#!/bin/bash

# =============================================================================
# Terminal Intelligence Setup Script for Linux
# =============================================================================
# This script automates the complete setup of Terminal Intelligence system:
# 1. Generates all commander files from CSV using batch_generate.sh
# 2. Creates Ollama models for each commander file using generate_commander.sh
# 3. Sets up aliases in .bashrc using create_aliases.sh
#
# Requirements:
# - batch_generate.sh
# - generate_commander.sh
# - create_aliases.sh
# - languages.csv
# - Ollama installed and running
# =============================================================================

set -e # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}===========================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}===========================================${NC}\n"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a file exists and is executable
check_script() {
    local script_name="$1"
    if [ ! -f "$script_name" ]; then
        print_error "Required script '$script_name' not found!"
        return 1
    fi

    if [ ! -x "$script_name" ]; then
        print_warning "Making '$script_name' executable..."
        chmod +x "$script_name"
    fi

    print_success "Found and verified '$script_name'"
    return 0
}

# Function to cleanup on error
cleanup_on_error() {
    local exit_code=$?
    local line_number=$1
    print_error "Setup failed at line $line_number with exit code $exit_code"
    print_error "Please check the errors above and try again."
    exit $exit_code
}

# Set error trap with line number
trap 'cleanup_on_error $LINENO' ERR

# =============================================================================
# MAIN EXECUTION
# =============================================================================

print_header "Terminal Intelligence Setup Starting"

# Verify we're in the correct directory
print_status "Verifying working directory..."
if [ ! -f "linux_TI.sh" ]; then
    print_error "This script must be run from the Terminal-Intelligence directory!"
    print_error "Current directory: $(pwd)"
    print_error "Please cd to the Terminal-Intelligence directory and try again."
    exit 1
fi
print_success "Running from correct directory: $(pwd)"

# Step 1: Verify prerequisites
print_header "Step 1: Verifying Prerequisites"

print_status "Checking for required scripts..."
check_script "batch_generate.sh"
check_script "generate_commander.sh"
check_script "create_aliases.sh"

print_status "Checking for languages.csv..."
if [ ! -f "languages.csv" ]; then
    print_error "languages.csv not found!"
    exit 1
fi
print_success "Found languages.csv"

print_status "Checking for Ollama..."
if ! command_exists ollama; then
    print_error "Ollama is not installed or not in PATH!"
    print_error "Please install Ollama first: https://ollama.ai/"
    exit 1
fi
print_success "Ollama is available"

print_status "Checking if Ollama service is running..."
if ! ollama list >/dev/null 2>&1; then
    print_error "Ollama service is not running!"
    print_error "Please start Ollama service first"
    exit 1
fi
print_success "Ollama service is running"

# Step 2: Generate commander files
print_header "Step 2: Checking/Generating Commander Files"

print_status "Checking existing commander files..."
existing_files=0
missing_files=0
files_to_generate=()

# Temporarily disable error exit for this section
set +e

# Check which files exist
while IFS=',' read -r language filename; do
    # Skip header row
    if [ "$language" = "language" ]; then
        continue
    fi

    # Trim whitespace
    language=$(echo "$language" | xargs)
    filename=$(echo "$filename" | xargs)

    # Skip empty lines
    if [ -z "$language" ] || [ -z "$filename" ]; then
        continue
    fi

    if [ -f "$filename" ]; then
        print_success "Found existing commander file: $filename"
        ((existing_files++))
    else
        print_warning "Missing commander file: $filename"
        files_to_generate+=("$language:$filename")
        ((missing_files++))
    fi
done <languages.csv

# Re-enable error exit
set -e

if [ $missing_files -eq 0 ]; then
    print_success "All commander files already exist ($existing_files files)"
else
    print_status "Generating $missing_files missing commander files..."
    if ./batch_generate.sh; then
        print_success "Missing commander files generated successfully"

        # Verify the files were actually created
        print_status "Verifying generated files..."
        verification_failed=0
        for entry in "${files_to_generate[@]}"; do
            IFS=':' read -r language filename <<<"$entry"
            if [ -f "$filename" ]; then
                print_success "Verified: $filename created successfully"
            else
                print_error "Failed: $filename was not created"
                ((verification_failed++))
            fi
        done

        if [ $verification_failed -gt 0 ]; then
            print_error "$verification_failed commander files failed to generate"
            exit 1
        fi
    else
        print_error "Failed to generate commander files"
        exit 1
    fi
fi

# Step 3: Create Ollama models
print_header "Step 3: Checking/Creating Ollama Models"

print_status "Checking existing Ollama models..."
existing_models=0
missing_models=0
model_count=0
failed_models=0

# Get list of existing ollama models
existing_ollama_models=$(ollama list | awk 'NR>1 {print $1}' | cut -d':' -f1)

# Read CSV and check/create models
while IFS=',' read -r language filename; do
    # Skip header row
    if [ "$language" = "language" ]; then
        continue
    fi

    # Trim whitespace
    language=$(echo "$language" | xargs)
    filename=$(echo "$filename" | xargs)

    # Skip empty lines
    if [ -z "$language" ] || [ -z "$filename" ]; then
        continue
    fi

    # Check if model already exists
    if echo "$existing_ollama_models" | grep -q "^${filename}$"; then
        print_success "Found existing Ollama model: $filename"
        ((existing_models++))
        continue
    fi

    print_status "Creating Ollama model for $language ($filename)..."
    ((missing_models++))

    # Check if the commander file exists
    if [ ! -f "$filename" ]; then
        print_warning "Commander file '$filename' not found, skipping..."
        ((failed_models++))
        continue
    fi

    # Create the Ollama model
    if ollama create "$filename" -f "$filename" >/dev/null 2>&1; then
        print_success "Created model: $filename"
        ((model_count++))
    else
        print_error "Failed to create model: $filename"
        ((failed_models++))
    fi

done <languages.csv

if [ $missing_models -eq 0 ]; then
    print_success "All Ollama models already exist ($existing_models models)"
else
    print_success "Created $model_count new Ollama models"
    if [ $failed_models -gt 0 ]; then
        print_warning "$failed_models models failed to create"
    fi
fi

# Step 4: Create aliases
print_header "Step 4: Checking/Setting Up Aliases"

print_status "Checking for existing aliases in .bashrc..."
if grep -q "Ollama Commander Aliases" "$HOME/.bashrc" 2>/dev/null; then
    print_success "Ollama Commander Aliases section already exists in .bashrc"

    # Check if we have all the aliases we need
    missing_aliases=0
    existing_aliases=0

    while IFS=',' read -r language filename; do
        # Skip header row
        if [ "$language" = "language" ]; then
            continue
        fi

        # Trim whitespace
        language=$(echo "$language" | xargs)
        filename=$(echo "$filename" | xargs)

        # Skip empty lines
        if [ -z "$language" ] || [ -z "$filename" ]; then
            continue
        fi

        # Generate expected alias name
        base_name=$(echo "$filename" | sed 's/-commander$//')
        alias_suffix=$(echo "$base_name" | cut -c1-2)
        alias_name="o$alias_suffix"

        if grep -q "alias $alias_name=" "$HOME/.bashrc" 2>/dev/null; then
            print_success "Found existing alias: $alias_name"
            ((existing_aliases++))
        else
            print_warning "Missing alias: $alias_name"
            ((missing_aliases++))
        fi
    done <languages.csv

    if [ $missing_aliases -gt 0 ]; then
        print_status "Found $missing_aliases missing aliases. Updating .bashrc..."
        if ./create_aliases.sh; then
            print_success "Missing aliases added and .bashrc reloaded successfully"
        else
            print_error "Failed to update aliases"
            exit 1
        fi
    else
        print_success "All aliases already exist ($existing_aliases aliases)"
        print_status "Reloading .bashrc to ensure aliases are active..."
        source "$HOME/.bashrc"
        print_success "✓ .bashrc reloaded successfully!"
    fi
else
    print_status "No existing aliases found. Running create_aliases.sh..."
    if ./create_aliases.sh; then
        print_success "Aliases created and .bashrc reloaded successfully"
    else
        print_error "Failed to create aliases"
        exit 1
    fi
fi

# Step 5: Verification
print_header "Step 5: Verification"

print_status "Verifying created Ollama models..."
echo "Available models:"

# Build a dynamic pattern from the CSV file
model_patterns=""
while IFS=',' read -r language filename; do
    # Skip header row
    if [ "$language" = "language" ]; then
        continue
    fi

    # Trim whitespace
    filename=$(echo "$filename" | xargs)

    # Skip empty lines
    if [ -z "$filename" ]; then
        continue
    fi

    if [ -z "$model_patterns" ]; then
        model_patterns="$filename"
    else
        model_patterns="$model_patterns|$filename"
    fi
done <languages.csv

if [ -n "$model_patterns" ]; then
    ollama list | grep -E "($model_patterns)" || print_warning "No commander models found in ollama list"
else
    print_warning "No model patterns found in languages.csv"
fi

print_status "Verifying aliases in .bashrc..."
if grep -q "Ollama Commander Aliases" "$HOME/.bashrc"; then
    print_success "Aliases found in .bashrc"
    echo "Available aliases:"
    grep "alias o" "$HOME/.bashrc" | tail -5
else
    print_warning "No aliases found in .bashrc"
fi

# Final summary
print_header "Setup Complete!"

total_languages=$(tail -n +2 languages.csv | grep -v '^[[:space:]]*$' | wc -l)
total_models=$((existing_models + model_count))
total_aliases=$((existing_aliases + missing_aliases))

echo -e "${GREEN}✓${NC} Commander files: $total_languages files ready"
echo -e "${GREEN}✓${NC} Ollama models: $total_models models available"
echo -e "${GREEN}✓${NC} Bash aliases: $total_aliases aliases configured"
echo -e "${GREEN}✓${NC} .bashrc reloaded and ready"

if [ $missing_files -eq 0 ] && [ $missing_models -eq 0 ] && [ ${missing_aliases:-0} -eq 0 ]; then
    print_success "Terminal Intelligence is fully up to date! All components were already in place."
else
    print_success "Terminal Intelligence setup completed successfully!"
    if [ $missing_files -gt 0 ]; then
        echo -e "  ${BLUE}→${NC} Generated $missing_files new commander files"
    fi
    if [ $missing_models -gt 0 ]; then
        echo -e "  ${BLUE}→${NC} Created $model_count new Ollama models"
    fi
    if [ ${missing_aliases:-0} -gt 0 ]; then
        echo -e "  ${BLUE}→${NC} Added ${missing_aliases:-0} new aliases"
    fi
fi

print_status "You can now use commands like: opy, ojs, ops, osh, ots"
print_status "Example: opy 'create a python script to read a CSV file'"
print_status ""
print_status "💡 Tip: You can add new languages to languages.csv and run this script again!"

echo -e "\n${BLUE}Happy coding!${NC} 🚀"

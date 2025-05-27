#!/bin/bash

# Default CSV file
CSV_FILE="languages.csv"
BASHRC_FILE="$HOME/.bashrc"

# Check if a custom CSV file is provided
if [ $# -eq 1 ]; then
    CSV_FILE="$1"
fi

# Check if CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: CSV file '$CSV_FILE' not found!"
    echo "Usage: $0 [csv_file]"
    exit 1
fi

# Check if .bashrc exists, create if it doesn't
if [ ! -f "$BASHRC_FILE" ]; then
    echo "Warning: $BASHRC_FILE not found. Creating it..."
    touch "$BASHRC_FILE"
fi

echo "Adding aliases to $BASHRC_FILE..."
echo "=================================="

# Create a backup of .bashrc
cp "$BASHRC_FILE" "$BASHRC_FILE.backup.$(date +%Y%m%d_%H%M%S)"
echo "Backup created: $BASHRC_FILE.backup.$(date +%Y%m%d_%H%M%S)"

# Add a comment section for our aliases
echo "" >>"$BASHRC_FILE"
echo "# Ollama Commander Aliases - Added $(date)" >>"$BASHRC_FILE"

# Read CSV file line by line, skipping header
tail -n +2 "$CSV_FILE" | while IFS=',' read -r language filename; do
    # Trim whitespace
    language=$(echo "$language" | xargs)
    filename=$(echo "$filename" | xargs)

    # Skip empty lines
    if [ -z "$language" ] || [ -z "$filename" ]; then
        continue
    fi

    # Extract first 2 letters of the commander filename
    # Remove any "-commander" suffix first, then get first 2 chars
    base_name=$(echo "$filename" | sed 's/-commander$//')
    alias_suffix=$(echo "$base_name" | cut -c1-2)
    alias_name="o$alias_suffix"

    echo "Creating alias: $alias_name -> ollama run $filename"

    # Add alias to .bashrc
    echo "alias $alias_name='ollama run $filename'" >>"$BASHRC_FILE"
done

# Add the base gemma3:12b alias
echo "Creating alias: oll -> ollama run gemma3:12b"
echo "alias oll='ollama run gemma3:12b'" >>"$BASHRC_FILE"

echo "" >>"$BASHRC_FILE"
echo "# End of Ollama Commander Aliases" >>"$BASHRC_FILE"

echo "=================================="
echo "Aliases added successfully!"
echo ""
echo "Reloading .bashrc..."
# Note: sourcing .bashrc in a script affects only the script's environment
# It doesn't propagate to the parent shell
if source "$BASHRC_FILE" 2>/dev/null; then
    echo "✓ .bashrc reloaded successfully!"
    echo ""
    echo "🔄 Important: The aliases are active in this script's environment,"
    echo "   but you may need to run 'source ~/.bashrc' manually in your"
    echo "   current terminal to activate them there."
else
    echo "⚠️  Could not reload .bashrc automatically"
    echo "   Please run 'source ~/.bashrc' manually to activate aliases"
fi
echo ""
echo "Available aliases:"
echo "------------------"

# Show the aliases that were added
tail -n +2 "$CSV_FILE" | while IFS=',' read -r language filename; do
    language=$(echo "$language" | xargs)
    filename=$(echo "$filename" | xargs)

    if [ -n "$language" ] && [ -n "$filename" ]; then
        base_name=$(echo "$filename" | sed 's/-commander$//')
        alias_suffix=$(echo "$base_name" | cut -c1-2)
        alias_name="o$alias_suffix"
        echo "$alias_name -> ollama run $filename ($language)"
    fi
done

echo "oll -> ollama run gemma3:12b (Base Model)"

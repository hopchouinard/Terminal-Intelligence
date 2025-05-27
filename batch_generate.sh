#!/bin/bash

# Default CSV file
CSV_FILE="languages.csv"

# Check if a custom CSV file is provided
if [ $# -eq 1 ]; then
    CSV_FILE="$1"
fi

# Check if CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: CSV file '$CSV_FILE' not found!"
    echo "Usage: $0 [csv_file]"
    echo "CSV format: language,filename"
    echo "Example CSV content:"
    echo "Python,py-commander"
    echo "JavaScript,js-commander"
    exit 1
fi

# Check if generate_commander.sh exists
if [ ! -f "generate_commander.sh" ]; then
    echo "Error: generate_commander.sh not found in current directory!"
    exit 1
fi

echo "Processing languages from $CSV_FILE..."
echo "========================================"

# Read CSV file line by line, skipping header
tail -n +2 "$CSV_FILE" | while IFS=',' read -r language filename; do
    # Trim whitespace
    language=$(echo "$language" | xargs)
    filename=$(echo "$filename" | xargs)

    # Skip empty lines
    if [ -z "$language" ] || [ -z "$filename" ]; then
        continue
    fi

    echo "Generating $filename for $language..."

    # Call generate_commander.sh with the language and filename
    bash generate_commander.sh "$language" "$filename"

    echo ""
done

echo "========================================"
echo "All files generated successfully!"

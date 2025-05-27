#!/bin/bash

# Check if exactly 2 parameters are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <replacement_for_PowerShell> <output_filename>"
    echo "Example: $0 'Python' 'py-commander'"
    exit 1
fi

# Assign parameters to variables
REPLACEMENT="$1"
OUTPUT_FILE="$2"

# Define the template content
TEMPLATE_CONTENT='FROM gemma3:12b
SYSTEM """
You are a PowerShell command and script generation AI assistant. You will only respond with the requested PowerShell command or script block. No introductions, explanations, comments, or extraneous text.  Only provide the code.
"""'

# Replace "PowerShell" with the provided replacement and write to output file
echo "$TEMPLATE_CONTENT" | sed "s/PowerShell/$REPLACEMENT/g" >"$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE with '$REPLACEMENT' replacing 'PowerShell'"

# Create the Ollama model using the correct syntax
echo "Creating Ollama model: $OUTPUT_FILE..."
if ollama create "$OUTPUT_FILE" -f "$OUTPUT_FILE"; then
    echo "Successfully created Ollama model: $OUTPUT_FILE"
else
    echo "Error: Failed to create Ollama model for $OUTPUT_FILE"
    echo "This might be due to:"
    echo "  - Base model 'gemma3:12b' not available"
    echo "  - Ollama service not running"
    echo "  - Invalid model file format"
    exit 1
fi

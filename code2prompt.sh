#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Function to check if a file is likely to be binary
is_binary() {
    if file -b --mime-type "$1" | grep -qE '^(application/|image/|audio/|video/)'; then
        return 0  # It's likely binary
    else
        return 1  # It's likely not binary
    fi
}

# Function to process each file
process_file() {
    local file="$1"
    echo "DEBUG: Processing file: $file" >&2
    
    # Ensure we're not processing the output file itself
    if [[ "$file" == "$output_file" ]]; then
        echo "DEBUG: Skipping output file" >&2
        return
    fi
      
    local file_size=$(stat -f %z "$file")
    echo "DEBUG: File size: $file_size bytes" >&2
    
    if [ "$file_size" -gt 1048576 ]; then  # Skip files larger than 1MB
        echo "Skipped large file: $file ($(numfmt --to=iec-i --suffix=B --format="%.1f" $file_size))" >&2
        return
    fi

    if is_binary "$file"; then
        echo "Skipped binary file: $file" >&2
        return
    fi

    echo "File: $file" >> "$temp_file"
    echo "Content:" >> "$temp_file"
    cat "$file" >> "$temp_file"
    echo "----------------------------------------" >> "$temp_file"
    
    echo "Processed: $file ($(numfmt --to=iec-i --suffix=B --format="%.1f" $file_size))" >&2
}

# Function to recursively process directories
process_directory() {
    local dir="$1"
    local depth="$2"
    
    if [ "$depth" -gt 10 ]; then
        echo "DEBUG: Max depth reached, stopping at: $dir" >&2
        return
    fi
    
    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            echo "DEBUG: Entering directory: $item (depth: $depth)" >&2
            process_directory "$item" $((depth + 1))
        elif [ -f "$item" ]; then
            process_file "$item"
        fi
    done
}

# Initialize default values
directory="."
output_file=""

# Parse command line arguments
while getopts ":d:o:" opt; do
  case $opt in
    d) directory="$OPTARG" ;;
    o) output_file="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

echo "DEBUG: Working directory before cd: $(pwd)" >&2

# Change to the specified directory
cd "$directory"

echo "DEBUG: Working directory after cd: $(pwd)" >&2

# Get the actual name of the current directory
current_dir=$(basename "$(pwd)")
echo "DEBUG: Current directory name: $current_dir" >&2

# Use default output file name if not specified
if [ -z "$output_file" ]; then
    output_file="${current_dir}_code2Prompt.txt"
fi

echo "DEBUG: Output file: $output_file" >&2

# Create a temporary file
temp_file=$(mktemp)
echo "DEBUG: Temporary file: $temp_file" >&2

echo "Processing directory: $PWD ($current_dir)" >&2
echo "Output will be saved to: $output_file" >&2

# Start recursive processing from the current directory
process_directory "." 0

# Move the temporary file to the final output file
mv "$temp_file" "$output_file"

echo "Processing complete. Output saved to $output_file" >&2
output_size=$(stat -f %z "$output_file")
echo "Output file size: $(numfmt --to=iec-i --suffix=B --format="%.1f" $output_size)" >&2
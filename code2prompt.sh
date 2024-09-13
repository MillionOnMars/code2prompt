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

# Function to check if a file is likely to be source code
is_source_code() {
    local file="$1"
    local extension="${file##*.}"
    local source_extensions=("c" "cpp" "h" "hpp" "xml" "java" "py" "js" "ts" "go" "rb" "php" "cs" "swift" "kt" "scala" "rs" "sh" "pl" "pm")
    
    for ext in "${source_extensions[@]}"; do
        if [[ "$extension" == "$ext" ]]; then
            return 0  # It's likely source code
        fi
    done
    
    return 1  # It's likely not source code
}

# Array to store file sizes and names
declare -a file_sizes

# Function to process each file
process_file() {
    local file="$1"
    
    # Ensure we're not processing the output file itself
    if [[ "$file" == "$output_file" ]]; then
        return
    fi
      
    local file_size=$(stat -f %z "$file")
    
    if [ "$file_size" -gt 1048576 ]; then  # Skip files larger than 1MB
        echo "Skipped large file: $file ($(numfmt --to=iec-i --suffix=B --format="%.1f" $file_size))" >&2
        return
    fi

    if is_binary "$file"; then
        echo "Skipped binary file: $file" >&2
        return
    fi

    if ! is_source_code "$file"; then
        echo "Skipped non-source file: $file" >&2
        return
    fi

    echo "File: $file" >> "$temp_file"
    echo "Content:" >> "$temp_file"
    cat "$file" >> "$temp_file"
    echo "----------------------------------------" >> "$temp_file"
    
    echo "Processed: $file ($(numfmt --to=iec-i --suffix=B --format="%.1f" $file_size))" >&2

    # Add file size and name to the array
    file_sizes+=("$file_size:$file")
}

# Function to recursively process directories
process_directory() {
    local dir="$1"
    local depth="$2"
    
    if [ "$depth" -gt 10 ]; then
        echo "Max depth reached, stopping at: $dir" >&2
        return
    fi
    
    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            process_directory "$item" $((depth + 1))
        elif [ -f "$item" ]; then
            process_file "$item"
        fi
    done
}

# Initialize default values
directory="."
output_file=""
verbose=false

# Parse command line arguments
while getopts ":d:o:v" opt; do
  case $opt in
    d) directory="$OPTARG" ;;
    o) output_file="$OPTARG" ;;
    v) verbose=true ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

# Change to the specified directory
cd "$directory"

# Get the actual name of the current directory
current_dir=$(basename "$(pwd)")

# Use default output file name if not specified
if [ -z "$output_file" ]; then
    output_file="${current_dir}_code2Prompt.txt"
fi

# Create a temporary file
temp_file=$(mktemp)

echo "Processing directory: $PWD ($current_dir)" >&2
echo "Output will be saved to: $output_file" >&2

# Start recursive processing from the current directory
process_directory "." 0

# Move the temporary file to the final output file
mv "$temp_file" "$output_file"

echo "Processing complete. Output saved to $output_file" >&2
output_size=$(stat -f %z "$output_file")
echo "Output file size: $(numfmt --to=iec-i --suffix=B --format="%.1f" $output_size)" >&2

# If verbose mode is on, print the top 10 largest files
if $verbose; then
    echo "Top 10 largest source files:" >&2
    IFS=$'\n' sorted=($(sort -rn <<<"${file_sizes[*]}"))
    for i in "${!sorted[@]}"; do
        if [ $i -eq 10 ]; then
            break
        fi
        IFS=':' read -r size file <<< "${sorted[$i]}"
        echo "$(($i+1)). $file ($(numfmt --to=iec-i --suffix=B --format="%.1f" $size))" >&2
    done
fi
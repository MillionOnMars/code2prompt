# code2prompt

A utility script for recursively listing and processing files in a directory, excluding binaries and large files. This tool is designed to help developers quickly generate a text representation of their codebase, which can be useful for documentation, code reviews, or as input for AI-assisted coding tools.

## Installation

1 Clone this repository:

```bash
git clone https://github.com/your-org/code2prompt.git
```

2 Move the `code2prompt` script to a directory in your PATH:

```bash
mv code2prompt/code2prompt ~/bin/
```

3 Make the script executable:

```bash
chmod +x ~/bin/code2prompt
```

4 Ensure that `~/bin` is in your PATH by adding the following line to your`~/.zshrc` or `~/.bashrc` or `~/bash_profile`:

```bash
export PATH="$HOME/bin:$PATH"
```

5 Reload your shell configuration:

```bash
source ~/.bashrc  # or source ~/.bash_profile
```

or

```bash
source ~/.zshrc  
```

## Usage

Basic usage:

```bash
code2prompt [options]
```

Options:

- `-d <directory>`: Specify the directory to process (default: current directory)

- `-o <output_file>`: Specify the output file name (default: <current_directory_name>_code2Prompt.txt)
- `-q`: Quiet mode (suppress verbose output)

## Features

- Recursively processes files in the specified directory
- Excludes binary files and files larger than 1MB
- Limits recursion depth to 10 levels to prevent infinite loops
- Provides verbose output by default, with a quiet mode option
- Generates a single text file containing the content of all processed files

## Examples

1 Process the current directory with default settings:

```bash
code2prompt
```

2 Process a specific directory:

```bash
code2prompt -d /path/to/your/project
```

3 Specify a custom output file:

```bash
code2prompt -o my_project_files.txt
```

4 Process a directory in quiet mode:

```bash
code2prompt -d /path/to/your/project -q
```

5 Combine options:

```bash
code2prompt -d /path/to/your/project -o custom_output.txt -q
```

## Output

The script generates a text file containing the content of all processed files. Each file's content is preceded by its name and followed by a separator:

File: /path/to/file1.txt
Content:
[Content of file1.txt]
File: /path/to/file2.py
Content:
[Content of file2.py]

## Limitations

- Files larger than 1MB are skipped to prevent processing very large files
- Binary files are excluded
- Maximum recursion depth is set to 10 levels
- Symbolic links are not followed to prevent loops

## Troubleshooting

If you encounter any issues, please check the following:

1. Ensure the script is executable (`chmod +x ~/bin/code2prompt`)
2. Verify that the directory containing the script is in your PATH (`echo $PATH`)
3. Check that you have the necessary permissions to read the files and write to the output location
4. If the script seems to hang, it might be processing a large directory. Use the `-q` option to reduce output and see if it completes

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a new branch for your feature or bug fix
3. Make your changes and commit them with a clear commit message
4. Push your changes to your fork
5. Create a pull request with a description of your changes

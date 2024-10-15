#!/bin/bash

# Function to check if sqlmap is installed
check_sqlmap() {
    if ! command -v sqlmap &> /dev/null; then
        echo "sqlmap not found. Installing..."
        install_sqlmap
    else
        echo "sqlmap is already installed."
    fi
}

# Function to install sqlmap
install_sqlmap() {
    # Clone sqlmap from GitHub
    git clone --quiet https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap
    echo "sqlmap has been installed to /opt/sqlmap"
}

# Input file containing URLs (one per line)
input_file="output.txt"

# Check if sqlmap is installed
check_sqlmap

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
    echo "File not found: $input_file"
    exit 1
fi

# SQLMap settings (adjust as needed)
level=3
risk=3
threads=5
tamper_script="space2comment" # Change or remove as needed

# Set output directory to scriptdir/data/output
script_dir="$(dirname "$(realpath "$0")")"
output_dir="$script_dir/data/output"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Maximum number of concurrent sqlmap processes
max_jobs=5
current_jobs=0

# Loop through each URL in the input file
while IFS= read -r url; do
    # Skip empty lines
    [[ -z "$url" ]] && continue

    # Run sqlmap with the URL in the background
    echo "Running sqlmap on: $url"
    sqlmap -u "$url" --level="$level" --risk="$risk" --random-agent \
        --tamper="$tamper_script" --batch --threads="$threads" --output-dir="$output_dir" &

    # Increment the current job counter
    ((current_jobs++))

    # If we reach the max jobs, wait for them to finish
    if [[ $current_jobs -ge $max_jobs ]]; then
        wait # Wait for all background jobs to finish
        current_jobs=0 # Reset the job counter
    fi

done < "$input_file"

# Wait for any remaining jobs to finish
wait

echo "All scans completed. Results are stored in $output_dir."

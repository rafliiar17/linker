#!/bin/bash

# Input file containing URLs (one per line)
input_file="urls.txt"
# Output file to save results
output_file="output.txt"

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
    echo "File not found: $input_file"
    exit 1
fi

# Clear the output file if it exists or create a new one
> "$output_file"

# Function to decode a single URL
decode_url() {
    local url="$1"
    
    # Extract the base64 parameter using parameter expansion
    base64_param="${url##*param=}"
    base64_param="${base64_param%%=*}"  # Remove everything after the '=' for decoding

    # Debugging: Print the base64 parameter and its length
    echo "Base64 parameter: '$base64_param' (length: ${#base64_param})"

    # Determine the number of padding characters to add
    padding_length=$((4 - ${#base64_param} % 4))
    if [[ $padding_length -lt 4 ]]; then
        base64_param+=$(printf '%*s' "$padding_length" '' | tr ' ' '=')
    fi

    # Decode the base64 parameter
    decoded_param=$(echo "$base64_param" | base64 --decode 2>/dev/null)

    # Check if decoding was successful
    if [[ $? -ne 0 ]]; then
        echo "Base64 decoding failed for: $base64_param" >> "$output_file"
        echo "Error decoding URL: $url"  # Print error to terminal
        return
    fi

    # Construct the new URL using the decoded parameter
    new_url="${url/param=$base64_param/param=$decoded_param=}"

    # Save the new URL to the output file
    echo "$new_url" >> "$output_file"

    # Print the new URL to the terminal
    echo "New URL constructed: $new_url"
}

# Export the function for parallel processing
export -f decode_url

# Read each URL from the input file and process it in parallel
while IFS= read -r url; do
    # Skip empty lines
    [[ -z "$url" ]] && continue
    # Run the decode_url function in the background
    decode_url "$url" &
done < "$input_file"

# Wait for all background jobs to finish
wait

echo "Output saved to $output_file"

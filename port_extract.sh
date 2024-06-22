#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $(basename $0) -i input_file -o output_file"
    echo
    echo "Extract port numbers from an Nmap output file."
    echo
    echo "  -i input_file    Specify the Nmap output file to parse."
    echo "  -o output_file   Specify the file to write the port numbers to."
    echo "  -h               Display this help message."
    echo
    echo "Example:"
    echo "  $(basename $0) -i all_ports.nmap -o port_list.txt"
}

# Check if no arguments were passed
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Parse command line arguments
while getopts "hi:o:" opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        i)
            input_file="$OPTARG"
            ;;
        o)
            output_file="$OPTARG"
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
done

# Check if input and output files are set
if [ -z "$input_file" ] || [ -z "$output_file" ]; then
    echo "Error: Both input and output files must be specified."
    echo
    show_help
    exit 1
fi

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' does not exist."
    exit 1
fi

# Extract port numbers
grep -oP '\d+/tcp' "$input_file" | awk -F '/' '{print $1}' | sort -n | uniq > "$output_file"

echo "Port numbers extracted to $output_file"

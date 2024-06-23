#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $(basename $0) -i input_file -o output_file"
    echo
    echo "Extract port numbers from an Nmap output file."
    echo
    echo "  -i input_file    Specify the Nmap output file to parse (.nmap or .gnmap)."
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

# Temporary file to store the extracted port numbers
temp_file=$(mktemp)

# Determine the format of the input file
case "$input_file" in
    *.nmap)
        # Extract port numbers from .nmap file
        grep -oP '\d+/tcp' "$input_file" | awk -F '/' '{print $1}' | sort -n | uniq > "$temp_file"
        ;;
    *.gnmap)
        # Extract port numbers from .gnmap file
        grep -oP 'Ports: \K[^ ]+' "$input_file" | awk -F '[,/]' '{for (i=1; i<NF; i+=2) print $i}' | sort -n | uniq > "$temp_file"
        ;;
    *.xml)
        echo "Error: XML input files are not supported by this script."
        rm -f "$temp_file"
        exit 1
        ;;
    *)
        echo "Error: Unsupported file format. Supported formats are .nmap and .gnmap."
        rm -f "$temp_file"
        exit 1
        ;;
esac

# Output the port numbers to the specified file
cat "$temp_file" > "$output_file"

# Print the port numbers as a comma-separated line to the screen
ports=$(paste -sd, "$temp_file")
echo "Ports: $ports"

# Suggest Nmap commands for deeper enumeration
echo
echo "Suggested Nmap Commands for Deeper Enumeration:"
echo
echo "1. Detailed version and script scan:"
echo "   nmap -iL live_subdomains.txt -p $ports -sCV -oA nmap/software_enum"
echo
echo "2. Aggressive scan with OS detection, version detection, script scanning, and traceroute:"
echo "   nmap -iL live_subdomains.txt -p $ports -A -oA nmap/aggressive_scan"
echo
echo "3. Scan with default scripts and service versions:"
echo "   nmap -iL live_subdomains.txt -p $ports -sV --script=default -oA nmap/default_scripts"
echo
echo "4. Run all scripts in the vuln category to check for vulnerabilities:"
echo "   nmap -iL live_subdomains.txt -p $ports --script=vuln -oA nmap/vuln_scan"
echo
echo "5. Scan with UDP, TCP, service version detection, and OS detection:"
echo "   nmap -iL live_subdomains.txt -sSU -p U:$ports,T:$ports -sV -oA nmap/udp_tcp_scan"

# Clean up temporary file
rm -f "$temp_file"

echo "Port numbers extracted to $output_file"

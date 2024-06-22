# nmap_port-extract
A bash script to read an nmap output file and then use awk and grep to dump out a list of port numbers for further scanning.

How to Use the Script:

    Save the script to a file, e.g., extract_ports.sh.

    Make the script executable:
    
    chmod +x extract_ports.sh

Run the script with the required options:

    ./extract_ports.sh -i all_ports.nmap -o port_list.txt

Explanation of the Additions:

    show_help function: Provides a usage guide and examples for how to run the script.

    Argument Parsing:
        getopts "hi:o:" handles the command-line arguments.
        h option displays the help.
        i option specifies the input file.
        o option specifies the output file.
        If either the input file or output file is not specified, the script shows an error message and the help menu.

    Error Handling:
        Checks if both input_file and output_file are provided.
        Checks if the input file exists before attempting to parse it.

    Execution:
        The core functionality to extract port numbers is unchanged but is now wrapped with argument handling and validation.

This makes the script more robust and user-friendly, allowing for easy reuse with different files.

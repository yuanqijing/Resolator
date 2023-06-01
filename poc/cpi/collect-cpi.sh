#!/bin/bash

# Check if the PID argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <pid>"
    exit 1
fi

# Check if the process with such PID exists
if ! ps -p $1 > /dev/null; then
    echo "Process with PID $1 not found."
    echo "Usage: $0 <pid>"
    exit 1
fi

pid=$1

# Get the current date
current_date=$(date '+%Y-%m-%d')

# Form the output file name using the current date
output_file="cpi_output_${current_date}.txt"

# Get the absolute path of the output file
output_file_path="$(pwd)/$output_file"

# Print the absolute path of the output file
echo "Output will be written to: $output_file_path"

while true; do
    # Run perf stat and save the output
    perf_output=$(perf stat -e cycles,instructions -p "$pid" -- sleep 1 2>&1)

    # Extract cycles and instructions from the output
    cycles=$(echo "$perf_output" | awk '/cycles/ {print $1}' | tr -d ',')
    instructions=$(echo "$perf_output" | awk '/instructions/ {print $1}' | tr -d ',')

    # Calculate CPI
    if [ -z "$instructions" ] || [ "$instructions" -eq 0 ]; then
        cpi="NaN"
    else
        cpi=$(echo "$cycles / $instructions" | bc -l)
    fi

    # Get the current timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Write the CPI with timestamp to the output file
    echo "$timestamp - CPI: $cpi"
    echo "$timestamp - CPI: $cpi" >> $output_file_path

    # Wait for 5 seconds before the next round
    sleep 5
done

#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [-u] [TSV File] [Minimum Quality]"
    echo "  -u: Include 'Undetermined' quality rows"
}

# Parse command-line options
include_undetermined=false
while getopts ":u" opt; do
  case $opt in
    u)
      include_undetermined=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    usage
    exit 1
fi

filename="$1"
min_quality="$2"

# Define the quality levels in descending order
declare -A quality_levels
quality_levels=([Complete]=4 [High-quality]=3 [Medium-quality]=2 [Low-quality]=1 [Undetermined]=0)

# Get the minimum quality index
min_quality_index=${quality_levels[$min_quality]}
if [ -z "$min_quality_index" ]; then
    echo "Invalid quality level provided."
    exit 1
fi

# Check if the file exists
if [ ! -f "$filename" ]; then
    echo "File not found: $filename"
    exit 1
fi

# Parse the TSV file and print matching contig_ids
awk -F'\t' -v min_index="$min_quality_index" -v include_u="$include_undetermined" '
BEGIN {
    quality["Complete"]=4
    quality["High-quality"]=3
    quality["Medium-quality"]=2
    quality["Low-quality"]=1
    quality["Undetermined"]=0
}
NR > 1 { # Skip the header line
    if (quality[$8] >= min_index || (include_u == "true" && $8 == "Undetermined")) {
        print $1
    }
}
' "$filename"

# End of script

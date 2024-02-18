#!/usr/bin/env python
import csv
import os
import argparse
import sys

def read_table(filename, min_quality, undetermined=False):
    quality_order = ['Undetermined', 'Low-quality', 'Medium-quality', 'High-quality', 'Complete']
    
    # Ensure the minimum quality is a valid entry
    if min_quality not in quality_order:
        raise ValueError("Invalid quality level provided.")

    min_quality_index = quality_order.index(min_quality)
    matching_contigs = []

    with open(filename, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            row_quality = row['checkv_quality']
            if quality_order.index(row_quality) >= min_quality_index or (undetermined and row_quality == 'Undetermined'):
                matching_contigs.append(row['contig_id'])

    return matching_contigs

def main():
    parser = argparse.ArgumentParser(description='Filter contigs based on quality.')
    parser.add_argument('filename', type=str, help='Name of the CSV file containing the table.')
    parser.add_argument('min_quality', type=str, help='Minimum quality required (e.g., Complete, High-quality).')
    parser.add_argument('-u', '--undetermined', action='store_true', help='Include undetermined contigs.')
    parser.add_argument('--version', action='version', version='%(prog)s 0.1')
    args = parser.parse_args()

    if not args.filename:
        print("Error: No filename provided.")
        sys.exit(1)
    
    if not os.path.isfile(args.filename):
        print("Error: File not found: {}".format(args.filename))
        sys.exit(1)

    try:
        matching_contigs = read_table(args.filename, args.min_quality, args.undetermined)
        for contig in matching_contigs:
            print(contig)
        
        print("Total: {}".format(len(matching_contigs)), file=sys.stderr)
    except Exception as e:
        print("Error: {}".format(e))

if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""
This script automatically creates a 'sample.csv' file from all .sra files
found in the 'input/' directory. The CSV will contain two columns:
'sample_id' and 'sra_path', which can be used as input for a pipeline.
"""

import os
import csv
from pathlib import Path

def generate_sample_csv(input_folder: Path, output_csv: Path = None) -> bool:
    """
    Search for .sra files in the input folder and create a sample.csv file.
    Returns True if the file was created successfully, False otherwise.
    """
    if output_csv is None:
        output_csv = input_folder / "sample.csv"
    
    # Get all .sra files in the folder
    sra_files = sorted(input_folder.glob("*.sra"))

    if not sra_files:
        print(f"Error: No .sra files found in '{input_folder}'.")
        return False
    
    try:
        with open(output_csv, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['sample_id', 'sra_path'])  # header

            for sra_file in sra_files:
                sample_id = sra_file.stem  # remove .sra extension
                rel_path = str(Path("input") / sra_file.name)  # relative path
                writer.writerow([sample_id, rel_path])
                print(f"Added: {sample_id} -> {rel_path}")

        print(f"\nSuccessfully created '{output_csv.name}' with {len(sra_files)} sample(s).")
        return True

    except Exception as e:
        print(f"Error while writing the CSV: {e}")
        return False

def main():
    print("Looking for SRA files in the 'input/' folder...")

    script_path = Path(__file__).absolute()
    pipeline_root = script_path.parent
    input_folder = pipeline_root / "input"

    if not input_folder.exists():
        print(f"'input/' folder not found at {input_folder}")
        print("Please create the folder and add your .sra files.")
        return

    generate_sample_csv(input_folder)

if __name__ == "__main__":
    main()

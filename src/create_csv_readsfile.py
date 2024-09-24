import os
import csv
import argparse

# Function to generate CSV from FASTQ files in a directory
def generate_csv(fastq_dir, output_csv):
    rows = []

    # Walk through the directory and find paired-end FASTQ files
    for filename in os.listdir(fastq_dir):
        if filename.endswith('_R1.fastq.gz'):
            sample_id = filename.split('_R1.fastq.gz')[0]
            read_1 = os.path.join(fastq_dir, filename)
            read_2 = os.path.join(fastq_dir, sample_id + '_R2.fastq.gz')
            rows.append([sample_id, read_1, read_2])

    # Writing to CSV
    with open(output_csv, 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(['sample_id', 'read_1', 'read_2'])
        csvwriter.writerows(rows)

    print(f'CSV file created successfully at {output_csv}!')


def main():
    parser = argparse.ArgumentParser(description='Generate CSV from FASTQ files.')
    parser.add_argument('--fastq_dir', required=True, help='Directory containing FASTQ files')
    parser.add_argument('--output_csv', default='readsfile.csv', help='Output CSV file name (default: readsfile.csv)')
    
    args = parser.parse_args()

    # Generate CSV from the provided FASTQ directory
    generate_csv(args.fastq_dir, args.output_csv)

if __name__ == "__main__":
    main()

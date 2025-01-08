# SAPseq Pipeline Build

Do you not like coding?

Do you not hate .csv files?

Do you enjoy copying and pasting?

Are you fundamentally lazy?

This pipeline is for you!

With minimal effort, you too can process SAPseq data!

## Features

- **For `--sapseq`:** Quickly generate a CSV for in-house pulldown data with single-end reads.
- **Without `--sapseq`:** Generate a more detailed CSV with custom parameters.

## How to Use

### Access the Tool
Download make_config.html and open.

### Generate a CSV

#### 1. For `--sapseq`
1. Enter your data in the `NAME, INPUT_PATH, CLASS_TIM` format in the first text area. T = target, I = input, M = miRNA
2. Example input:

input1,/path/to/input1.fastq.gz,I

3. Click **Generate CSV** to download `config.csv`.

#### 2. Without `--sapseq`
1. Enter your data in the `NAME, INPUT_PATH, 5ADAPTER, UMI, UMI_LOC, 3ADAPTER, CLASS_TIM` format in the second text area.
2. Example input:

sample1,/path/to/sample1.fastq.gz,AGCTG,5,NNNNXXXCCCNNNNNN,GCTAG,T
sample2,/path/to/sample2.fastq.gz,AGCTG,5,NNNNXXXCCCNNNNNN,GCTAG,T

3. Click **Generate CSV** to download `config.csv`.

### Upload the CSV to Your HPC Cluster
1. Save the `config.csv` file.
2. Upload the file to your HPC cluster.
3. Run the preprocessing step using the following commands:
```bash
sed -i 's/\([^,]*,[^,]*,[^,]*\).*/\1/' config.csv
echo "" >> config.csv
sbatch preprocessing.sh --config config.csv --o ./output_directory --sapseq



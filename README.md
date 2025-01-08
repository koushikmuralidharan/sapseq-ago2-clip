# CSV Input Generator

This script provides an interface for generating CSV configuration files for the SAPseq analysis pipeline. It allows users to input data in specific formats and download a CSV file for HPC cluster processing.

## Features

- Supports in-house pulldown data with single-end reads.
- Generates CSVs for use with the `--sapseq` option or a custom pipeline encoding.

## Usage

1. https://koushikmuralidharan.github.io/sapseq-ago2-clip/
2. Input your rows in the specified format:
   - **For `--sapseq`:** `NAME, INPUT_PATH, CLASS_TIM`
   - **Without `--sapseq`:** `NAME, INPUT_PATH, 5ADAPTER, UMI, UMI_LOC, 3ADAPTER, CLASS_TIM`
3. Click the "Generate CSV" button to download the configuration file.

# CSV Input Generator

This script provides an interface for generating CSV configuration files for the SAPseq analysis pipeline. It allows users to input data in specific formats and download a CSV file for HPC cluster processing.

## Features

- Supports in-house pulldown data with single-end reads.
- Generates CSVs for use with the `--sapseq` option or a custom pipeline encoding.

## Usage

1. Copy the HTML code below and host it on a local server or open it directly in a web browser.
2. Input your rows in the specified format:
   - **For `--sapseq`:** `NAME, INPUT_PATH, CLASS_TIM`
   - **Without `--sapseq`:** `NAME, INPUT_PATH, 5ADAPTER, UMI, UMI_LOC, 3ADAPTER, CLASS_TIM`
3. Click the "Generate CSV" button to download the configuration file.

### Sample HTML Code

```html
<!DOCTYPE html>
<html>
<head>
    <title>CSV Input Generator</title>
    <style>
        /* CSS styles here */
    </style>
</head>
<body>
    <h1>CSV Input Generator</h1>
    <p>Welcome to the SAPseq analysis pipeline. For in-house pulldown data, include <code>--sapseq</code> while calling the command.</p>
    <pre>input1,/gpfs/home/kmuralidharan/sapseq/unsorted_hepatocytes/input/NS_KM1_input.fastq.gz,I
input2,/gpfs/home/kmuralidharan/sapseq/unsorted_hepatocytes/input/NS_KM2_input.fastq.gz,I
target1,/gpfs/home/kmuralidharan/sapseq/unsorted_hepatocytes/input/NS_KM1_target.fastq.gz,T
target2,/gpfs/home/kmuralidharan/sapseq/unsorted_hepatocytes/input/NS_KM2_target.fastq.gz,T
miRNA1,/gpfs/home/kmuralidharan/sapseq/unsorted_hepatocytes/input/NS_KM1_miRNA.fastq.gz,M
miRNA2,/gpfs/home/kmuralidharan/sapseq/unsorted_hepatocytes/input/NS_KM2_miRNA.fastq.gz,M</pre>
    <div class="container">
        <label>Enter rows (comma-separated):</label>
        <textarea></textarea>
        <button>Generate CSV</button>
    </div>
    <script>
        // JavaScript for CSV generation
    </script>
</body>
</html>

#!/bin/sh
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64gb
#SBATCH --time=24:00:00
#SBATCH --partition=highmem

#===============================================================================
# PREPROCESSING SCRIPT
#===============================================================================

# Parse command-line arguments
while [ "$1" != "" ]; do
    case $1 in
        --config ) shift
                   CONFIG_FILE=$1
                   ;;
        --o )      shift
                   OUTPUT_DIR=$1
                   ;;
        --sapseq ) SAPSEQ_MODE=true
                   ;;
        * )        echo "Invalid parameter: $1"
                   exit 1
    esac
    shift
done

if [ -z "$CONFIG_FILE" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: sbatch preprocessing.sh --config <config_file.csv> --o <output_directory> [--sapseq]"
    exit 1
fi

# Create output directories
mkdir -p "$OUTPUT_DIR/fastqc_results"
mkdir -p "$OUTPUT_DIR/multiqc_results"
mkdir -p "$OUTPUT_DIR/Step_01_Results/cutadapt"
mkdir -p "$OUTPUT_DIR/Step_01_Results/umi_extract"
mkdir -p "$OUTPUT_DIR/Step_01_Results/processed_fastqc"

# Load modules
module purge

echo ".d8888.  .d8b.  d8888b. .d8888.   d88888b  .d88b."
echo "88'  YP d8' \`8b 88  \`8D 88'  YP 88'     .8P  Y8."
echo "\`8bo.   88ooo88 88oodD' \`8bo.   88ooooo 88    88"
echo "  \`Y8b. 88~~~88 88~~~     \`Y8b. 88~~~~~ 88    88"
echo "db   8D 88   88 88        db   8D 88.     \`8P  d8'"
echo "\`8888Y' YP   YP 88      \`8888Y' Y88888P  \`Y88'Y8"
echo "                                                 "
echo "                                                 "

if [ "$SAPSEQ_MODE" = true ]; then
    # Read simplified config file
    while IFS="," read -r NAME INPUT_PATH CLASS_TIM; do
        # Skip the header row
        if [ "$NAME" = "NAME" ]; then
            continue
        fi

        # Step 1: Run FastQC on raw files
        module purge
        module load java
        module load fastqc
        echo "Running FASTQC on raw sample: $NAME"
        if [ ! -f "$INPUT_PATH" ]; then
            echo "Error: Input file $INPUT_PATH does not exist."
            exit 1
        fi
        fastqc -t 4 --noextract -o "$OUTPUT_DIR/fastqc_results" "$INPUT_PATH" || {
            echo "FASTQC failed for $NAME";
            exit 1;
        }

        # Use predefined adapters and UMI settings
        ADAPTER_5="ATCTACACGTTCAGAGTTCTACAGTCCGACGATC"
        ADAPTER_3="NNNTGGAATTCTCGGGTGCCAAGG"
        UMI="NNNNNNNNNN"
        UMI_LOC="5"  # Default location

        # Step 2: Trim adapters using Cutadapt
        module purge
        module load python/3.8.3
        echo "                                             "
        echo "                     d8                   888                       d8  "
        echo " e88~~\\ 888  888 _d88__   /~~~8e   e88~\\888   /~~~8e  888-~88e  _d88__"
        echo "d888    888  888  888         88b d888  888       88b 888  888b  888  "
        echo "8888    888  888  888    e88~-888 8888  888  e88~-888 888  8888  888  "
        echo "Y888    888  888  888   C888  888 Y888  888 C888  888 888  888P  888  "
        echo " \"88__/ \"88_-888  \"88_/  \"88_-888  \"88_/888  \"88_-888 888-_88\"   \"88_/  "
        echo "                                                      888              "

        echo "Trimming adapters for $NAME"
        CUTADAPT_OUTPUT="$OUTPUT_DIR/Step_01_Results/cutadapt/${NAME}_trimmed.fastq.gz"
        CUTADAPT_LOG="$OUTPUT_DIR/Step_01_Results/cutadapt/${NAME}_cutadapt.log"

        cutadapt -a "$ADAPTER_3" -g "$ADAPTER_5" --rc -j 4 -m 10 --nextseq-trim=20 \
            -o "$CUTADAPT_OUTPUT" "$INPUT_PATH" > "$CUTADAPT_LOG" 2>&1 || {
            echo "Cutadapt failed for $NAME";
            exit 1;
        }

        # Step 3: Extract UMI
        module purge
        module load python/3.8.3
        echo "                                                 "
        echo "  _   _ __  __ ___   _              _     "
        echo " | | | |  \/  |_ _| | |_ ___   ___ | |___ "
        echo " | | | | |\/| || |  | __/ _ \ / _ \| / __|"
        echo " | |_| | |  | || |  | || (_) | (_) | \__ \\"
        echo "  \___/|_|  |_|___|  \__\___/ \___/|_|___/"
        echo "Extracting UMI for $NAME"
        UMI_OUTPUT="$OUTPUT_DIR/Step_01_Results/umi_extract/${NAME}_umi_processed.fastq.gz"
        UMI_LOG="$OUTPUT_DIR/Step_01_Results/umi_extract/${NAME}_umi.log"

        umi_tools extract \
            -I "$CUTADAPT_OUTPUT" \
            --bc-pattern="$UMI" \
            -L "$UMI_LOG" \
            -S "$UMI_OUTPUT" || {
            echo "UMI extraction failed for $NAME";
            exit 1;
        }

        # Step 4: Run FastQC on processed files
        module purge
        module load java
        module load fastqc
        echo "Running FASTQC on processed sample: $NAME"
        fastqc -t 4 --noextract -o "$OUTPUT_DIR/Step_01_Results/processed_fastqc" "$UMI_OUTPUT" || {
            echo "FASTQC failed for processed $NAME";
            exit 1;
        }
    done < "$CONFIG_FILE"
else
    # Read full config file
    while IFS="," read -r NAME INPUT_PATH ADAPTER_5 UMI UMI_LOC ADAPTER_3 CLASS_TIM; do
        # Skip the header row
        if [ "$NAME" = "NAME" ]; then
            continue
        fi

        # Step 1: Run FastQC on raw files
        module purge
        module load java
        module load fastqc
        echo "Running FASTQC on raw sample: $NAME"
        if [ ! -f "$INPUT_PATH" ]; then
            echo "Error: Input file $INPUT_PATH does not exist."
            exit 1
        fi
        fastqc -t 4 --noextract -o "$OUTPUT_DIR/fastqc_results" "$INPUT_PATH" || {
            echo "FASTQC failed for $NAME";
            exit 1;
        }

        # Step 2: Trim adapters using Cutadapt
        module purge
        module load python/3.8.3
        echo "Trimming adapters for $NAME"
        CUTADAPT_OUTPUT="$OUTPUT_DIR/Step_01_Results/cutadapt/${NAME}_trimmed.fastq.gz"
        CUTADAPT_LOG="$OUTPUT_DIR/Step_01_Results/cutadapt/${NAME}_cutadapt.log"

        if [ "$UMI_LOC" = "3" ]; then
            UMI_OPTION="--3prime"
        else
            UMI_OPTION=""
        fi

        cutadapt -a "$ADAPTER_3" -g "$ADAPTER_5" $UMI_OPTION --rc -j 4 -m 10 --nextseq-trim=20 \
            -o "$CUTADAPT_OUTPUT" "$INPUT_PATH" > "$CUTADAPT_LOG" 2>&1 || {
            echo "Cutadapt failed for $NAME";
            exit 1;
        }

        # Step 3: Extract UMI
        echo "Extracting UMI for $NAME"
        UMI_OUTPUT="$OUTPUT_DIR/Step_01_Results/umi_extract/${NAME}_umi_processed.fastq.gz"
        UMI_LOG="$OUTPUT_DIR/Step_01_Results/umi_extract/${NAME}_umi.log"

        umi_tools extract \
            -I "$CUTADAPT_OUTPUT" \
            --bc-pattern="$UMI" \
            -L "$UMI_LOG" \
            -S "$UMI_OUTPUT" || {
            echo "UMI extraction failed for $NAME";
            exit 1;
        }

        # Step 4: Run FastQC on processed files
        module purge
        module load java
        module load fastqc
        echo "Running FASTQC on processed sample: $NAME"
        fastqc -t 4 --noextract -o "$OUTPUT_DIR/Step_01_Results/processed_fastqc" "$UMI_OUTPUT" || {
            echo "FASTQC failed for processed $NAME";
            exit 1;
        }
    done < "$CONFIG_FILE"
fi

# Step 5: Generate MultiQC reports
pip install multiqc
echo "Generating combined MultiQC report for all samples"
multiqc "$OUTPUT_DIR/fastqc_results" "$OUTPUT_DIR/Step_01_Results/processed_fastqc" -o "$OUTPUT_DIR/multiqc_results"

# Final combined report for processed samples
echo "Generating final combined MultiQC report for processed samples"
multiqc "$OUTPUT_DIR/Step_01_Results/processed_fastqc" -o "$OUTPUT_DIR/multiqc_results/processed_combined"

echo "Pipeline completed successfully."

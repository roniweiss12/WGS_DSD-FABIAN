# WGS_DSD-FABIAN

This repository contains a pipeline with the following steps:

1. Take a variants file
2. Split it so there won't be over 10k variants (FABIAN limitation)
3. Run it through FABIAN
4. Process the results into the original variants file.

Run with the command:
`nextflow run fabian_analysis.nf --csvFile path/to/variants.csv --curProcessedOutputDir results_dir`

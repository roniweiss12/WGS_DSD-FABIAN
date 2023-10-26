# WGS_DSD-FABIAN

This repository contains a pipeline that takes a variants file, splits it so there won't be over 10k variants (FABIAN limitation), runs it through FABIAN and processes the results into the original variants file.

Run with the command:
`nextflow run fabian_analysis.nf --csvFile path/to/variants.csv --curProcessedOutputDir results_dir`

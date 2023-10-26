# WGS_DSD-FABIAN

This repository contains a pipeline that inputs a variants.csv file and applies the following steps:

1. Split it so there won't be over 10k variants (FABIAN limitation).
   
2. Run it through FABIAN
   
3. Process the results into the original variants file.

Run with the command:

`nextflow run fabian_analysis.nf --csvFile path/to/variants.csv --curProcessedOutputDir results_dir`

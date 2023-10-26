# WGS_DSD-FABIAN

This repository contains a pipeline that inputs a variants.csv file and applies the following steps:

1. Split it so there won't be over 10k variants (FABIAN limitation).
   
2. Run it through FABIAN, against the following TF's: AR CBX3 DMRT1 DMRT3 ESR1 ESR2 FOXL1 GATA4 LHX9 NR5A1 RUNX1 SOX10 SOX8 SOX9 SRY WT1
   
3. Process the results into the original variants file.

The output file is the same variants.csv file with extra columns, one for each TF, that contain the average gain/loss of function score.

Run with the command:

`nextflow run fabian_analysis.nf --csvFile path/to/variants.csv --curProcessedOutputDir results_dir`

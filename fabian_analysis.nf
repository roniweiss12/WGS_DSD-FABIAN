#!/usr/bin/env nextflow

// Define input parameters
params.csvFile = ""
params.bin = "/home/stu/nitzang/WGS_DSD-FABIAN/bin"
params.curProcessedOutputDir = ""

process splitCsvAt10k {
    publishDir params.curProcessedOutputDir, mode: 'copy'

    input:
    file vars

    output:
    tuple file("first.csv"), file ("second.csv")

    script:
    """
    LINES=\$(cat ${vars} | wc -l)
    head -n 10000 ${vars} > first.csv
    head -n 1 ${vars} > second.csv
    sed -n '10001,\$p' < ${vars} >> second.csv
    """
}

process csvToVcf {
    publishDir params.curProcessedOutputDir, mode: 'copy', failOnError: true

   input:
    file csvFile
   
   output:
    tuple file("${csvFile}.vcf.gz"), file ("${csvFile}.vcf.gz.tbi")

    script:
    """
    for file in ${params.bin}*; do
        ln -s "\$file" .
    done
    csv_to_vcf_for_fabian.sh ${csvFile} bin/cols_info.csv ${csvFile}.vcf
    """
}


process runFabian {
    
    publishDir params.curProcessedOutputDir, mode: 'copy'

    input:
    tuple file(gzFile), file (tbiFile)

    output:
    file "fabian.data_*.zip"

    script:
    """
    runFab.sh ${gzFile}
    """
}

process addFabToVars {
    
    publishDir params.curProcessedOutputDir, mode: 'copy'

    input:
    file csvFile
    tuple file(firstFab), file(secondFab)

    output:
    file "fab_${csvFile}"

    script:
    """
    Rscript ${params.bin}/get_fabian_data.R ${csvFile} ${firstFab} ${secondFab}
    """
}
workflow {
    def vars = file(params.csvFile)
    def splitted = splitCsvAt10k(vars)
    def fabs = splitted.flatten() | csvToVcf | runFabian
    def fab_results = fabs.collect { it }
    addFabToVars(vars, fab_results)
}

//nextflow run fabian_analysis.nf --csvFile ../DSDncVariants/variants_pipeline/2023-10-23/qualityDSD_variants.csv --curProcessedOutputDir results26_10 -resume
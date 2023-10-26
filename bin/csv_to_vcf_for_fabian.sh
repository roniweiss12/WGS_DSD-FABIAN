#!/bin/bash

# Script: csv_to_vcf.sh
# Description: Converts the output of Roni's pipeline into a vcf file for showing in IGV browser
# Usage: bash csv_to_vcf.sh <csv_file> <col_info_file>  <output_file>
# Output : 
#           1) <output_file>.gz     - the vcf file
#           2) <output_file>.gz.tbi - index file for the vcf, need in order to see in igv browser 


csv_file=$1
col_info_file=$2
output=$3

python bin/csv_to_vcf_for_fabian.py $csv_file $col_info_file $output

bgzip -f $output
echo "Done bgzip"
tabix -p vcf "${output}.gz"
echo -e "Done! output can be found at \n\t ${output}.gz \n\t ${output}.gz.tbi"
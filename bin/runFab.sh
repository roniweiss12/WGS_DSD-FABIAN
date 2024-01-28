#!/bin/bash
# Script: runFab.sh
# Description: runs FABIAN command provided by FABIAN website and adjusted to our needs (vcf file, specific TF's)
# Usage: bash runFab.sh <vcf_file>
# Output : fabian.data_{FABIANID}.zip

vcf_file=$1

printf "($(date +%T)) Submitting " && \
FABIANID=$( curl -sLD - -o /dev/null \
-F "mode=vcf" \
-F "filename=@$vcf_file" \
-F "genome=hg38" \
-F "tfs_filter=names" \
-F "tfs_filter_names_tb=AR CBX3 DMRT1 DMRT3 ESR1 ESR2 FOXL1 GATA4 LEF1 LHX9 NR5A1 RUNX1 SOX10 SOX8 SOX9 SRY TCF3 TCF12 WT1 ASCL1 BCL6 MYOD1 NKX1-1 CEBPE" \
-F "models_filter=tffm_d" \
-F "models_filter=tffm_fo" \
-F "models_filter=pwm" \
-F "dbs_filter=jaspar2022" \
-F "dbs_filter=cisbp_1.02" \
-F "dbs_filter=HOCOMOCOv11" \
-F "dbs_filter=hPDI" \
-F "dbs_filter=jolma2013" \
-F "dbs_filter=SwissRegulon" \
-F "dbs_filter=UniPROBE" \
https://www.genecascade.org/fabian/analyse.cgi \
| grep -m 1 "Location: " | grep -o "\([0-9]\+_[0-9]\+\)" ) && \
i=1; until curl -sfo fabian.data_${FABIANID}.zip \
https://www.genecascade.org/temp/QE/FABIAN/${FABIANID}/fabian.data.zip; \
do printf "\r($(date +%T)) Waiting for $FABIANID"; \
[ $i == 30 ] && sleep $i || sleep $((i++)); done && \
printf "\r($(date +%T)) Saved file fabian.data_${FABIANID}.zip\n"
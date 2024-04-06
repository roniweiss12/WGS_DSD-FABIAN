#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
library(dplyr)
library(tidyr)
library(stringr)
library(utils)
library(openxlsx)
library(pheatmap)
library(RColorBrewer)

read_fabian <- function(zipped_fabian){
  temp_dir <- tempdir()
  unzip(zipped_fabian, exdir = temp_dir)
  df_path <- file.path(temp_dir, "fabian.data")
  fabian_file <- read.table(df_path, sep = '\t', header = F)
  return(fabian_file)
}

TF_COLS <- c("AR", "CBX3", "DMRT1", "DMRT3", "ESR1", "ESR2", "FOXL1",
"GATA4", "LHX9", "LEF1", "NR5A1", "RUNX1", "SOX10", "SOX8", "SOX9",
"SRY", "TCF3", "TCF12", "WT1", "ASCL1", "BCL6", "MYOD1", "NKX1.1", "CEBPE")

FIRST_COLUMNS <- c("CHROM", "POS", "REF",	"ALT",	"FILTER",	"AF",	"AF_popmax",
 	"GHid",	"GH_is_elite",	"GH_type", "geneHancer", "repeatsMasker",
  "DSDgenes_1mb", "DSDgenes_1.5mb", "distance_from_nearest_DSD_TSS",
  "INTERVAL_ID", "from", "to",	"length", "median_DP",	"median_GQ",
  "total_probands",	"sinclair_probands",	"AF_sinclair",	"ken_probands",
  "AF_ken",	"zangen_probands",	"AF_zangen",	"local_AF_overall",
  "stringent_AF",	"quality", "conservation", "AR", "CBX3", "DMRT1",
  "DMRT3", "ESR1", "ESR2", "FOXL1", "GATA4", "LHX9", "LEF1", "NR5A1", "RUNX1",
  "SOX10", "SOX8", "SOX9", "SRY", "TCF3", "TCF12", "WT1", "ASCL1", "BCL6",
  "MYOD1", "NKX1.1", "CEBPE", "max_tf_value")

vars_file <- args[1]
zipped_fabian1 <- args[2]
zipped_fabian2 <- args[3]

fab1 <- read_fabian(zipped_fabian1)
fab2 <- read_fabian(zipped_fabian2)
fabian_file <- rbind(fab1, fab2)

vars <- read.table(vars_file, sep = ",", header = TRUE)

dot_split <- strsplit(fabian_file$V1, ":")
fabian_file$CHROM <- lapply(dot_split, '[[', 1)

# Use gsub to extract the numbers at the beginning of each string
numbers_only <- gsub("^(\\d+).*", "\\1", lapply(dot_split, "[[", 2))

# Convert the extracted numbers to numeric if needed
fabian_file$POS <- as.numeric(numbers_only)

rest_of_string <- gsub("^(\\d+)(.*)", "\\2", lapply(dot_split, "[[", 2))
nucs <- strsplit(rest_of_string, ">")
fabian_file$REF <- lapply(nucs, "[[", 1)
alt <- lapply(nucs, "[[", 2)
alt <- unlist(alt)
alt <- strsplit(alt, "\\.")
fabian_file$ALT <- lapply(alt, "[[", 1)

fabian_file <- fabian_file %>%
  rename("tf" = "V2", "function" = "V13", "score" = "V14")

summary_data <- fabian_file %>%
  group_by(CHROM, POS, REF, ALT, tf) %>%
  summarize(meanScore = mean(score), .groups = "drop")

# Pivot the summary_data to wide format using spread
wide_summary_data <- summary_data %>%
  spread(tf, meanScore)

# Use lapply to apply unlist to each column
unlisted_data <- lapply(wide_summary_data, unlist)

# Convert the result to a data frame
unlisted_data <- as.data.frame(unlisted_data)
index_cols <- c("CHROM", "POS", "ALT", "REF")
# Join wide_summary_data to variants
vars <- left_join(vars, unlisted_data, by = index_cols)

vars <- vars %>%
  mutate(max_tf_value = apply(select(., one_of(TF_COLS)), MARGIN = 1, function(x) max(abs(x)))) %>%
  arrange(desc(max_tf_value))

# Reorder the columns
vars <- vars[, c(FIRST_COLUMNS, setdiff(names(vars), first_columns))]
write.csv(vars, paste0("fab_", vars_file), quote = FALSE, row.names = FALSE, na = "")
# Concatenate values in specified columns and set as index
vars$index <- do.call(paste, c(vars[index_cols], sep = "_"))
vars <- vars[, !names(vars) %in% index_cols]  # Remove original columns

# Set the concatenated column as the index
rownames(vars) <- vars$index
vars$index <- NULL  # Remove the concatenated column
TF_COLS <- c(TF_COLS, "max_tf_value")
# Select columns for the heatmap (excluding the Sample column)
heatmap_data <- vars[, TF_COLS]
heatmap_data[is.na(heatmap_data)] <- 0
heatmap_data <- round(heatmap_data, 2)

write.csv(heatmap_data, "heatmap_data.csv", quote = FALSE, row.names = TRUE, na = "")

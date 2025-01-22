#!/usr/bin/env Rscript

library(Matrix)

# Parse input arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 7) {
  stop("Usage: normalization.R <filtered_matrix_1> <filtered_matrix_2> <barcodes_1> <barcodes_2> <features_1> <features_2> <output_dir>")
}

# Assign arguments to variables
filtered_matrix_1 <- args[5]
filtered_matrix_2 <- args[6]
barcodes_1 <- args[1]
barcodes_2 <- args[2]
features_1 <- args[3]
features_2 <- args[4]
output_dir <- args[7]

# Ensure output directory exists
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Load filtered matrices
matrix_1 <- Matrix::readMM(filtered_matrix_1)
matrix_2 <- Matrix::readMM(filtered_matrix_2)

# Normalize matrices (log-transform and scaling)
normalize_matrix <- function(matrix) {
  normalized <- log1p(matrix / Matrix::colSums(matrix) * 1e6)
  return(normalized)
}

normalized_matrix_1 <- normalize_matrix(matrix_1)
normalized_matrix_2 <- normalize_matrix(matrix_2)

# Save normalized matrices
Matrix::writeMM(normalized_matrix_1, file.path(output_dir, "normalized_matrix_1.mtx"))
Matrix::writeMM(normalized_matrix_2, file.path(output_dir, "normalized_matrix_2.mtx"))

# Save barcodes and features for downstream analysis
#file.copy(barcodes_1, file.path(output_dir, "normalized_barcodes_1.csv"))
#file.copy(barcodes_2, file.path(output_dir, "normalized_barcodes_2.csv"))
#file.copy(features_1, file.path(output_dir, "normalized_features_1.csv"))
#file.copy(features_2, file.path(output_dir, "normalized_features_2.csv"))

message("Normalization completed.")

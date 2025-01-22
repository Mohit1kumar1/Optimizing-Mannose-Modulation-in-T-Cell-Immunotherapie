#!/usr/bin/env Rscript
# Load required libraries
library(Matrix)
library(dplyr)

# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 7) {  # Expecting 6 input files + 1 output directory
  stop("Usage: quality_control.R <barcodes_1.csv> <barcodes_2.csv> <features_1.csv> <features_2.csv> <matrix_1.mtx> <matrix_2.mtx> <output_directory>")
}

# Assign input arguments to variables
barcodes_file_1 <- args[1]
barcodes_file_2 <- args[2]
features_file_1 <- args[3]
features_file_2 <- args[4]
matrix_file_1 <- args[5]
matrix_file_2 <- args[6]
output_dir <- args[7]

# Ensure output directory exists
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Read input files
barcodes_1 <- read.csv(barcodes_file_1)
barcodes_2 <- read.csv(barcodes_file_2)
features_1 <- read.csv(features_file_1)
features_2 <- read.csv(features_file_2)
matrix_1 <- Matrix::readMM(matrix_file_1)
matrix_2 <- Matrix::readMM(matrix_file_2)

# Perform quality control (example thresholds)
valid_genes_1 <- which(Matrix::rowSums(matrix_1) > 10)
valid_cells_1 <- which(Matrix::colSums(matrix_1) > 200)

valid_genes_2 <- which(Matrix::rowSums(matrix_2) > 10)
valid_cells_2 <- which(Matrix::colSums(matrix_2) > 200)

filtered_matrix_1 <- matrix_1[valid_genes_1, valid_cells_1]
filtered_matrix_2 <- matrix_2[valid_genes_2, valid_cells_2]

filtered_barcodes_1 <- barcodes_1[valid_cells_1, ]
filtered_barcodes_2 <- barcodes_2[valid_cells_2, ]

filtered_features_1 <- features_1[valid_genes_1, ]
filtered_features_2 <- features_2[valid_genes_2, ]

# Save filtered results
write.csv(filtered_barcodes_1, file = file.path(output_dir, "filtered_barcodes_1.csv"), row.names = FALSE)
write.csv(filtered_barcodes_2, file = file.path(output_dir, "filtered_barcodes_2.csv"), row.names = FALSE)
write.csv(filtered_features_1, file = file.path(output_dir, "filtered_features_1.csv"), row.names = FALSE)
write.csv(filtered_features_2, file = file.path(output_dir, "filtered_features_2.csv"), row.names = FALSE)

Matrix::writeMM(filtered_matrix_1, file.path(output_dir, "filtered_matrix_1.mtx"))
Matrix::writeMM(filtered_matrix_2, file.path(output_dir, "filtered_matrix_2.mtx"))

message("Quality control completed for both datasets.")

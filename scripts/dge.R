#!/usr/bin/env Rscript


library(Matrix)
library(edgeR)
library(limma)

args <- commandArgs(trailingOnly = TRUE)
input_file_1 <- args[1]
input_file_2 <- args[2]
output_dir <- args[3]

if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Load matrices
normalized_matrix_1 <- Matrix::readMM(input_file_1)
normalized_matrix_2 <- Matrix::readMM(input_file_2)

# Debug dimensions
print(paste("Dimensions of Matrix 1:", paste(dim(normalized_matrix_1), collapse = " x ")))
print(paste("Dimensions of Matrix 2:", paste(dim(normalized_matrix_2), collapse = " x ")))

# Convert to matrix format if needed
normalized_matrix_1 <- as.matrix(normalized_matrix_1)
normalized_matrix_2 <- as.matrix(normalized_matrix_2)

# Ensure both matrices have row names
if (is.null(rownames(normalized_matrix_1))) {
  rownames(normalized_matrix_1) <- paste0("Gene_", seq_len(nrow(normalized_matrix_1)))
}
if (is.null(rownames(normalized_matrix_2))) {
  rownames(normalized_matrix_2) <- paste0("Gene_", seq_len(nrow(normalized_matrix_2)))
}

# Align rows based on gene names
common_rows <- intersect(rownames(normalized_matrix_1), rownames(normalized_matrix_2))
if (length(common_rows) == 0) stop("No common rows between matrices.")
normalized_matrix_1 <- normalized_matrix_1[common_rows, , drop = FALSE]
normalized_matrix_2 <- normalized_matrix_2[common_rows, , drop = FALSE]

# Combine data into a DGEList object
counts <- cbind(normalized_matrix_1, normalized_matrix_2)
group <- factor(c(rep("Treatment", ncol(normalized_matrix_1)), 
                  rep("Control", ncol(normalized_matrix_2))))
dge <- DGEList(counts = counts, group = group)

# Normalize counts
dge <- calcNormFactors(dge)

# Design matrix
design <- model.matrix(~group)

# Estimate dispersion
dge <- estimateDisp(dge, design)

# Fit the model and test for differential expression
fit <- glmQLFit(dge, design)
qlf <- glmQLFTest(fit, coef = 2)

# Extract top genes
top_genes <- topTags(qlf, n = Inf)$table

# Save results
write.csv(top_genes, file = file.path(output_dir, "dge_results.csv"))

message("Differential expression analysis completed.")

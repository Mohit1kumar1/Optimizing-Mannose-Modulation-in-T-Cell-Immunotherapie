#!/usr/bin/env Rscript

library(Matrix)
library(stats)
library(ggplot2)


# Assign arguments
normalized_matrix_1 <- args[1]
normalized_matrix_2 <- args[2]
output_dir <- args[3]

# Debug arguments
print(paste("Input file 1:", normalized_matrix_1))
print(paste("Input file 2:", normalized_matrix_2))
print(paste("Output directory:", output_dir))

# Check files and directories
if (!file.exists(normalized_matrix_1)) stop("File not found:", normalized_matrix_1)
if (!file.exists(normalized_matrix_2)) stop("File not found:", normalized_matrix_2)
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

process_dataset <- function(matrix_path, label) {
  print(paste("Processing dataset:", label))

  # Load matrix
  matrix <- tryCatch(Matrix::readMM(matrix_path),
                     error = function(e) stop("Error reading matrix:", e$message))

  print(paste("Loaded matrix dimensions:", dim(matrix)))
  
  # Debugging: Check rows/columns before cleanup
  print(paste("Rows before cleanup:", nrow(matrix)))
  print(paste("Columns before cleanup:", ncol(matrix)))

  # Remove rows/columns with zero sums or constant values
  matrix <- matrix[Matrix::rowSums(matrix) > 0, , drop = FALSE]
  matrix <- matrix[, Matrix::colSums(matrix) > 0, drop = FALSE]
  matrix <- matrix[, apply(as.matrix(matrix), 2, var) > 0, drop = FALSE]

  print(paste("Matrix dimensions after cleanup:", dim(matrix)))

  # Check if the matrix is too sparse after cleanup
  if (nrow(matrix) < 2 || ncol(matrix) < 2) {
    stop("Matrix is too sparse for PCA and clustering.")
  }

  # Perform PCA using irlba for sparse matrices
  library(irlba)
  pca_results <- irlba::prcomp_irlba(as.matrix(matrix), n = 50)
  print("PCA completed.")
  
  # Perform K-means clustering
  kmeans_results <- kmeans(pca_results$x, centers = 3)
  print("Clustering completed.")
  
  # Prepare and save output
  pca_data <- as.data.frame(pca_results$x)
  pca_data$Cluster <- as.factor(kmeans_results$cluster)
  
  write.csv(kmeans_results$cluster, file.path(output_dir, paste0("clusters_", label, ".csv")), row.names = TRUE)
  write.csv(pca_results$x, file.path(output_dir, paste0("pca_coordinates_", label, ".csv")), row.names = TRUE)
  
  # Plot PCA
  pca_plot <- ggplot(pca_data, aes(x = PC1, y = PC2, color = Cluster)) +
    geom_point(alpha = 0.7) +
    labs(title = paste("PCA and Clustering -", label)) +
    theme_minimal()
  ggsave(file.path(output_dir, paste0("pca_plot_", label, ".png")), pca_plot)
  
  print(paste("Processing completed for:", label))
}

# Process datasets
process_dataset(normalized_matrix_1, "GSM8036223")
process_dataset(normalized_matrix_2, "GSM8036224")

message("Clustering and PCA completed for both datasets.")

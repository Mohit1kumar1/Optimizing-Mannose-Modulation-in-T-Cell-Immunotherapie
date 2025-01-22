library(rhdf5)
library(Matrix)

# Part 1: Parse Arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) {  # Expecting 3 arguments (2 input files + 1 output directory)
  stop("Usage: extract_hdf5.R <input_hdf5_file_1> <input_hdf5_file_2> <output_directory>")
}
input_file_1 <- args[1]
input_file_2 <- args[2]
output_dir <- args[3]

# Part 2: Validate Input Files and Output Directory
if (!file.exists(input_file_1)) stop(paste("Input file does not exist:", input_file_1))
if (!file.exists(input_file_2)) stop(paste("Input file does not exist:", input_file_2))
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Part 3: Display HDF5 File Structures for Debugging
h5_structure_1 <- h5ls(input_file_1)
h5_structure_2 <- h5ls(input_file_2)
message("HDF5 structure for input file 1:")
print(h5_structure_1)
message("HDF5 structure for input file 2:")
print(h5_structure_2)

# Part 4: Extract Barcodes
barcodes_1 <- h5read(input_file_1, "/matrix/barcodes")
barcodes_2 <- h5read(input_file_2, "/matrix/barcodes")
write.csv(barcodes_1, file = file.path(output_dir, "barcodes_1.csv"), row.names = FALSE)
write.csv(barcodes_2, file = file.path(output_dir, "barcodes_2.csv"), row.names = FALSE)
message("Barcodes extracted and saved.")

# Part 5: Extract Features
features_1 <- h5read(input_file_1, "/matrix/features/id")
features_2 <- h5read(input_file_2, "/matrix/features/id")
write.csv(features_1, file = file.path(output_dir, "features_1.csv"), row.names = FALSE)
write.csv(features_2, file = file.path(output_dir, "features_2.csv"), row.names = FALSE)
message("Features extracted and saved.")

# Part 6: Extract and Save Sparse Matrix Data
data_1 <- h5read(input_file_1, "/matrix/data")
indices_1 <- h5read(input_file_1, "/matrix/indices")
indptr_1 <- h5read(input_file_1, "/matrix/indptr")
shape_1 <- h5read(input_file_1, "/matrix/shape")

data_2 <- h5read(input_file_2, "/matrix/data")
indices_2 <- h5read(input_file_2, "/matrix/indices")
indptr_2 <- h5read(input_file_2, "/matrix/indptr")
shape_2 <- h5read(input_file_2, "/matrix/shape")

# Convert and Save as Sparse Matrices
sparse_matrix_1 <- sparseMatrix(
  i = indices_1 + 1,  # Convert 0-based indices to 1-based
  p = indptr_1,
  x = data_1,
  dims = shape_1
)
sparse_matrix_2 <- sparseMatrix(
  i = indices_2 + 1,  # Convert 0-based indices to 1-based
  p = indptr_2,
  x = data_2,
  dims = shape_2
)
Matrix::writeMM(sparse_matrix_1, file.path(output_dir, "matrix_1.mtx"))
Matrix::writeMM(sparse_matrix_2, file.path(output_dir, "matrix_2.mtx"))
message("Sparse matrices saved.")

message("HDF5 data extraction completed successfully.")

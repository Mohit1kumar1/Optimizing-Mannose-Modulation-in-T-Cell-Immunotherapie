#!/usr/bin/env Rscript

library(clusterProfiler)
library(org.Mm.eg.db)  # For mouse, use org.Hs.eg.db for human
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
dge_file <- args[1]
output_dir <- args[2]

if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Load DGE results
dge_results <- read.csv(dge_file)

# Select significant genes
significant_genes <- dge_results[dge_results$adj.P.Val < 0.05, "Gene"]

# Convert gene symbols to Entrez IDs





# {["""to use org.Mm.eg.db, correct reference file is required for the organism"""]}






#entrez_ids <- bitr(significant_genes, fromType = "SYMBOL", toType = "ENTREZID", OrgDb = org.Mm.eg.db)

# Perform KEGG pathway enrichment analysis
#kegg_results <- enrichKEGG(gene = entrez_ids$ENTREZID, organism = "mmu")

# Save results
#write.csv(as.data.frame(kegg_results), file = file.path(output_dir, "kegg_results.csv"))

# Generate enrichment plot
#top_kegg <- head(kegg_results, 10)
#ggplot(top_kegg, aes(x = reorder(Description, -pvalue), y = -log10(pvalue))) +
 #   geom_bar(stat = "identity", fill = "steelblue") +
  #  coord_flip() +
   # xlab("KEGG Pathways") +
#    ylab("-log10(p-value)") +
 #   theme_minimal() +
  #  ggtitle("Top 10 KEGG Pathways Enriched") +
   # theme(axis.text = element_text(size = 10), axis.title = element_text(size = 12))

# Save the plot
#ggsave(file.path(output_dir, "kegg_enrichment_plot.png"))

#message("Pathway analysis and plotting completed.")

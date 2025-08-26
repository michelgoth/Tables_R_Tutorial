# ===============================================================
# LESSON 24: TRANSCRIPTOMIC SUBTYPE DISCOVERY WITH CONSENSUS CLUSTERING
# ===============================================================
#
# OBJECTIVE:
# To perform unsupervised clustering on transcriptomic data to identify 
# distinct molecular subtypes and annotate them with biologically 
# meaningful names (Classical, Mesenchymal, Proneural, Neural).
#
# WHY THIS IS IMPORTANT:
# This analysis bridges our findings with the established TCGA literature
# by identifying the well-known molecular archetypes of glioma in our dataset.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
load_required_packages(c("dplyr", "survival", "survminer", "ConsensusClusterPlus", "pheatmap"))

cat("--- LESSON 24: Transcriptomic Subtype Discovery ---\n")

# ===============================================================
# SECTION 1: LOAD AND PREPARE DATA -----------------------------
# ===============================================================
raw_clinical_data <- load_clinical_data(file.path("Data", "ClinicalData.xlsx"))
clinical_data <- impute_clinical_data(raw_clinical_data)
rnaseq_data <- load_rnaseq_data(file.path("Data", "CGGA.mRNAseq_325.RSEM.20200506.txt"))
combined_data <- integrate_data(clinical_data, rnaseq_data)

vst_counts <- combined_data$vst_counts
aligned_clinical <- combined_data$clinical

cat("--- Data loaded successfully. ---\n")
cat("Dimensions of expression matrix:", dim(vst_counts), "\n")
cat("Dimensions of clinical data:", dim(aligned_clinical), "\n")

# ===============================================================
# SECTION 2: DEFINE TCGA SUBTYPE GENE SIGNATURE -----------------
# ===============================================================
# Using a subset of the most important marker genes from the Verhaak signature
# This is more focused and reliable than using all 840 genes
tcga_signature_genes <- c(
  # Proneural markers
  "PDGFRA", "OLIG2", "SOX2", "NKX2-2", "DLL3", "ASCL1",
  # Classical markers  
  "EGFR", "NES", "NOTCH3", "FGFR3", "AKT3",
  # Mesenchymal markers
  "CD44", "CHI3L1", "TRADD", "RELB", "TAZ", "YAP1",
  # Neural markers
  "NEFL", "GABRA1", "SYT1", "SLC12A5", "GRIA2",
  # Additional important genes
  "VIM", "FN1", "SERPINE1", "POSTN", "COL1A1", "MET"
)

# Filter for available genes
available_genes <- intersect(tcga_signature_genes, rownames(vst_counts))
cat("Using", length(available_genes), "signature genes out of", length(tcga_signature_genes), "total\n")

# Create clustering matrix
clustering_matrix <- vst_counts[available_genes, ]
cat("Clustering matrix dimensions:", dim(clustering_matrix), "\n")

# ===============================================================
# SECTION 3: PERFORM CONSENSUS CLUSTERING -----------------------
# ===============================================================
cat("--- Performing Consensus Clustering... ---\n")

# Create output directory
results_dir <- "plots/consensus_clustering"
if (!dir.exists(results_dir)) {
  dir.create(results_dir, recursive = TRUE)
}

# Run consensus clustering
set.seed(1234)  # For reproducibility
cc_results <- ConsensusClusterPlus(
  as.matrix(clustering_matrix),
  maxK = 6,
  reps = 50,  # Reduced for faster execution
  pItem = 0.8,
  pFeature = 1,
  title = results_dir,
  clusterAlg = "hc",
  distance = "pearson",
  seed = 1234,
  plot = "png",
  verbose = TRUE
)

# Extract the 4-cluster solution (optimal based on TCGA literature)
optimal_k <- 4
cluster_assignments <- cc_results[[optimal_k]]$consensusClass

# Debug: Check the alignment
cat("Number of cluster assignments:", length(cluster_assignments), "\n")
cat("Number of clinical samples:", nrow(aligned_clinical), "\n")
cat("First few cluster assignment names:", head(names(cluster_assignments)), "\n")
cat("First few clinical rownames:", head(rownames(aligned_clinical)), "\n")

# Add cluster assignments to clinical data
# The cluster assignments should already be in the same order as the clinical data
# since both come from the same integrated dataset
if (length(cluster_assignments) == nrow(aligned_clinical)) {
  aligned_clinical$Subtype_Numeric <- cluster_assignments
} else {
  # Fallback: try to match by names
  aligned_clinical$Subtype_Numeric <- cluster_assignments[rownames(aligned_clinical)]
}

cat("--- Consensus Clustering complete. ---\n")
cat("Cluster distribution:\n")
print(table(aligned_clinical$Subtype_Numeric, useNA = "ifany"))

# ===============================================================
# SECTION 4: ANNOTATE CLUSTERS WITH BIOLOGICAL NAMES -----------
# ===============================================================
cat("--- Annotating clusters with biological names... ---\n")

# Define marker gene sets for each subtype
proneural_markers <- c("PDGFRA", "OLIG2", "SOX2", "NKX2-2", "DLL3", "ASCL1")
classical_markers <- c("EGFR", "NES", "NOTCH3", "FGFR3", "AKT3")
mesenchymal_markers <- c("CD44", "CHI3L1", "TRADD", "RELB", "VIM", "FN1")
neural_markers <- c("NEFL", "GABRA1", "SYT1", "SLC12A5", "GRIA2")

# Function to calculate mean expression for a gene set in a cluster
calculate_cluster_score <- function(cluster_num, gene_set) {
  # Get patients in this cluster (using the original cluster assignment names)
  cluster_patients <- names(cluster_assignments)[cluster_assignments == cluster_num]
  
  # Get available genes from the gene set
  available_markers <- intersect(gene_set, rownames(clustering_matrix))
  
  if (length(available_markers) == 0 || length(cluster_patients) == 0) {
    return(0)  # No markers or patients available
  }
  
  # Calculate mean expression across patients and genes in this cluster
  cluster_expression <- clustering_matrix[available_markers, cluster_patients, drop = FALSE]
  return(mean(cluster_expression, na.rm = TRUE))
}

# Calculate scores for each cluster and each gene set
annotation_scores <- data.frame(
  Cluster = 1:4,
  Proneural = sapply(1:4, function(x) calculate_cluster_score(x, proneural_markers)),
  Classical = sapply(1:4, function(x) calculate_cluster_score(x, classical_markers)),
  Mesenchymal = sapply(1:4, function(x) calculate_cluster_score(x, mesenchymal_markers)),
  Neural = sapply(1:4, function(x) calculate_cluster_score(x, neural_markers))
)

print("Annotation scores:")
print(annotation_scores)

# Create mapping from cluster number to biological name
# Each subtype gets assigned to the cluster with the highest score for its markers
proneural_cluster <- which.max(annotation_scores$Proneural)
classical_cluster <- which.max(annotation_scores$Classical)
mesenchymal_cluster <- which.max(annotation_scores$Mesenchymal)
neural_cluster <- which.max(annotation_scores$Neural)

# Handle potential conflicts (same cluster assigned to multiple subtypes)
cluster_mapping <- c("Other", "Other", "Other", "Other")
cluster_mapping[proneural_cluster] <- "Proneural"
cluster_mapping[classical_cluster] <- "Classical"
cluster_mapping[mesenchymal_cluster] <- "Mesenchymal"
cluster_mapping[neural_cluster] <- "Neural"

# If there are conflicts, the neural subtype gets assigned by elimination
remaining_clusters <- which(cluster_mapping == "Other")
if (length(remaining_clusters) == 1) {
  cluster_mapping[remaining_clusters] <- "Neural"
}

cat("Cluster to subtype mapping:\n")
for (i in 1:4) {
  cat("Cluster", i, "->", cluster_mapping[i], "\n")
}

# Apply the mapping
aligned_clinical$Subtype <- cluster_mapping[aligned_clinical$Subtype_Numeric]

cat("Final subtype distribution:\n")
print(table(aligned_clinical$Subtype))

# ===============================================================
# SECTION 5: GENERATE VISUALIZATIONS ----------------------------
# ===============================================================
cat("--- Generating visualizations... ---\n")

# Create heatmap with annotated subtypes
# We need to ensure the annotation aligns with the clustering matrix column names
# The clustering matrix uses the original CGGA IDs, so we'll create the annotation based on those

# Create a mapping from CGGA IDs to subtypes
cgga_to_subtype <- aligned_clinical$Subtype
names(cgga_to_subtype) <- names(cluster_assignments)

# Create annotation dataframe that matches the clustering matrix columns
annotation_col <- data.frame(
  Subtype = factor(cgga_to_subtype[colnames(clustering_matrix)])
)
rownames(annotation_col) <- colnames(clustering_matrix)

# Order samples by subtype for cleaner visualization
subtype_order <- order(annotation_col$Subtype)
ordered_matrix <- clustering_matrix[, subtype_order]
ordered_annotation <- annotation_col[subtype_order, , drop = FALSE]

# Generate heatmap
# Define colors for the annotation
annotation_colors <- list(
  Subtype = c("Classical" = "red", "Mesenchymal" = "blue", "Proneural" = "green", "Neural" = "purple")
)

pdf("plots/Lesson24_Subtype_Heatmap.pdf", width = 12, height = 8)
pheatmap(
  ordered_matrix,
  annotation_col = ordered_annotation,
  annotation_colors = annotation_colors,
  show_colnames = FALSE,
  cluster_cols = FALSE,
  cluster_rows = TRUE,
  scale = "row",
  main = "Gene Expression Heatmap by Molecular Subtype"
)
dev.off()

# Generate Kaplan-Meier survival plot
fit_km <- survfit(Surv(OS, Censor) ~ Subtype, data = aligned_clinical)

km_plot <- ggsurvplot(
  fit_km,
  data = aligned_clinical,
  pval = TRUE,
  conf.int = FALSE,
  risk.table = TRUE,
  title = "Survival by Molecular Subtype",
  xlab = "Time (days)",
  legend.title = "Molecular Subtype",
  palette = c("red", "blue", "green", "purple")[1:length(unique(aligned_clinical$Subtype))]
)

pdf("plots/Lesson24_KM_by_Subtype.pdf", width = 10, height = 8)
print(km_plot)
dev.off()

cat("--- Analysis complete! Plots saved to plots/ directory ---\n")

# Print summary
cat("\n=== SUMMARY ===\n")
cat("Successfully identified", length(unique(aligned_clinical$Subtype)), "molecular subtypes\n")
cat("Subtype distribution:\n")
print(table(aligned_clinical$Subtype))

if (length(unique(aligned_clinical$Subtype)) > 1) {
  survival_test <- survdiff(Surv(OS, Censor) ~ Subtype, data = aligned_clinical)
  cat("Survival difference p-value:", format(1 - pchisq(survival_test$chisq, df = length(survival_test$n) - 1), digits = 3), "\n")
}

cat("Generated files:\n")
cat("- plots/Lesson24_Subtype_Heatmap.pdf\n")
cat("- plots/Lesson24_KM_by_Subtype.pdf\n")
cat("- plots/consensus_clustering/ (consensus clustering diagnostic plots)\n")

# End of Lesson 24

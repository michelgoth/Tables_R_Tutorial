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
load_required_packages(c("dplyr", "survival", "survminer", "ConsensusClusterPlus", "pheatmap", 
                         "DESeq2", "clusterProfiler", "enrichplot", "ggplot2"))

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

# ===============================================================
# SECTION 6: DIFFERENTIAL EXPRESSION ANALYSIS FOR EACH SUBTYPE
# ===============================================================
cat("--- Performing differential expression analysis for each subtype... ---\n")

# Use the full expression data for differential expression, not just the 28 signature genes
full_expression <- vst_counts

# Function to perform differential expression for one subtype vs all others
perform_de_analysis <- function(subtype_name, expression_data, clinical_data) {
  cat("Analyzing", subtype_name, "vs others...\n")
  
  # Create binary comparison: target subtype vs all others
  clinical_data$comparison_group <- ifelse(clinical_data$Subtype == subtype_name, 
                                          subtype_name, "Others")
  clinical_data$comparison_group <- factor(clinical_data$comparison_group, 
                                          levels = c("Others", subtype_name))
  
  # Convert VST data back to counts for DESeq2 (approximately)
  # Since we have VST data, we'll use a different approach with limma-style analysis
  library(limma)
  
  # Create design matrix
  design <- model.matrix(~ comparison_group, data = clinical_data)
  
  # Fit linear model
  fit <- lmFit(expression_data, design)
  fit <- eBayes(fit)
  
  # Extract results
  results <- topTable(fit, coef = paste0("comparison_group", subtype_name), 
                     number = Inf, sort.by = "P")
  
  # Add gene symbols (assuming rownames are gene symbols)
  results$gene <- rownames(results)
  
  # Calculate -log10(p-value) for volcano plot
  results$neg_log10_pval <- -log10(results$P.Value)
  
  # Add significance labels
  results$significance <- "Not Significant"
  results$significance[results$adj.P.Val < 0.05 & results$logFC > 1] <- "Up in Target"
  results$significance[results$adj.P.Val < 0.05 & results$logFC < -1] <- "Down in Target"
  
  return(results)
}

# Install limma if not available
if (!require(limma, quietly = TRUE)) {
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  BiocManager::install("limma")
  library(limma)
}

# Perform DE analysis for each subtype
subtype_names <- unique(aligned_clinical$Subtype)
subtype_names <- subtype_names[!is.na(subtype_names)]

de_results_list <- list()
for (subtype in subtype_names) {
  if (sum(aligned_clinical$Subtype == subtype, na.rm = TRUE) >= 5) {  # Only analyze if >= 5 samples
    de_results_list[[subtype]] <- perform_de_analysis(subtype, full_expression, aligned_clinical)
  }
}

# ===============================================================
# SECTION 7: GENERATE VOLCANO PLOTS FOR EACH SUBTYPE ----------
# ===============================================================
cat("--- Generating volcano plots for each subtype... ---\n")

# Function to create volcano plot
create_volcano_plot <- function(de_results, subtype_name) {
  # Filter out genes with very low expression or extreme values
  de_results <- de_results[is.finite(de_results$neg_log10_pval) & 
                          de_results$neg_log10_pval < 50, ]
  
  # Create volcano plot
  p <- ggplot(de_results, aes(x = logFC, y = neg_log10_pval, color = significance)) +
    geom_point(alpha = 0.6, size = 0.8) +
    scale_color_manual(values = c("Up in Target" = "red", 
                                 "Down in Target" = "blue", 
                                 "Not Significant" = "grey70")) +
    geom_hline(yintercept = -log10(0.05), linetype = "dashed", alpha = 0.7) +
    geom_vline(xintercept = c(-1, 1), linetype = "dashed", alpha = 0.7) +
    labs(title = paste("Differential Expression:", subtype_name, "vs Others"),
         x = "Log2 Fold Change",
         y = "-Log10(P-value)",
         color = "Significance") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, size = 14),
          legend.position = "bottom")
  
  # Add labels for top genes
  top_up <- de_results[de_results$significance == "Up in Target", ][1:5, ]
  top_down <- de_results[de_results$significance == "Down in Target", ][1:5, ]
  top_genes <- rbind(top_up, top_down)
  top_genes <- top_genes[!is.na(top_genes$gene), ]
  
  if (nrow(top_genes) > 0) {
    p <- p + geom_text_repel(data = top_genes, 
                            aes(label = gene), 
                            size = 3, 
                            max.overlaps = 10,
                            show.legend = FALSE)
  }
  
  return(p)
}

# Load ggrepel for gene labels
if (!require(ggrepel, quietly = TRUE)) {
  install.packages("ggrepel")
  library(ggrepel)
}

# Generate volcano plots for each subtype
for (subtype in names(de_results_list)) {
  volcano_plot <- create_volcano_plot(de_results_list[[subtype]], subtype)
  
  # Save plot
  filename <- paste0("Lesson24_Volcano_", gsub("[^A-Za-z0-9]", "_", subtype))
  save_plot_both(volcano_plot, filename, width = 10, height = 8)
  
  cat("Saved volcano plot for", subtype, "\n")
}

# ===============================================================
# SECTION 8: GSEA ANALYSIS FOR EACH SUBTYPE -------------------
# ===============================================================
cat("--- Performing GSEA analysis for each subtype... ---\n")

# Function to perform GSEA for a subtype
perform_gsea_analysis <- function(de_results, subtype_name) {
  cat("GSEA for", subtype_name, "...\n")
  
  # Prepare gene list for GSEA (ranked by log fold change)
  gene_list <- de_results$logFC
  names(gene_list) <- de_results$gene
  gene_list <- sort(gene_list, decreasing = TRUE)
  
  # Remove duplicates and NA values
  gene_list <- gene_list[!duplicated(names(gene_list))]
  gene_list <- gene_list[!is.na(names(gene_list)) & !is.na(gene_list)]
  
  tryCatch({
    # Perform GSEA using Hallmark gene sets
    gsea_results <- gseGO(geneList = gene_list,
                         OrgDb = org.Hs.eg.db::org.Hs.eg.db,
                         keyType = "SYMBOL",
                         ont = "BP",  # Biological Process
                         minGSSize = 15,
                         maxGSSize = 500,
                         pvalueCutoff = 0.05,
                         verbose = FALSE)
    
    return(gsea_results)
  }, error = function(e) {
    cat("Error in GSEA for", subtype_name, ":", e$message, "\n")
    return(NULL)
  })
}

# Load required packages for GSEA
if (!require(org.Hs.eg.db, quietly = TRUE)) {
  BiocManager::install("org.Hs.eg.db")
  library(org.Hs.eg.db)
}

# Perform GSEA for each subtype
gsea_results_list <- list()
for (subtype in names(de_results_list)) {
  gsea_results_list[[subtype]] <- perform_gsea_analysis(de_results_list[[subtype]], subtype)
}

# ===============================================================
# SECTION 9: VISUALIZE GSEA RESULTS ----------------------------
# ===============================================================
cat("--- Generating GSEA visualization plots... ---\n")

# Generate GSEA plots for each subtype
for (subtype in names(gsea_results_list)) {
  gsea_result <- gsea_results_list[[subtype]]
  
  if (!is.null(gsea_result) && nrow(gsea_result) > 0) {
    # Create dot plot showing top enriched pathways
    dot_plot <- dotplot(gsea_result, showCategory = 10, 
                       title = paste("GSEA Results:", subtype, "vs Others"),
                       font.size = 8) +
      theme(plot.title = element_text(hjust = 0.5))
    
    # Save dot plot
    filename <- paste0("Lesson24_GSEA_Dotplot_", gsub("[^A-Za-z0-9]", "_", subtype))
    save_plot_both(dot_plot, filename, width = 12, height = 8)
    
    # Create enrichment plot for top pathway if available
    if (nrow(gsea_result) > 0) {
      top_pathway <- gsea_result@result$ID[1]
      
      tryCatch({
        enrich_plot <- gseaplot2(gsea_result, geneSetID = top_pathway,
                               title = paste("Top Enriched Pathway -", subtype))
        
        filename <- paste0("Lesson24_GSEA_Enrichment_", gsub("[^A-Za-z0-9]", "_", subtype))
        save_plot_both(enrich_plot, filename, width = 10, height = 6)
      }, error = function(e) {
        cat("Could not create enrichment plot for", subtype, "\n")
      })
    }
    
    cat("Generated GSEA plots for", subtype, "\n")
  } else {
    cat("No significant GSEA results for", subtype, "\n")
  }
}

# ===============================================================
# SECTION 10: SUMMARY OF DIFFERENTIAL EXPRESSION AND GSEA -----
# ===============================================================
cat("\n=== DIFFERENTIAL EXPRESSION AND GSEA SUMMARY ===\n")

for (subtype in names(de_results_list)) {
  cat("\n", subtype, "Subtype:\n")
  
  # DE summary
  de_result <- de_results_list[[subtype]]
  n_up <- sum(de_result$significance == "Up in Target", na.rm = TRUE)
  n_down <- sum(de_result$significance == "Down in Target", na.rm = TRUE)
  cat("  - Upregulated genes:", n_up, "\n")
  cat("  - Downregulated genes:", n_down, "\n")
  
  # GSEA summary
  gsea_result <- gsea_results_list[[subtype]]
  if (!is.null(gsea_result) && nrow(gsea_result) > 0) {
    cat("  - Enriched pathways:", nrow(gsea_result), "\n")
    if (nrow(gsea_result) > 0) {
      cat("  - Top pathway:", gsea_result@result$Description[1], "\n")
    }
  } else {
    cat("  - No significant pathway enrichment\n")
  }
}

cat("\nGenerated files:\n")
cat("- plots/Lesson24_Subtype_Heatmap.pdf\n")
cat("- plots/Lesson24_KM_by_Subtype.pdf\n")
cat("- plots/consensus_clustering/ (consensus clustering diagnostic plots)\n")

# List volcano plots
for (subtype in names(de_results_list)) {
  filename <- paste0("Lesson24_Volcano_", gsub("[^A-Za-z0-9]", "_", subtype))
  cat("- plots/", filename, ".pdf\n", sep = "")
}

# List GSEA plots
for (subtype in names(gsea_results_list)) {
  if (!is.null(gsea_results_list[[subtype]]) && nrow(gsea_results_list[[subtype]]) > 0) {
    filename1 <- paste0("Lesson24_GSEA_Dotplot_", gsub("[^A-Za-z0-9]", "_", subtype))
    filename2 <- paste0("Lesson24_GSEA_Enrichment_", gsub("[^A-Za-z0-9]", "_", subtype))
    cat("- plots/", filename1, ".pdf\n", sep = "")
    cat("- plots/", filename2, ".pdf\n", sep = "")
  }
}

# End of Lesson 24

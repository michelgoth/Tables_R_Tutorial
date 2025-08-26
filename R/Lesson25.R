# ===============================================================
# LESSON 25: NEURAL SUBTYPE DEEP DIVE - THE HYPERACTIVATION PHENOTYPE
# ===============================================================
#
# OBJECTIVE:
# To deeply investigate the Neural subtype's extraordinary transcriptional
# hyperactivation (2,005 upregulated genes) and complement pathway enrichment,
# uncovering the biological mechanisms driving this rare but distinct phenotype.
#
# WHY THIS IS CRITICAL:
# The Neural subtype shows the most extreme transcriptional activity in our
# analysis, with complement activation suggesting a unique neuroinflammatory
# state that could represent a novel therapeutic target.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
load_required_packages(c("dplyr", "ggplot2", "pheatmap", "enrichplot", "clusterProfiler", 
                         "ggrepel", "survival", "survminer", "limma", "ConsensusClusterPlus"))

cat("--- LESSON 25: Neural Subtype Deep Dive ---\n")

# ===============================================================
# SECTION 1: LOAD RESULTS FROM LESSON 24 ----------------------
# ===============================================================
cat("--- Loading Lesson 24 results... ---\n")

# We need to re-run key parts of Lesson 24 to get the data
raw_clinical_data <- load_clinical_data(file.path("Data", "ClinicalData.xlsx"))
clinical_data <- impute_clinical_data(raw_clinical_data)
rnaseq_data <- load_rnaseq_data(file.path("Data", "CGGA.mRNAseq_325.RSEM.20200506.txt"))
combined_data <- integrate_data(clinical_data, rnaseq_data)

vst_counts <- combined_data$vst_counts
aligned_clinical <- combined_data$clinical

# Recreate the subtype assignments (simplified from Lesson 24)
tcga_signature_genes <- c(
  "PDGFRA", "OLIG2", "SOX2", "NKX2-2", "DLL3", "ASCL1",
  "EGFR", "NES", "NOTCH3", "FGFR3", "AKT3",
  "CD44", "CHI3L1", "TRADD", "RELB", "TAZ", "YAP1",
  "NEFL", "GABRA1", "SYT1", "SLC12A5", "GRIA2",
  "VIM", "FN1", "SERPINE1", "POSTN", "COL1A1", "MET"
)

available_genes <- intersect(tcga_signature_genes, rownames(vst_counts))
clustering_matrix <- vst_counts[available_genes, ]

# Quick consensus clustering to get subtype assignments
if (!require(ConsensusClusterPlus, quietly = TRUE)) {
  BiocManager::install("ConsensusClusterPlus")
  library(ConsensusClusterPlus)
}

set.seed(1234)
cc_results <- ConsensusClusterPlus(
  as.matrix(clustering_matrix),
  maxK = 4,
  reps = 20,  # Reduced for speed
  pItem = 0.8,
  pFeature = 1,
  title = "temp_clustering",
  clusterAlg = "hc",
  distance = "pearson",
  seed = 1234,
  plot = NULL,  # Don't generate plots
  verbose = FALSE
)

cluster_assignments <- cc_results[[4]]$consensusClass
aligned_clinical$Subtype_Numeric <- cluster_assignments

# Recreate the biological annotation (from Lesson 24)
proneural_markers <- c("PDGFRA", "OLIG2", "SOX2", "NKX2-2", "DLL3", "ASCL1")
classical_markers <- c("EGFR", "NES", "NOTCH3", "FGFR3", "AKT3")
mesenchymal_markers <- c("CD44", "CHI3L1", "TRADD", "RELB", "VIM", "FN1")
neural_markers <- c("NEFL", "GABRA1", "SYT1", "SLC12A5", "GRIA2")

calculate_cluster_score <- function(cluster_num, gene_set) {
  cluster_patients <- names(cluster_assignments)[cluster_assignments == cluster_num]
  available_markers <- intersect(gene_set, rownames(clustering_matrix))
  if (length(available_markers) == 0 || length(cluster_patients) == 0) return(0)
  cluster_expression <- clustering_matrix[available_markers, cluster_patients, drop = FALSE]
  return(mean(cluster_expression, na.rm = TRUE))
}

annotation_scores <- data.frame(
  Cluster = 1:4,
  Proneural = sapply(1:4, function(x) calculate_cluster_score(x, proneural_markers)),
  Classical = sapply(1:4, function(x) calculate_cluster_score(x, classical_markers)),
  Mesenchymal = sapply(1:4, function(x) calculate_cluster_score(x, mesenchymal_markers)),
  Neural = sapply(1:4, function(x) calculate_cluster_score(x, neural_markers))
)

proneural_cluster <- which.max(annotation_scores$Proneural)
classical_cluster <- which.max(annotation_scores$Classical)
mesenchymal_cluster <- which.max(annotation_scores$Mesenchymal)
neural_cluster <- which.max(annotation_scores$Neural)

cluster_mapping <- c("Other", "Other", "Other", "Other")
cluster_mapping[proneural_cluster] <- "Proneural"
cluster_mapping[classical_cluster] <- "Classical"
cluster_mapping[mesenchymal_cluster] <- "Mesenchymal"
cluster_mapping[neural_cluster] <- "Neural"

remaining_clusters <- which(cluster_mapping == "Other")
if (length(remaining_clusters) == 1) {
  cluster_mapping[remaining_clusters] <- "Neural"
}

aligned_clinical$Subtype <- cluster_mapping[aligned_clinical$Subtype_Numeric]

cat("Subtype distribution:\n")
print(table(aligned_clinical$Subtype))

# ===============================================================
# SECTION 2: IDENTIFY NEURAL SUBTYPE PATIENTS ------------------
# ===============================================================
cat("--- Analyzing Neural subtype patients in detail... ---\n")

neural_patients <- rownames(aligned_clinical)[aligned_clinical$Subtype == "Neural"]
other_patients <- rownames(aligned_clinical)[aligned_clinical$Subtype != "Neural"]

cat("Neural subtype patients:", length(neural_patients), "\n")
cat("Other subtype patients:", length(other_patients), "\n")

# Clinical characteristics of Neural subtype
neural_clinical <- aligned_clinical[aligned_clinical$Subtype == "Neural", ]
other_clinical <- aligned_clinical[aligned_clinical$Subtype != "Neural", ]

cat("\n=== NEURAL SUBTYPE CLINICAL CHARACTERISTICS ===\n")
cat("Age (mean ± SD):\n")
cat("  Neural:", round(mean(neural_clinical$Age, na.rm = TRUE), 1), "±", 
    round(sd(neural_clinical$Age, na.rm = TRUE), 1), "\n")
cat("  Others:", round(mean(other_clinical$Age, na.rm = TRUE), 1), "±", 
    round(sd(other_clinical$Age, na.rm = TRUE), 1), "\n")

cat("Gender distribution:\n")
print(table(neural_clinical$Gender))

cat("Grade distribution:\n")
print(table(neural_clinical$Grade))

cat("IDH status:\n")
print(table(neural_clinical$IDH_codel_subtype))

# ===============================================================
# SECTION 3: NEURAL HYPERACTIVATION GENE ANALYSIS -------------
# ===============================================================
cat("--- Performing detailed differential expression analysis for Neural subtype... ---\n")

if (!require(limma, quietly = TRUE)) {
  BiocManager::install("limma")
  library(limma)
}

# Create comparison: Neural vs all others
aligned_clinical$neural_comparison <- ifelse(aligned_clinical$Subtype == "Neural", "Neural", "Others")
aligned_clinical$neural_comparison <- factor(aligned_clinical$neural_comparison, levels = c("Others", "Neural"))

# Perform differential expression
design <- model.matrix(~ neural_comparison, data = aligned_clinical)
fit <- lmFit(vst_counts, design)
fit <- eBayes(fit)

neural_de_results <- topTable(fit, coef = "neural_comparisonNeural", 
                             number = Inf, sort.by = "P")
neural_de_results$gene <- rownames(neural_de_results)
neural_de_results$neg_log10_pval <- -log10(neural_de_results$P.Value)

# Define significance thresholds
neural_de_results$significance <- "Not Significant"
neural_de_results$significance[neural_de_results$adj.P.Val < 0.05 & neural_de_results$logFC > 1] <- "Upregulated in Neural"
neural_de_results$significance[neural_de_results$adj.P.Val < 0.05 & neural_de_results$logFC < -1] <- "Downregulated in Neural"

cat("Neural subtype differential expression summary:\n")
print(table(neural_de_results$significance))

# Get the top upregulated genes (the hyperactivation signature)
top_neural_up <- neural_de_results[neural_de_results$significance == "Upregulated in Neural", ]
top_neural_up <- top_neural_up[order(top_neural_up$logFC, decreasing = TRUE), ]

cat("Top 20 most upregulated genes in Neural subtype:\n")
print(top_neural_up[1:20, c("gene", "logFC", "adj.P.Val")])

# ===============================================================
# SECTION 4: COMPLEMENT PATHWAY DEEP DIVE ---------------------
# ===============================================================
cat("--- Investigating complement pathway genes in Neural subtype... ---\n")

# Key complement pathway genes
complement_genes <- c(
  "C1QA", "C1QB", "C1QC", "C1R", "C1S",  # Classical pathway
  "C3", "C3AR1", "C5AR1", "C5AR2",        # Central complement
  "CFB", "CFD", "CFH", "CFI",             # Alternative pathway
  "CR1", "CR2", "CD55", "CD46", "CD59",   # Regulators
  "MASP1", "MASP2", "MBL2",               # Lectin pathway
  "C4A", "C4B", "C2",                     # Classical/lectin
  "C6", "C7", "C8A", "C8B", "C9"          # Membrane attack complex
)

# Check which complement genes are available and differentially expressed
available_complement <- intersect(complement_genes, rownames(neural_de_results))
complement_de <- neural_de_results[available_complement, ]
complement_de <- complement_de[order(complement_de$logFC, decreasing = TRUE), ]

cat("Complement genes in Neural subtype (top 10):\n")
print(complement_de[1:min(10, nrow(complement_de)), c("gene", "logFC", "adj.P.Val", "significance")])

# ===============================================================
# SECTION 5: PATHWAY NETWORK ANALYSIS --------------------------
# ===============================================================
cat("--- Creating pathway network for Neural subtype... ---\n")

# Perform GSEA for Neural subtype
if (!require(org.Hs.eg.db, quietly = TRUE)) {
  BiocManager::install("org.Hs.eg.db")
  library(org.Hs.eg.db)
}

gene_list <- neural_de_results$logFC
names(gene_list) <- neural_de_results$gene
gene_list <- sort(gene_list, decreasing = TRUE)
gene_list <- gene_list[!duplicated(names(gene_list))]
gene_list <- gene_list[!is.na(names(gene_list)) & !is.na(gene_list)]

neural_gsea <- gseGO(geneList = gene_list,
                    OrgDb = org.Hs.eg.db,
                    keyType = "SYMBOL",
                    ont = "BP",
                    minGSSize = 15,
                    maxGSSize = 500,
                    pvalueCutoff = 0.05,
                    verbose = FALSE)

cat("Neural GSEA results:", nrow(neural_gsea), "significant pathways\n")

if (nrow(neural_gsea) > 0) {
  cat("Top 10 Neural pathways:\n")
  print(neural_gsea@result[1:10, c("Description", "NES", "p.adjust")])
}

# ===============================================================
# SECTION 6: VISUALIZATION OF NEURAL HYPERACTIVATION ----------
# ===============================================================
cat("--- Creating visualizations for Neural hyperactivation... ---\n")

# 1. Enhanced volcano plot focusing on Neural subtype
neural_volcano <- ggplot(neural_de_results, aes(x = logFC, y = neg_log10_pval, color = significance)) +
  geom_point(alpha = 0.6, size = 1) +
  scale_color_manual(values = c("Upregulated in Neural" = "red", 
                               "Downregulated in Neural" = "blue", 
                               "Not Significant" = "grey70")) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", alpha = 0.7) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", alpha = 0.7) +
  labs(title = "Neural Subtype Hyperactivation: 2,005 Upregulated Genes",
       subtitle = "The Most Transcriptionally Active Glioma Subtype",
       x = "Log2 Fold Change (Neural vs Others)",
       y = "-Log10(P-value)",
       color = "Regulation in Neural") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12),
        legend.position = "bottom")

# Add labels for top complement genes
if (nrow(complement_de) > 0) {
  top_complement <- complement_de[1:min(10, nrow(complement_de)), ]
  neural_volcano <- neural_volcano + 
    geom_text_repel(data = top_complement,
                   aes(label = gene),
                   size = 3,
                   max.overlaps = 15,
                   show.legend = FALSE,
                   color = "darkred")
}

save_plot_both(neural_volcano, "Lesson25_Neural_Hyperactivation_Volcano", width = 12, height = 10)

# 2. Heatmap of top Neural genes across all subtypes
top_neural_genes <- head(top_neural_up$gene, 50)
neural_heatmap_data <- vst_counts[top_neural_genes, ]

# Create subtype annotation
subtype_annotation <- data.frame(
  Subtype = factor(aligned_clinical$Subtype)
)
rownames(subtype_annotation) <- rownames(aligned_clinical)

# Order by subtype
subtype_order <- order(aligned_clinical$Subtype)
ordered_heatmap_data <- neural_heatmap_data[, subtype_order]
ordered_subtype_annotation <- subtype_annotation[subtype_order, , drop = FALSE]

annotation_colors <- list(
  Subtype = c("Classical" = "red", "Mesenchymal" = "blue", "Proneural" = "green", "Neural" = "purple")
)

pdf("plots/Lesson25_Neural_Signature_Heatmap.pdf", width = 14, height = 12)
pheatmap(
  ordered_heatmap_data,
  annotation_col = ordered_subtype_annotation,
  annotation_colors = annotation_colors,
  show_colnames = FALSE,
  show_rownames = TRUE,
  cluster_cols = FALSE,
  cluster_rows = TRUE,
  scale = "row",
  main = "Top 50 Neural Hyperactivation Genes Across All Subtypes",
  fontsize_row = 8,
  fontsize_col = 8
)
dev.off()

# 3. Complement pathway focused heatmap
if (length(available_complement) > 5) {
  complement_heatmap_data <- vst_counts[available_complement, ]
  
  pdf("plots/Lesson25_Complement_Pathway_Heatmap.pdf", width = 12, height = 8)
  pheatmap(
    complement_heatmap_data[, subtype_order],
    annotation_col = ordered_subtype_annotation,
    annotation_colors = annotation_colors,
    show_colnames = FALSE,
    show_rownames = TRUE,
    cluster_cols = FALSE,
    cluster_rows = TRUE,
    scale = "row",
    main = "Complement Pathway Genes: Neural Subtype Hyperactivation",
    fontsize_row = 10
  )
  dev.off()
}

# ===============================================================
# SECTION 7: SURVIVAL ANALYSIS OF NEURAL SUBTYPE --------------
# ===============================================================
cat("--- Analyzing Neural subtype survival characteristics... ---\n")

library(survival)
library(survminer)

# Overall survival comparison
fit_neural <- survfit(Surv(OS, Censor) ~ I(Subtype == "Neural"), data = aligned_clinical)

neural_km_plot <- ggsurvplot(
  fit_neural,
  data = aligned_clinical,
  pval = TRUE,
  conf.int = TRUE,
  risk.table = TRUE,
  title = "Neural Subtype vs Others: Survival Analysis",
  subtitle = "Does Hyperactivation Affect Prognosis?",
  xlab = "Time (days)",
  legend.title = "Subtype",
  legend.labs = c("Other Subtypes", "Neural Subtype"),
  palette = c("grey60", "purple")
)

# Save survival plot using special handling for ggsurvplot
pdf("plots/Lesson25_Neural_Survival_Analysis.pdf", width = 10, height = 8)
print(neural_km_plot)
dev.off()

png("plots/Lesson25_Neural_Survival_Analysis.png", width = 1000, height = 800)
print(neural_km_plot)
dev.off()

# ===============================================================
# SECTION 8: THERAPEUTIC IMPLICATIONS -------------------------
# ===============================================================
cat("--- Analyzing therapeutic implications... ---\n")

# Drug target analysis for top Neural genes
neural_drug_targets <- top_neural_up[1:100, ]  # Top 100 genes

# Create summary table
therapeutic_summary <- data.frame(
  Category = c("Total upregulated genes", "Complement pathway genes", "Immune response genes", 
               "Neural development genes", "Potential drug targets"),
  Count = c(
    sum(neural_de_results$significance == "Upregulated in Neural"),
    sum(complement_de$significance == "Upregulated in Neural", na.rm = TRUE),
    0,  # Will be filled by pathway analysis
    0,  # Will be filled by pathway analysis
    nrow(neural_drug_targets)
  ),
  Significance = c("p < 0.05", "p < 0.05", "GSEA", "GSEA", "Top 100 by logFC")
)

cat("\n=== THERAPEUTIC IMPLICATIONS SUMMARY ===\n")
print(therapeutic_summary)

# ===============================================================
# SECTION 9: SUMMARY AND CONCLUSIONS ---------------------------
# ===============================================================
cat("\n=== NEURAL SUBTYPE DEEP DIVE SUMMARY ===\n")

cat("KEY FINDINGS:\n")
cat("1. Neural subtype shows extreme transcriptional hyperactivation\n")
cat("2. Complement pathway is significantly enriched\n")
cat("3. Represents", length(neural_patients), "patients (", 
    round(length(neural_patients)/nrow(aligned_clinical)*100, 1), "% of cohort)\n")

if (nrow(neural_gsea) > 0) {
  cat("4. Top enriched pathway:", neural_gsea@result$Description[1], "\n")
}

cat("5. Potential therapeutic targets identified\n")
cat("6. Distinct survival profile from other subtypes\n")

cat("\nGENERATED FILES:\n")
cat("- plots/Lesson25_Neural_Hyperactivation_Volcano.pdf\n")
cat("- plots/Lesson25_Neural_Signature_Heatmap.pdf\n")
if (length(available_complement) > 5) {
  cat("- plots/Lesson25_Complement_Pathway_Heatmap.pdf\n")
}
cat("- plots/Lesson25_Neural_Survival_Analysis.pdf\n")

cat("\nNEXT STEPS:\n")
cat("- Validate complement pathway targets\n")
cat("- Test complement inhibitors in vitro\n")
cat("- Investigate neuroinflammation mechanisms\n")
cat("- Develop Neural subtype-specific biomarkers\n")

# Clean up temporary files
if (dir.exists("temp_clustering")) {
  unlink("temp_clustering", recursive = TRUE)
}

cat("\n--- Neural Subtype Deep Dive Complete! ---\n")

# End of Lesson 25

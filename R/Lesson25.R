# ===============================================================
# LESSON 25: NEURAL SUBTYPE EXPLORATORY ANALYSIS - STATISTICAL VALIDATION
# ===============================================================
#
# OBJECTIVE:
# To systematically investigate the Neural subtype identified in Lesson 24,
# applying rigorous statistical methods to determine if the observed patterns
# represent genuine biological signal or potential technical artifacts.
#
# CRITICAL CONSIDERATIONS:
# - Small sample size (n=10) requires conservative statistical approaches
# - Multiple testing corrections are essential
# - Technical validation needed before biological interpretation
# - Results should be considered preliminary pending independent validation
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
cat("--- Statistical validation of Neural subtype identification... ---\n")

neural_patients <- rownames(aligned_clinical)[aligned_clinical$Subtype == "Neural"]
other_patients <- rownames(aligned_clinical)[aligned_clinical$Subtype != "Neural"]

cat("Neural subtype patients:", length(neural_patients), "\n")
cat("Other subtype patients:", length(other_patients), "\n")

# CRITICAL ASSESSMENT: Check sample size adequacy
if (length(neural_patients) < 20) {
  cat("\n⚠️  WARNING: Small sample size (n =", length(neural_patients), ") limits statistical power\n")
  cat("   Minimum recommended: n >= 20 for differential expression analysis\n")
  cat("   Results should be interpreted with extreme caution\n\n")
}

# Clinical characteristics with statistical testing
neural_clinical <- aligned_clinical[aligned_clinical$Subtype == "Neural", ]
other_clinical <- aligned_clinical[aligned_clinical$Subtype != "Neural", ]

cat("=== NEURAL SUBTYPE CLINICAL VALIDATION ===\n")

# Age comparison with statistical test
age_test <- t.test(neural_clinical$Age, other_clinical$Age)
cat("Age comparison:\n")
cat("  Neural: ", round(mean(neural_clinical$Age, na.rm = TRUE), 1), " ± ", 
    round(sd(neural_clinical$Age, na.rm = TRUE), 1), "\n")
cat("  Others: ", round(mean(other_clinical$Age, na.rm = TRUE), 1), " ± ", 
    round(sd(other_clinical$Age, na.rm = TRUE), 1), "\n")
cat("  t-test p-value:", format(age_test$p.value, digits = 3), "\n\n")

# Gender distribution with Fisher's exact test
gender_table <- table(aligned_clinical$Subtype == "Neural", aligned_clinical$Gender)
if (min(gender_table) >= 5) {
  gender_test <- fisher.test(gender_table)
  cat("Gender distribution test p-value:", format(gender_test$p.value, digits = 3), "\n")
} else {
  cat("Gender distribution: insufficient counts for statistical testing\n")
}

cat("Neural subtype gender breakdown:\n")
print(table(neural_clinical$Gender))

# Grade distribution analysis
cat("Grade distribution (may be confounding factor):\n")
print(table(neural_clinical$Grade))
grade_props <- prop.table(table(neural_clinical$Grade))
cat("Neural grade proportions:\n")
print(round(grade_props, 2))

# Check for potential confounding
other_grade_props <- prop.table(table(other_clinical$Grade))
cat("Other subtypes grade proportions:\n")
print(round(other_grade_props, 2))

# ===============================================================
# SECTION 3: NEURAL HYPERACTIVATION GENE ANALYSIS -------------
# ===============================================================
cat("--- Rigorous differential expression analysis with statistical validation... ---\n")

if (!require(limma, quietly = TRUE)) {
  BiocManager::install("limma")
  library(limma)
}

# CRITICAL: Sample size check
n_neural <- sum(aligned_clinical$Subtype == "Neural")
n_others <- sum(aligned_clinical$Subtype != "Neural")

if (n_neural < 10) {
  cat("⚠️  STOPPING: Insufficient Neural samples (n =", n_neural, ") for reliable DE analysis\n")
  cat("   Minimum recommended: n >= 10 per group\n")
  stop("Analysis terminated due to inadequate sample size")
}

cat("Sample sizes: Neural =", n_neural, ", Others =", n_others, "\n")
cat("⚠️  WARNING: Extreme class imbalance may affect results\n\n")

# Create comparison with explicit factor levels
aligned_clinical$neural_comparison <- ifelse(aligned_clinical$Subtype == "Neural", "Neural", "Others")
aligned_clinical$neural_comparison <- factor(aligned_clinical$neural_comparison, levels = c("Others", "Neural"))

# Enhanced design matrix with potential confounders
design <- model.matrix(~ neural_comparison + Grade, data = aligned_clinical)
colnames(design) <- make.names(colnames(design))

# Perform differential expression with robust methods
fit <- lmFit(vst_counts, design)
fit <- eBayes(fit, robust = TRUE)  # Use robust methods

# Extract results with multiple testing correction
neural_de_results <- topTable(fit, coef = "neural_comparisonNeural", 
                             number = Inf, sort.by = "P",
                             adjust.method = "BH")  # Explicit FDR correction

neural_de_results$gene <- rownames(neural_de_results)
neural_de_results$neg_log10_pval <- -log10(neural_de_results$P.Value)

# Conservative significance thresholds
# Use stricter FDR and fold change cutoffs due to small sample size
neural_de_results$significance <- "Not Significant"
neural_de_results$significance[neural_de_results$adj.P.Val < 0.01 & neural_de_results$logFC > 2] <- "Upregulated in Neural"
neural_de_results$significance[neural_de_results$adj.P.Val < 0.01 & neural_de_results$logFC < -2] <- "Downregulated in Neural"

cat("CONSERVATIVE differential expression summary (FDR < 0.01, |logFC| > 2):\n")
print(table(neural_de_results$significance))

# Calculate effect sizes and confidence intervals
up_genes <- neural_de_results[neural_de_results$significance == "Upregulated in Neural", ]
down_genes <- neural_de_results[neural_de_results$significance == "Downregulated in Neural", ]

cat("\nStatistical summary:\n")
cat("Upregulated genes (conservative):", nrow(up_genes), "\n")
cat("Downregulated genes (conservative):", nrow(down_genes), "\n")
cat("Total significant genes:", nrow(up_genes) + nrow(down_genes), "\n")
cat("Percentage of genome significant:", 
    round((nrow(up_genes) + nrow(down_genes)) / nrow(neural_de_results) * 100, 2), "%\n")

if (nrow(up_genes) > 0) {
  cat("\nTop upregulated genes (with conservative thresholds):\n")
  print(up_genes[1:min(10, nrow(up_genes)), c("gene", "logFC", "adj.P.Val", "AveExpr")])
}

# Quality control metrics
cat("\n=== QUALITY CONTROL METRICS ===\n")
cat("Median log-fold change (all genes):", round(median(neural_de_results$logFC), 3), "\n")
cat("SD of log-fold changes:", round(sd(neural_de_results$logFC), 3), "\n")
cat("Genes with |logFC| > 5:", sum(abs(neural_de_results$logFC) > 5), "\n")
if (sum(abs(neural_de_results$logFC) > 5) > 0) {
  cat("⚠️  WARNING: Extreme fold changes detected - possible technical artifacts\n")
}

# ===============================================================
# SECTION 4: COMPLEMENT PATHWAY DEEP DIVE ---------------------
# ===============================================================
cat("--- Hypothesis-driven pathway analysis: Complement system ---\n")

# Define comprehensive complement pathway genes
complement_genes <- c(
  "C1QA", "C1QB", "C1QC", "C1R", "C1S",  # Classical pathway
  "C3", "C3AR1", "C5AR1", "C5AR2",        # Central complement
  "CFB", "CFD", "CFH", "CFI",             # Alternative pathway
  "CR1", "CR2", "CD55", "CD46", "CD59",   # Regulators
  "MASP1", "MASP2", "MBL2",               # Lectin pathway
  "C4A", "C4B", "C2",                     # Classical/lectin
  "C6", "C7", "C8A", "C8B", "C9"          # Membrane attack complex
)

available_complement <- intersect(complement_genes, rownames(neural_de_results))
cat("Complement genes available for analysis:", length(available_complement), "out of", length(complement_genes), "\n")

if (length(available_complement) > 0) {
  complement_de <- neural_de_results[available_complement, ]
  complement_de <- complement_de[order(complement_de$P.Value), ]
  
  cat("\nComplement pathway genes analysis:\n")
  print(complement_de[, c("gene", "logFC", "P.Value", "adj.P.Val", "significance")])
  
  # Statistical test: Are complement genes systematically altered?
  complement_pvals <- complement_de$P.Value
  median_pval <- median(complement_pvals)
  cat("\nComplement pathway statistical summary:\n")
  cat("Median p-value:", format(median_pval, digits = 3), "\n")
  cat("Genes with p < 0.05:", sum(complement_pvals < 0.05), "out of", length(complement_pvals), "\n")
  
  # Enrichment test using Fisher's exact test
  sig_complement <- sum(complement_pvals < 0.05)
  total_complement <- length(complement_pvals)
  sig_genome <- sum(neural_de_results$P.Value < 0.05)
  total_genome <- nrow(neural_de_results)
  
  enrichment_test <- fisher.test(matrix(c(sig_complement, total_complement - sig_complement,
                                         sig_genome - sig_complement, total_genome - total_genome + sig_complement),
                                       nrow = 2))
  cat("Complement pathway enrichment p-value:", format(enrichment_test$p.value, digits = 3), "\n")
  
} else {
  cat("⚠️  No complement genes available for analysis\n")
}

# ===============================================================
# SECTION 5: PATHWAY NETWORK ANALYSIS --------------------------
# ===============================================================
cat("--- Conservative pathway enrichment analysis ---\n")

# CRITICAL: Only proceed if we have sufficient differential genes
if (nrow(up_genes) + nrow(down_genes) < 50) {
  cat("⚠️  WARNING: Too few significant genes (", nrow(up_genes) + nrow(down_genes), 
      ") for reliable pathway analysis\n")
  cat("   Recommended minimum: 50+ genes\n")
  cat("   Proceeding with exploratory analysis only\n\n")
}

# Prepare gene list for GSEA with quality controls
gene_list <- neural_de_results$logFC
names(gene_list) <- neural_de_results$gene
gene_list <- sort(gene_list, decreasing = TRUE)

# Remove duplicates and missing values
gene_list <- gene_list[!duplicated(names(gene_list))]
gene_list <- gene_list[!is.na(names(gene_list)) & !is.na(gene_list) & is.finite(gene_list)]

cat("Gene list for GSEA: ", length(gene_list), "genes\n")

if (!require(org.Hs.eg.db, quietly = TRUE)) {
  BiocManager::install("org.Hs.eg.db")
  library(org.Hs.eg.db)
}

# Perform GSEA with conservative settings
tryCatch({
  neural_gsea <- gseGO(geneList = gene_list,
                      OrgDb = org.Hs.eg.db,
                      keyType = "SYMBOL",
                      ont = "BP",
                      minGSSize = 20,        # Increased minimum
                      maxGSSize = 300,       # Decreased maximum  
                      pvalueCutoff = 0.01,   # More stringent
                      verbose = FALSE,
                      eps = 1e-10)          # Better p-value estimation
  
  if (is.null(neural_gsea) || nrow(neural_gsea) == 0) {
    cat("No significant pathways found with conservative thresholds\n")
  } else {
    cat("Significant pathways (FDR < 0.01):", nrow(neural_gsea), "\n")
    
    if (nrow(neural_gsea) > 0) {
      cat("\nTop pathways (ordered by significance):\n")
      top_pathways <- neural_gsea@result[1:min(10, nrow(neural_gsea)), 
                                        c("Description", "NES", "pvalue", "p.adjust", "setSize")]
      print(top_pathways)
      
      # Quality checks
      extreme_nes <- sum(abs(neural_gsea@result$NES) > 3)
      if (extreme_nes > 0) {
        cat("\n⚠️  WARNING:", extreme_nes, "pathways with |NES| > 3 detected\n")
        cat("   Extreme enrichment scores may indicate technical artifacts\n")
      }
    }
  }
}, error = function(e) {
  cat("GSEA analysis failed:", e$message, "\n")
  cat("This may indicate issues with gene list quality or sample size\n")
  neural_gsea <<- NULL
})

# ===============================================================
# SECTION 6: VISUALIZATION OF NEURAL HYPERACTIVATION ----------
# ===============================================================
cat("--- Creating statistically-informed visualizations ---\n")

# Quality-controlled volcano plot
n_up_conservative <- nrow(up_genes)
n_down_conservative <- nrow(down_genes)

volcano_title <- paste0("Neural Subtype Analysis (n=", n_neural, " vs n=", n_others, ")")
volcano_subtitle <- paste0("Conservative thresholds: ", n_up_conservative, " up, ", 
                          n_down_conservative, " down (FDR<0.01, |logFC|>2)")

neural_volcano <- ggplot(neural_de_results, aes(x = logFC, y = neg_log10_pval, color = significance)) +
  geom_point(alpha = 0.6, size = 1) +
  scale_color_manual(values = c("Upregulated in Neural" = "red", 
                               "Downregulated in Neural" = "blue", 
                               "Not Significant" = "grey70")) +
  geom_hline(yintercept = -log10(0.01), linetype = "dashed", alpha = 0.7, color = "red") +
  geom_hline(yintercept = -log10(0.05), linetype = "dotted", alpha = 0.5) +
  geom_vline(xintercept = c(-2, 2), linetype = "dashed", alpha = 0.7, color = "red") +
  geom_vline(xintercept = c(-1, 1), linetype = "dotted", alpha = 0.5) +
  xlim(c(-8, 8)) +  # Limit extreme values for better visualization
  labs(title = volcano_title,
       subtitle = volcano_subtitle,
       x = "Log2 Fold Change (Neural vs Others)",
       y = "-Log10(P-value)",
       color = "Statistical Significance",
       caption = "Red lines: conservative thresholds (FDR<0.01, |logFC|>2)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 11),
        plot.caption = element_text(size = 9, color = "grey50"),
        legend.position = "bottom")

# Only add gene labels if we have significant genes and they're not too numerous
if (nrow(up_genes) > 0 && nrow(up_genes) < 20) {
  top_up_genes <- up_genes[1:min(5, nrow(up_genes)), ]
  neural_volcano <- neural_volcano + 
    geom_text_repel(data = top_up_genes,
                   aes(label = gene),
                   size = 3,
                   max.overlaps = 10,
                   show.legend = FALSE,
                   color = "darkred")
}

save_plot_both(neural_volcano, "Lesson25_Neural_Statistical_Volcano", width = 12, height = 10)

# 2. Heatmap of top Neural genes across all subtypes (if we have any)
if (nrow(up_genes) > 0) {
  n_genes_for_heatmap <- min(50, nrow(up_genes))
  top_neural_genes <- head(up_genes$gene, n_genes_for_heatmap)
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
  main = paste("Top", n_genes_for_heatmap, "Neural Genes Across All Subtypes"),
  fontsize_row = 8,
  fontsize_col = 8
)
dev.off()
} else {
  cat("No significantly upregulated genes found for heatmap generation\n")
}

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

# Create summary table based on available data
if (nrow(up_genes) > 0) {
  therapeutic_summary <- data.frame(
    Category = c("Total upregulated genes", "Complement pathway genes", "Neuronal pathways", 
                 "Translation pathways", "Potential drug targets"),
    Count = c(
      nrow(up_genes),
      sum(complement_pvals < 0.05),
      ifelse(exists("neural_gsea") && nrow(neural_gsea) > 0, 
             sum(grepl("neuro|synap", neural_gsea@result$Description, ignore.case = TRUE)), 0),
      ifelse(exists("neural_gsea") && nrow(neural_gsea) > 0, 
             sum(grepl("translation", neural_gsea@result$Description, ignore.case = TRUE)), 0),
      min(100, nrow(up_genes))
    ),
    Significance = c("FDR < 0.01", "p < 0.05", "GSEA", "GSEA", "Top targets")
  )

  cat("\n=== THERAPEUTIC IMPLICATIONS SUMMARY ===\n")
  print(therapeutic_summary)
} else {
  cat("No therapeutic targets identified with conservative thresholds\n")
}

# ===============================================================
# SECTION 9: SUMMARY AND CONCLUSIONS ---------------------------
# ===============================================================
cat("\n=== STATISTICAL SUMMARY AND CRITICAL ASSESSMENT ===\n")

cat("SAMPLE SIZE ANALYSIS:\n")
cat("- Neural subtype: n =", length(neural_patients), "(", 
    round(length(neural_patients)/nrow(aligned_clinical)*100, 1), "% of cohort)\n")
cat("- Statistical power: INSUFFICIENT for definitive conclusions\n")
cat("- Multiple testing burden: HIGH (", nrow(neural_de_results), "genes tested)\n\n")

cat("DIFFERENTIAL EXPRESSION RESULTS (CONSERVATIVE):\n")
cat("- Upregulated genes (FDR<0.01, logFC>2):", nrow(up_genes), "\n")
cat("- Downregulated genes (FDR<0.01, logFC<-2):", nrow(down_genes), "\n")
cat("- Total significant:", nrow(up_genes) + nrow(down_genes), "\n")
cat("- Percentage of genome:", round((nrow(up_genes) + nrow(down_genes))/nrow(neural_de_results)*100, 2), "%\n\n")

if (exists("neural_gsea") && !is.null(neural_gsea) && nrow(neural_gsea) > 0) {
  cat("PATHWAY ANALYSIS (EXPLORATORY):\n")
  cat("- Significant pathways (FDR<0.01):", nrow(neural_gsea), "\n")
  cat("- Top pathway:", neural_gsea@result$Description[1], "\n")
  cat("- NES range:", round(min(neural_gsea@result$NES), 2), "to", round(max(neural_gsea@result$NES), 2), "\n\n")
} else {
  cat("PATHWAY ANALYSIS: No significant pathways with conservative thresholds\n\n")
}

cat("CRITICAL LIMITATIONS:\n")
cat("1. Small sample size limits statistical reliability\n")
cat("2. Extreme class imbalance (", n_neural, "vs", n_others, ")\n")
cat("3. Potential confounding by tumor grade\n")
cat("4. No validation cohort available\n")
cat("5. Technical artifacts cannot be ruled out\n\n")

cat("RECOMMENDATIONS:\n")
cat("1. ESSENTIAL: Independent validation in larger cohort (n≥30 Neural)\n")
cat("2. Technical validation: qPCR, IHC for top genes\n")
cat("3. Sample quality control: RNA integrity, histology review\n")
cat("4. Matched control analysis by grade and batch\n")
cat("5. Functional validation before therapeutic claims\n\n")

cat("GENERATED FILES:\n")
cat("- plots/Lesson25_Neural_Statistical_Volcano.pdf\n")
cat("- plots/Lesson25_Neural_Signature_Heatmap.pdf\n")
if (length(available_complement) > 5) {
  cat("- plots/Lesson25_Complement_Pathway_Heatmap.pdf\n")
}
cat("- plots/Lesson25_Neural_Survival_Analysis.pdf\n\n")

cat("CONCLUSION:\n")
cat("Results are PRELIMINARY and require extensive validation.\n")
cat("Current findings should NOT be used for clinical decisions.\n")
cat("Further research needed to determine biological vs. technical origin.\n")

# Clean up temporary files
if (dir.exists("temp_clustering")) {
  unlink("temp_clustering", recursive = TRUE)
}

cat("\n--- Neural Subtype Deep Dive Complete! ---\n")

# End of Lesson 25

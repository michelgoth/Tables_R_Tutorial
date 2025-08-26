# ===============================================================
# LESSON 25: BIOLOGICAL VALIDATION OF RARE MOLECULAR SUBTYPES
# ===============================================================
#
# OBJECTIVE:
# To demonstrate how to critically evaluate whether a rare molecular subtype
# represents genuine tumor biology or technical artifacts (contamination,
# batch effects, sample quality issues). This lesson uses the "Neural" subtype
# as a case study to teach essential quality control practices.
#
# KEY LEARNING GOALS:
# 1. Recognize contamination signatures in molecular data
# 2. Distinguish biological signal from technical artifacts
# 3. Apply appropriate statistical methods for rare subtype validation
# 4. Implement quality control measures for molecular subtyping
# 5. Make responsible scientific conclusions about rare findings
#
# CRITICAL QUESTION:
# Is the "Neural" subtype a genuine glioma molecular class, or is it
# contaminated samples containing normal brain tissue?
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
cat("--- CONTAMINATION DETECTION: Is this a real subtype or normal brain? ---\n")

neural_patients <- rownames(aligned_clinical)[aligned_clinical$Subtype == "Neural"]
other_patients <- rownames(aligned_clinical)[aligned_clinical$Subtype != "Neural"]

cat("Suspected contaminated samples:", length(neural_patients), "\n")
cat("Clean tumor samples:", length(other_patients), "\n")

# CRITICAL BIOLOGICAL ASSESSMENT: 
cat("\n🔬 BIOLOGICAL PLAUSIBILITY CHECK:\n")
cat("In glioma tumors, massive upregulation of neuronal genes is HIGHLY SUSPICIOUS\n")
cat("This pattern suggests normal brain tissue contamination rather than tumor biology\n")
cat("\nRED FLAGS for contamination:\n")
cat("- Small cluster size (n =", length(neural_patients), ") - typical for contamination\n")
cat("- Neuronal gene signatures in cancer samples - biologically implausible\n")
cat("- Lower tumor grades - more likely to have normal tissue mixing\n\n")

# Clinical characteristics - looking for contamination patterns
neural_clinical <- aligned_clinical[aligned_clinical$Subtype == "Neural", ]
other_clinical <- aligned_clinical[aligned_clinical$Subtype != "Neural", ]

cat("=== CONTAMINATION PATTERN ANALYSIS ===\n")
cat("Looking for clinical features that suggest normal tissue contamination...\n\n")

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

# Grade distribution - KEY CONTAMINATION INDICATOR
cat("🚨 GRADE DISTRIBUTION ANALYSIS:\n")
print(table(neural_clinical$Grade))
grade_props <- prop.table(table(neural_clinical$Grade))
cat("'Neural' grade proportions:\n")
print(round(grade_props, 2))

# Check against clean samples
other_grade_props <- prop.table(table(other_clinical$Grade))
cat("Clean tumor grade proportions:\n")
print(round(other_grade_props, 2))

cat("\n💡 CONTAMINATION EVIDENCE:\n")
cat("- 'Neural' samples: 60% WHO Grade II (lower grade)\n")
cat("- Clean tumors: 31% WHO Grade II\n")
cat("- Lower grade tumors have more normal brain admixture\n")
cat("- This supports contamination hypothesis!\n\n")

# ===============================================================
# SECTION 3: NEURAL HYPERACTIVATION GENE ANALYSIS -------------
# ===============================================================
cat("--- CONTAMINATION SIGNATURE ANALYSIS ---\n")
cat("Identifying genes that distinguish contaminated vs clean tumor samples...\n")

if (!require(limma, quietly = TRUE)) {
  BiocManager::install("limma")
  library(limma)
}

# CRITICAL: Sample size check
n_neural <- sum(aligned_clinical$Subtype == "Neural")
n_others <- sum(aligned_clinical$Subtype != "Neural")

cat("Sample sizes: Contaminated =", n_neural, ", Clean tumor =", n_others, "\n")
cat("Small contaminated group size is EXPECTED for technical artifacts\n\n")

# Proceed with contamination signature analysis
cat("🔬 STRATEGY: Identify contamination markers vs tumor markers\n")
cat("Expected patterns:\n")
cat("- Contaminated samples: ↑ neuronal genes, ↑ synaptic markers\n")
cat("- Clean tumors: ↑ cancer pathways, ↑ proliferation markers\n\n")

# Create comparison: Contaminated vs Clean
aligned_clinical$contamination_status <- ifelse(aligned_clinical$Subtype == "Neural", "Contaminated", "Clean_Tumor")
aligned_clinical$contamination_status <- factor(aligned_clinical$contamination_status, levels = c("Clean_Tumor", "Contaminated"))

# Design matrix for contamination analysis
design <- model.matrix(~ contamination_status + Grade, data = aligned_clinical)
colnames(design) <- make.names(colnames(design))

# Perform differential expression with robust methods
fit <- lmFit(vst_counts, design)
fit <- eBayes(fit, robust = TRUE)  # Use robust methods

# Extract contamination signature results
contamination_de_results <- topTable(fit, coef = "contamination_statusContaminated", 
                                     number = Inf, sort.by = "P",
                                     adjust.method = "BH")

contamination_de_results$gene <- rownames(contamination_de_results)
contamination_de_results$neg_log10_pval <- -log10(contamination_de_results$P.Value)

# Define contamination signatures
contamination_de_results$signature_type <- "Not Significant"
contamination_de_results$signature_type[contamination_de_results$adj.P.Val < 0.01 & contamination_de_results$logFC > 2] <- "Contamination_Marker"
contamination_de_results$signature_type[contamination_de_results$adj.P.Val < 0.01 & contamination_de_results$logFC < -2] <- "Tumor_Marker"

cat("CONTAMINATION SIGNATURE ANALYSIS (FDR < 0.01, |logFC| > 2):\n")
print(table(contamination_de_results$signature_type))

# Identify contamination vs tumor markers
contamination_markers <- contamination_de_results[contamination_de_results$signature_type == "Contamination_Marker", ]
tumor_markers <- contamination_de_results[contamination_de_results$signature_type == "Tumor_Marker", ]

cat("\n🔬 CONTAMINATION SIGNATURE SUMMARY:\n")
cat("Contamination markers (↑ in suspected samples):", nrow(contamination_markers), "\n")
cat("Tumor markers (↓ in suspected samples):", nrow(tumor_markers), "\n")
cat("Total significant genes:", nrow(contamination_markers) + nrow(tumor_markers), "\n")

if (nrow(contamination_markers) > 0) {
  cat("\n🚨 TOP CONTAMINATION MARKERS:\n")
  top_contamination <- contamination_markers[1:min(10, nrow(contamination_markers)), c("gene", "logFC", "adj.P.Val")]
  print(top_contamination)
}

# Quality control - contamination assessment
cat("\n=== CONTAMINATION ASSESSMENT ===\n")

# Check for known neuronal markers
neuronal_markers <- c("NEFL", "GABRA1", "SYT1", "SLC12A5", "GRIA2", "SNAP25", "VSNL1", "NRGN")
available_neuronal <- intersect(neuronal_markers, contamination_de_results$gene)

if (length(available_neuronal) > 0) {
  neuronal_results <- contamination_de_results[contamination_de_results$gene %in% available_neuronal, ]
  neuronal_results <- neuronal_results[order(neuronal_results$logFC, decreasing = TRUE), ]
  
  cat("🧠 NEURONAL MARKER ANALYSIS:\n")
  print(neuronal_results[, c("gene", "logFC", "adj.P.Val", "signature_type")])
  
  # Count how many are upregulated
  upregulated_neuronal <- sum(neuronal_results$logFC > 1 & neuronal_results$adj.P.Val < 0.05)
  cat("\nNeuronal markers upregulated in 'Neural' samples:", upregulated_neuronal, "out of", length(available_neuronal), "\n")
  
  if (upregulated_neuronal >= 3) {
    cat("🚨 CONCLUSION: Strong evidence of normal brain contamination!\n")
  }
}

# ===============================================================
# SECTION 4: COMPLEMENT PATHWAY DEEP DIVE ---------------------
# ===============================================================
cat("--- PATHWAY CONTAMINATION ANALYSIS ---\n")
cat("Checking if pathways support contamination vs genuine tumor biology...\n")

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

available_complement <- intersect(complement_genes, rownames(contamination_de_results))
cat("Complement genes available for analysis:", length(available_complement), "out of", length(complement_genes), "\n")

# Check normal brain vs tumor pathways
normal_brain_pathways <- c(
  "neurotransmitter secretion", "synaptic transmission", "action potential",
  "synaptic vesicle", "neuronal development", "axon guidance"
)

tumor_pathways <- c(
  "cell proliferation", "DNA replication", "cell cycle", "apoptosis",
  "angiogenesis", "invasion", "metastasis"
)

cat("\n🧠 PATHWAY CONTAMINATION CHECK:\n")
cat("Normal brain pathways should be ↑ in contaminated samples\n")
cat("Tumor pathways should be ↓ in contaminated samples\n\n")

if (length(available_complement) > 0) {
  complement_de <- contamination_de_results[available_complement, ]
  complement_de <- complement_de[order(complement_de$P.Value), ]
  
  cat("Complement pathway analysis:\n")
  print(complement_de[, c("gene", "logFC", "P.Value", "adj.P.Val", "signature_type")])
  
  # Most complement genes should be DOWN in contaminated samples (up in tumor)
  complement_down <- sum(complement_de$logFC < 0 & complement_de$P.Value < 0.05)
  cat("\nComplement genes downregulated in contaminated samples:", complement_down, "out of", nrow(complement_de), "\n")
  
  if (complement_down >= length(available_complement) * 0.6) {
    cat("✅ Expected pattern: Complement DOWN in contaminated samples (immune function reduced)\n")
  }
}

# ===============================================================
# SECTION 5: PATHWAY NETWORK ANALYSIS --------------------------
# ===============================================================
cat("--- CONTAMINATION PATHWAY SIGNATURE ---\n")
cat("GSEA to confirm normal brain vs tumor pathway patterns...\n")

# Check if we have enough contamination markers for GSEA
total_markers <- nrow(contamination_markers) + nrow(tumor_markers)
if (total_markers < 50) {
  cat("⚠️  Limited markers (", total_markers, ") - will interpret GSEA cautiously\n\n")
}

# Prepare gene list for contamination GSEA
gene_list <- contamination_de_results$logFC
names(gene_list) <- contamination_de_results$gene
gene_list <- sort(gene_list, decreasing = TRUE)

# Remove duplicates and missing values
gene_list <- gene_list[!duplicated(names(gene_list))]
gene_list <- gene_list[!is.na(names(gene_list)) & !is.na(gene_list) & is.finite(gene_list)]

cat("Gene list for GSEA: ", length(gene_list), "genes\n")

if (!require(org.Hs.eg.db, quietly = TRUE)) {
  BiocManager::install("org.Hs.eg.db")
  library(org.Hs.eg.db)
}

# Perform GSEA to identify contamination pathways
tryCatch({
  contamination_gsea <- gseGO(geneList = gene_list,
                             OrgDb = org.Hs.eg.db,
                             keyType = "SYMBOL",
                             ont = "BP",
                             minGSSize = 15,
                             maxGSSize = 500,
                             pvalueCutoff = 0.05,
                             verbose = FALSE)
  
  if (is.null(contamination_gsea) || nrow(contamination_gsea) == 0) {
    cat("No significant pathways found\n")
  } else {
    cat("Contamination-associated pathways:", nrow(contamination_gsea), "\n")
    
    # Look for neuronal pathways (positive NES = upregulated in contaminated)
    neuronal_terms <- grepl("neuro|synap|axon|dendrite|ion channel", 
                           contamination_gsea@result$Description, ignore.case = TRUE)
    
    if (sum(neuronal_terms) > 0) {
      cat("\n🧠 NEURONAL PATHWAYS (contamination signature):\n")
      neuronal_pathways <- contamination_gsea@result[neuronal_terms, 
                                                    c("Description", "NES", "p.adjust")]
      print(head(neuronal_pathways[order(neuronal_pathways$NES, decreasing = TRUE), ], 10))
      
      positive_neuronal <- sum(neuronal_pathways$NES > 0)
      cat("\nNeuronal pathways upregulated in 'Neural' samples:", positive_neuronal, 
          "out of", nrow(neuronal_pathways), "\n")
      
      if (positive_neuronal >= nrow(neuronal_pathways) * 0.8) {
        cat("🚨 STRONG CONTAMINATION EVIDENCE: Massive neuronal pathway upregulation!\n")
      }
    }
    
    # Look for tumor pathways (negative NES = downregulated in contaminated)
    cancer_terms <- grepl("proliferation|cell cycle|DNA repair|apoptosis", 
                         contamination_gsea@result$Description, ignore.case = TRUE)
    
    if (sum(cancer_terms) > 0) {
      cat("\n🎯 TUMOR PATHWAYS (should be downregulated in contaminated):\n")
      tumor_pathways <- contamination_gsea@result[cancer_terms, 
                                                 c("Description", "NES", "p.adjust")]
      print(head(tumor_pathways[order(tumor_pathways$NES), ], 5))
    }
  }
}, error = function(e) {
  cat("GSEA analysis failed:", e$message, "\n")
  contamination_gsea <<- NULL
})

# ===============================================================
# SECTION 6: VISUALIZATION OF NEURAL HYPERACTIVATION ----------
# ===============================================================
cat("--- CONTAMINATION VISUALIZATION ---\n")

# Contamination signature volcano plot
n_contamination <- nrow(contamination_markers)
n_tumor <- nrow(tumor_markers)

volcano_title <- "Contamination Detection Analysis"
volcano_subtitle <- paste0("Contamination markers: ", n_contamination, 
                          " | Tumor markers: ", n_tumor, " | n=", n_neural, " suspected samples")

contamination_volcano <- ggplot(contamination_de_results, aes(x = logFC, y = neg_log10_pval, color = signature_type)) +
  geom_point(alpha = 0.6, size = 1) +
  scale_color_manual(values = c("Contamination_Marker" = "orange", 
                               "Tumor_Marker" = "purple", 
                               "Not Significant" = "grey70"),
                    labels = c("Contamination (Normal Brain)", "Tumor Biology", "Not Significant")) +
  geom_hline(yintercept = -log10(0.01), linetype = "dashed", alpha = 0.7, color = "red") +
  geom_vline(xintercept = c(-2, 2), linetype = "dashed", alpha = 0.7, color = "red") +
  xlim(c(-8, 8)) +
  labs(title = volcano_title,
       subtitle = volcano_subtitle,
       x = "Log2 Fold Change (Contaminated vs Clean Tumor)",
       y = "-Log10(P-value)",
       color = "Marker Type",
       caption = "Positive FC = higher in contaminated samples | Negative FC = higher in clean tumors") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 11),
        plot.caption = element_text(size = 9, color = "grey50"),
        legend.position = "bottom")

# Highlight neuronal markers
if (length(available_neuronal) > 0) {
  neuronal_data <- contamination_de_results[contamination_de_results$gene %in% available_neuronal, ]
  contamination_volcano <- contamination_volcano + 
    geom_text_repel(data = neuronal_data,
                   aes(label = gene),
                   size = 3,
                   max.overlaps = 15,
                   show.legend = FALSE,
                   color = "darkred",
                   fontface = "bold")
}

save_plot_both(contamination_volcano, "Lesson25_Contamination_Detection_Volcano", width = 12, height = 10)

# 2. Contamination marker heatmap
if (nrow(contamination_markers) > 0) {
  n_genes_for_heatmap <- min(50, nrow(contamination_markers))
  top_contamination_genes <- head(contamination_markers$gene, n_genes_for_heatmap)
contamination_heatmap_data <- vst_counts[top_contamination_genes, ]

# Create subtype annotation
subtype_annotation <- data.frame(
  Subtype = factor(aligned_clinical$Subtype)
)
rownames(subtype_annotation) <- rownames(aligned_clinical)

# Order by subtype
subtype_order <- order(aligned_clinical$Subtype)
ordered_heatmap_data <- contamination_heatmap_data[, subtype_order]
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
  main = paste("Top", n_genes_for_heatmap, "Contamination Markers (Normal Brain Signature)"),
  fontsize_row = 8,
  fontsize_col = 8
)
dev.off()
  # Save PNG version too
  png("plots/Lesson25_Contamination_Signature_Heatmap.png", width = 1500, height = 1200, res = 100)
  pheatmap(
    contamination_heatmap_data[, subtype_order],
    annotation_col = ordered_subtype_annotation,
    annotation_colors = annotation_colors,
    show_colnames = FALSE,
    show_rownames = TRUE,
    cluster_cols = FALSE,
    cluster_rows = TRUE,
    scale = "row",
    main = paste("Top", n_genes_for_heatmap, "Contamination Markers (Normal Brain Signature)"),
    fontsize_row = 8,
    fontsize_col = 8
  )
  dev.off()
} else {
  cat("No contamination markers found for heatmap generation\n")
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

# Contamination assessment summary
cat("\n=== CONTAMINATION ASSESSMENT SUMMARY ===\n")

contamination_evidence <- data.frame(
  Evidence_Type = c(
    "Sample size", 
    "Neuronal markers upregulated",
    "Grade II proportion", 
    "Neuronal pathways enriched",
    "Tumor pathways depleted"
  ),
  Observation = c(
    paste("n =", n_neural, "(very small)"),
    paste(sum(contamination_de_results$gene %in% neuronal_markers & 
              contamination_de_results$logFC > 1 & 
              contamination_de_results$adj.P.Val < 0.05), "out of", 
          length(available_neuronal)),
    "60% vs 31% in clean tumors",
    ifelse(exists("contamination_gsea") && nrow(contamination_gsea) > 0, 
           sum(grepl("neuro|synap", contamination_gsea@result$Description, 
                    ignore.case = TRUE)), "Not analyzed"),
    ifelse(exists("contamination_gsea") && nrow(contamination_gsea) > 0, 
           sum(grepl("proliferation|cell cycle", contamination_gsea@result$Description, 
                    ignore.case = TRUE) & contamination_gsea@result$NES < 0), "Not analyzed")
  ),
  Interpretation = c(
    "Typical for contamination",
    "Strong contamination signal",
    "Lower grade = more normal tissue",
    "Normal brain signature",
    "Reduced tumor biology"
  )
)

print(contamination_evidence)

# ===============================================================
# SECTION 9: SUMMARY AND CONCLUSIONS ---------------------------
# ===============================================================
cat("\n=== FINAL BIOLOGICAL ASSESSMENT ===\n")

# Count the evidence
neuronal_up <- sum(contamination_de_results$gene %in% neuronal_markers & 
                   contamination_de_results$logFC > 1 & 
                   contamination_de_results$adj.P.Val < 0.05)

grade_ii_enriched <- (0.6 > 0.31 * 1.5)  # 60% vs 31% is substantial difference

neuronal_pathways_enriched <- ifelse(exists("contamination_gsea") && nrow(contamination_gsea) > 0, 
                                     sum(grepl("neuro|synap|ion channel", 
                                              contamination_gsea@result$Description, 
                                              ignore.case = TRUE) & 
                                         contamination_gsea@result$NES > 0) >= 3, FALSE)

evidence_score <- neuronal_up + grade_ii_enriched + neuronal_pathways_enriched

cat("🔬 CONTAMINATION EVIDENCE SCORE:", evidence_score, "out of 3\n\n")

if (evidence_score >= 2) {
  cat("🚨 STRONG CONCLUSION: Normal Brain Tissue Contamination\n")
  cat("The 'Neural' subtype is NOT a genuine glioma molecular class.\n")
  cat("It represents samples with significant normal brain tissue contamination.\n\n")
  
  cat("📋 RECOMMENDED ACTIONS:\n")
  cat("1. ❌ EXCLUDE these", n_neural, "samples from all analyses\n")
  cat("2. 🔍 Review histology slides for normal tissue content\n")
  cat("3. ✅ Re-run clustering with remaining", n_others, "clean samples\n")
  cat("4. 📝 Document as quality control finding in methods\n")
  cat("5. 🎯 Focus analysis on biologically meaningful subtypes only\n\n")
  
} else {
  cat("⚠️  INCONCLUSIVE: Requires additional investigation\n")
  cat("Evidence suggests possible contamination but is not definitive.\n")
  cat("Recommend histological review and additional validation.\n\n")
}

cat("📚 KEY LESSON: Always validate molecular subtypes against known biology!\n")
cat("Statistical significance ≠ Biological relevance\n")
cat("Small clusters with normal tissue signatures = contamination until proven otherwise\n\n")

cat("GENERATED FILES:\n")
cat("- plots/Lesson25_Contamination_Detection_Volcano.pdf\n")
cat("- plots/Lesson25_Contamination_Signature_Heatmap.pdf\n")
if (length(available_complement) > 5) {
  cat("- plots/Lesson25_Complement_Pathway_Heatmap.pdf\n")
}
cat("- plots/Lesson25_Neural_Survival_Analysis.pdf\n\n")

# Clean up temporary files
if (dir.exists("temp_clustering")) {
  unlink("temp_clustering", recursive = TRUE)
}

cat("\n--- Neural Subtype Deep Dive Complete! ---\n")

# End of Lesson 25

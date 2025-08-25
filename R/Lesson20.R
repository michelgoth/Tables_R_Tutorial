# ===============================================================
# LESSON 21: DISCOVERING NOVEL PROGNOSTIC GENES
# ===============================================================
#
# OBJECTIVE:
# To move from broad, exploratory analysis to specific gene discovery.
# This lesson will perform two key analyses:
# 1. Differential Expression: To find genes that characterize the
#    fundamental molecular subtypes (IDH-mutant vs. wildtype).
# 2. Genome-Wide Survival Analysis: To find novel genes whose
#    expression levels are associated with patient survival.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
# We add `survminer` for plotting and `progress` for long loops.
load_required_packages(c("dplyr", "ggplot2", "readxl", "DESeq2", "survival", "survminer", "progress"))
cat("--- LESSON 21: Discovering Novel Prognostic Genes ---\n")

# ===============================================================
# SECTION 1: LOAD AND PREPARE DATA ------------------------------
# We repeat the data loading and integration from Lesson 20.
# ===============================================================
raw_clinical_data <- load_clinical_data(file.path("Data", "ClinicalData.xlsx"))
clinical_data <- impute_clinical_data(raw_clinical_data) # Use imputed data
rnaseq_data <- load_rnaseq_data(file.path("Data", "CGGA.mRNAseq_325.RSEM.20200506.txt"))
combined_data <- integrate_data(clinical_data, rnaseq_data)

# Extract the aligned clinical data, VST counts, and raw counts for analysis
clinical_df <- combined_data$clinical
vst_counts <- combined_data$vst_counts
rna_counts <- combined_data$raw_counts # Use raw counts for DESeq2

# DEBUG: Check the contents of rna_counts
print(head(rna_counts[,1:5]))

cat("--- Clinical and RNA-seq data successfully integrated. ---\n")

# ===============================================================
# SECTION 2: DIFFERENTIAL EXPRESSION ANALYSIS (IDH STATUS) ----
# ===============================================================
cat("--- Performing Differential Expression Analysis (IDH status)... ---\n")

# By using the imputed clinical data, we no longer need to manually
# filter for samples with missing IDH status. The analysis can run
# on the full cohort.
dds <- DESeqDataSetFromMatrix(countData = rna_counts,
                              colData = clinical_df,
                              design = ~ IDH_mutation_status)
# Run the DESeq analysis pipeline.
dds <- DESeq(dds)
# Get the results, specifying the contrast.
res <- results(dds, contrast=c("IDH_mutation_status", "Wildtype", "Mutant"))
res_df <- as.data.frame(res)

# --- Volcano Plot ---
# This plot shows the statistical significance (p-value) vs. the
# magnitude of change (log2 fold change) for every gene.
res_df$significant <- ifelse(res_df$padj < 0.01 & abs(res_df$log2FoldChange) > 2, "Yes", "No")
p_volcano <- ggplot(res_df, aes(x = log2FoldChange, y = -log10(pvalue), color = significant)) +
  geom_point(alpha = 0.4, size = 1.5) +
  scale_color_manual(values = c("grey", "red")) +
  theme_minimal() +
  labs(title = "Volcano Plot: IDH-Wildtype vs. IDH-Mutant",
       x = "Log2 Fold Change", y = "-log10(p-value)")
print(p_volcano)
save_plot_both(p_volcano, "Lesson20_Volcano_Plot_IDH")
cat("--- Volcano plot saved to 'plots' directory. ---\n")

# ===============================================================
# SECTION 3: GENOME-WIDE UNIVARIABLE SURVIVAL ANALYSIS ----------
# This is a computationally intensive step where we fit a Cox model
# for each gene to find genes associated with survival.
# ===============================================================
cat("--- Performing genome-wide survival analysis... (This may take a few minutes) ---\n")
# NOTE: This analysis is now performed on the full cohort, as the
# 'clinical_data' object has imputed survival information.
dds_vst <- DESeqDataSetFromMatrix(countData = rna_counts, colData = clinical_df, design = ~ 1)
vsd <- vst(dds_vst, blind=TRUE)
vsd_matrix <- assay(vsd)

# Prepare the survival data.
surv_obj <- Surv(time = clinical_df$OS, event = clinical_df$Censor)

# Initialize a data frame to store results.
survival_results <- data.frame(
  gene = character(),
  hazard_ratio = numeric(),
  p_value = numeric(),
  stringsAsFactors = FALSE
)

# Set up a progress bar.
pb <- progress_bar$new(total = nrow(vsd_matrix))

# Loop through each gene.
for (i in 1:nrow(vsd_matrix)) {
  gene_name <- rownames(vsd_matrix)[i]
  gene_expression <- vsd_matrix[i, ]
  
  # --- Robustness Check ---
  # Skip genes with low variance to avoid model fitting errors.
  if (var(gene_expression) < 0.1) {
    pb$tick()
    next # Skip to the next iteration
  }
  
  # Fit the Cox model.
  fit <- tryCatch(coxph(surv_obj ~ gene_expression), error = function(e) NULL)
  
  if (!is.null(fit)) {
    summary_fit <- summary(fit)
    survival_results <- rbind(survival_results, data.frame(
      gene = gene_name,
      hazard_ratio = summary_fit$conf.int[1, "exp(coef)"],
      p_value = summary_fit$waldtest["pvalue"]
    ))
  }
  pb$tick() # Update progress bar
}

# --- NEW: Correct for Multiple Testing ---
# When running thousands of tests, many p-values will be small by chance.
# We must adjust them to control the False Discovery Rate (FDR).
survival_results$p_adj <- p.adjust(survival_results$p_value, method = "BH")

# --- Identify and Visualize the Top Prognostic Gene ---
# Find the gene with the most significant ADJUSTED p-value.
top_gene <- survival_results[which.min(survival_results$p_adj), ]
cat(paste("\n--- Top prognostic gene identified (after FDR correction):", top_gene$gene, "---\n"))

# Create a Kaplan-Meier plot for this top gene.
# Stratify patients into "High" vs "Low" expression based on the median.
top_gene_expression <- vsd_matrix[top_gene$gene, ]
expression_group <- ifelse(top_gene_expression > median(top_gene_expression), "High", "Low")
km_data <- data.frame(OS = clinical_df$OS, Censor = clinical_df$Censor, group = expression_group)
fit_km <- survfit(Surv(OS, Censor) ~ group, data = km_data)

# Use survminer to create a publication-ready KM plot.
p_km_top_gene <- ggsurvplot(fit_km, data = km_data, pval = TRUE, risk.table = TRUE,
                            title = paste("Survival by", top_gene$gene, "Expression"),
                            legend.labs = c("High", "Low"))
print(p_km_top_gene)
# Custom saving for ggsurvplot object
pdf(file.path("plots", paste0("Lesson20_KM_Plot_", top_gene$gene, ".pdf")), width = 8, height = 6)
print(p_km_top_gene)
dev.off()
cat("--- KM plot for top gene saved to 'plots' directory. ---\n")

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================
# 1. Look at the volcano plot. Are there more genes upregulated in
#    IDH-wildtype or IDH-mutant tumors?
#
# 2. Examine the Kaplan-Meier plot for the top prognostic gene. Is high
#    expression of this gene associated with better or worse survival?
#
# 3. Modify the survival analysis loop to adjust for a clinical variable,
#    like 'Grade', in the Cox model. Does the top prognostic gene change?
#    Hint: `coxph(surv_obj ~ gene_expression + clinical_data$Grade)`

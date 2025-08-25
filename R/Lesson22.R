# ===============================================================
# LESSON 23: UNCOVERING THE UNDERLYING BIOLOGY (GSEA)
# ===============================================================
#
# OBJECTIVE:
# To move beyond individual genes and discover the biological *pathways*
# that are systematically altered in high-risk tumors. This lesson
# uses Gene Set Enrichment Analysis (GSEA) to provide a biological
# narrative for our prognostic findings.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
# We add `clusterProfiler`, `msigdbr`, and `enrichplot` for enrichment analysis.
load_required_packages(c("dplyr", "ggplot2", "readxl", "DESeq2", "clusterProfiler", "msigdbr", "enrichplot"))
cat("--- LESSON 23: Uncovering Underlying Biology (GSEA) ---\n")

# ===============================================================
# SECTION 1: PREPARE DATA AND GENE LIST FOR GSEA ----------------
# ===============================================================
# Load and prepare data
raw_clinical_data <- load_clinical_data(file.path("Data", "ClinicalData.xlsx"))
clinical_data <- impute_clinical_data(raw_clinical_data) # Use imputed data
rnaseq_data <- load_rnaseq_data(file.path("Data", "CGGA.mRNAseq_325.RSEM.20200506.txt"))
combined_data <- integrate_data(clinical_data, rnaseq_data)

# Extract the aligned clinical data and raw counts for analysis
clinical_df <- combined_data$clinical
rna_counts <- combined_data$raw_counts

cat("--- Clinical and RNA-seq data successfully integrated. ---\n")

# ===============================================================
# SECTION 2: RUN DIFFERENTIAL EXPRESSION TO GET GENE RANKING ----
# ===============================================================
cat("--- Re-running differential expression to get ranked gene list... ---\n")
# NOTE: Because we are using the imputed clinical data, we no longer need
# to manually filter for samples with missing IDH status.
dds <- DESeqDataSetFromMatrix(countData = rna_counts,
                              colData = clinical_df,
                              design = ~ IDH_mutation_status)
dds <- DESeq(dds)
res <- results(dds, contrast=c("IDH_mutation_status", "Wildtype", "Mutant"))
res_df <- as.data.frame(res)

# --- Create Ranked Gene List ---
# GSEA requires a list of all genes, ranked by a metric. We will rank
# them by the `stat` column from DESeq2 (a measure of effect size and significance).
# We must also remove genes with NA p-values.
gene_list <- res_df$stat
names(gene_list) <- rownames(res_df)
gene_list <- gene_list[!is.na(gene_list)]
gene_list <- sort(gene_list, decreasing = TRUE)
cat("--- Gene list successfully ranked. ---\n")

# ===============================================================
# SECTION 2: PERFORM GENE SET ENRICHMENT ANALYSIS (GSEA) --------
# ===============================================================
cat("--- Performing GSEA on Hallmark gene sets... ---\n")
# Download the "Hallmark" gene sets from the MSigDB database. This is a
# well-curated collection of 50 key cancer-related pathways.
h_gene_sets <- msigdbr(species = "Homo sapiens", category = "H")
h_gene_sets <- dplyr::select(h_gene_sets, gs_name, gene_symbol)

# Run GSEA.
gsea_results <- GSEA(gene_list, TERM2GENE = h_gene_sets)
gsea_df <- as.data.frame(gsea_results)

# Print the top enriched pathways.
cat("--- Top 5 pathways enriched in IDH-Wildtype (high-risk) tumors: ---\n")
print(head(gsea_df[gsea_df$NES > 0, ], 5))
cat("\n--- Top 5 pathways enriched in IDH-Mutant (low-risk) tumors: ---\n")
print(head(gsea_df[gsea_df$NES < 0, ], 5))

# ===============================================================
# SECTION 3: VISUALIZE GSEA RESULTS -----------------------------
# =================================circos
# A dot plot is a great way to visualize the top enriched pathways.
# It shows the significance and the number of genes involved.
p_gsea_dotplot <- dotplot(gsea_results, showCategory = 20) +
  labs(title = "Top Enriched Hallmark Pathways (GSEA)")
print(p_gsea_dotplot)
save_plot_both(p_gsea_dotplot, "Lesson22_GSEA_Dot_Plot")

# An enrichment plot shows how the genes in a specific pathway are
# distributed in our ranked list.
p_enrichment_plot <- gseaplot2(gsea_results, geneSetID = 1, # Plot the top pathway
                               title = gsea_results$Description[1])
print(p_enrichment_plot)
save_plot_both(p_enrichment_plot[[1]], "Lesson22_GSEA_Enrichment_Plot_Top_Pathway")
cat("--- GSEA plots saved to 'plots' directory. ---\n")

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================
# 1. Look at the dot plot. What kind of biological processes are
#    associated with the high-risk (IDH-wildtype) phenotype?
#
# 2. MSigDB contains many other gene set collections. Try re-running this
#    analysis using a different category, like "C2" (curated gene sets)
#    which includes pathways from KEGG and Reactome.
#    Hint: `msigdbr(species = "Homo sapiens", category = "C2")`
#
# 3. Change the ranking metric. Instead of the `stat` column, try ranking
#    the genes by `log2FoldChange`. Does this change the results?

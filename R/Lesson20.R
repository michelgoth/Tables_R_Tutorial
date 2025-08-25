# ===============================================================
# LESSON 20: EXPLORATORY ANALYSIS OF TRANSCRIPTOMIC DATA (PCA)
# ===============================================================
#
# OBJECTIVE:
# To perform a primary exploratory analysis of the high-dimensional
# RNA-seq data using Principal Component Analysis (PCA). This is the
# most fundamental first step in any transcriptomic analysis to
# understand the major drivers of variation in the data and to
# perform a high-level quality control check.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
# We add DESeq2 for its robust data structures and normalization/transformation tools.
load_required_packages(c("dplyr", "ggplot2", "readxl", "DESeq2"))
cat("--- LESSON 20: Exploratory Transcriptomic Analysis (PCA) ---\n")

# ===============================================================
# SECTION 1: LOAD AND INTEGRATE CLINICAL AND RNA-SEQ DATA -------
# ===============================================================
# Load clinical data.
clinical_data <- load_clinical_data("Data/ClinicalData.xlsx")

# Load RNA-seq data. This is a large matrix of gene expression values.
# The `data.table::fread` function is used for its speed with large files.
cat("--- Loading RNA-seq data... ---\n")
rna_data <- data.table::fread("Data/CGGA.mRNAseq_325.RSEM.20200506.txt")

# --- Data Wrangling ---
# The RNA-seq data needs to be reshaped to be compatible with our tools.
# 1. Convert to a data frame and set gene names as row names.
# 2. Transpose the matrix so that samples are rows and genes are columns.
# 3. Align the sample IDs between the clinical and RNA data.
rna_df <- as.data.frame(rna_data)
rownames(rna_df) <- rna_df$Gene_Name
rna_df$Gene_Name <- NULL

# Ensure all expression values are numeric integers for DESeq2.
# We round the RSEM values to the nearest integer.
rna_counts <- round(rna_df)

# Match samples between clinical and RNA data.
common_samples <- intersect(clinical_data$CGGA_ID, colnames(rna_counts))
clinical_data <- clinical_data[clinical_data$CGGA_ID %in% common_samples, ]
rna_counts <- rna_counts[, common_samples]

# Re-order clinical data rows to match the column order in rna_counts.
clinical_data <- clinical_data[match(colnames(rna_counts), clinical_data$CGGA_ID), ]
rownames(clinical_data) <- clinical_data$CGGA_ID

# Check for alignment. This should be TRUE.
stopifnot(all(colnames(rna_counts) == rownames(clinical_data)))
cat("--- Clinical and RNA-seq data successfully integrated. ---\n")

# ===============================================================
# SECTION 2: DATA TRANSFORMATION AND PCA ------------------------
# We use DESeq2 to create a data object and perform a variance
# stabilizing transformation (vst), which is ideal for visualization methods
# like PCA.
# ===============================================================
cat("--- Performing variance stabilizing transformation... ---\n")
# Create a minimal DESeqDataSet object. The design formula `~ 1` means
# we are not testing for differences yet.
dds <- DESeqDataSetFromMatrix(countData = rna_counts,
                              colData = clinical_data,
                              design = ~ 1)

# The vst function transforms the raw counts to make them more homoscedastic.
vsd <- vst(dds, blind = TRUE)

# --- Perform PCA ---
# The plotPCA function from DESeq2 is a convenient wrapper.
# We specify the clinical variables we want to color the points by.
cat("--- Generating PCA plots... ---\n")
p1 <- plotPCA(vsd, intgroup = "IDH_mutation_status") +
  labs(title = "PCA of Tumor Samples by IDH Status") + theme_minimal()
p2 <- plotPCA(vsd, intgroup = "Grade") +
  labs(title = "PCA of Tumor Samples by WHO Grade") + theme_minimal()
p3 <- plotPCA(vsd, intgroup = "MGMTp_methylation_status") +
  labs(title = "PCA of Tumor Samples by MGMT Status") + theme_minimal()

# Print plots to the console
print(p1)
print(p2)
print(p3)

# Save plots
save_plot_both(p1, "Lesson20_PCA_by_IDH")
save_plot_both(p2, "Lesson20_PCA_by_Grade")
save_plot_both(p3, "Lesson20_PCA_by_MGMT")
cat("--- PCA plots saved to the 'plots' directory. ---\n")

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================
# 1. Look at the three PCA plots. Which clinical variable shows the
#    clearest separation between groups? What does this tell you
#    about the main driver of gene expression differences in this cohort?
#
# 2. Try coloring the PCA plot by a different variable, such as 'PRS_type'
#    or 'Gender'. Do these variables show a clear separation?
#    Hint: `plotPCA(vsd, intgroup = "Gender")`
#
# 3. PCA only shows the first two principal components. You can access the
#    underlying data and plot PC3 vs PC4 to see if other patterns emerge.
#    Hint: `pcaData <- plotPCA(vsd, returnData=TRUE)` then use ggplot on pcaData.

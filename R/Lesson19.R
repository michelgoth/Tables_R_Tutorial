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
# Load and prepare data
raw_clinical_data <- load_clinical_data(file.path("Data", "ClinicalData.xlsx"))
clinical_data <- impute_clinical_data(raw_clinical_data) # Use imputed data
rnaseq_data <- load_rnaseq_data(file.path("Data", "CGGA.mRNAseq_325.RSEM.20200506.txt"))
combined_data <- integrate_data(clinical_data, rnaseq_data)

# Extract the aligned clinical data and the DESeqTransform object
clinical_df <- combined_data$clinical
vsd <- combined_data$vsd # Use the vsd object directly

cat("--- Clinical and RNA-seq data successfully integrated. ---\n")

# ===============================================================
# SECTION 2: PCA VISUALIZATION ----------------------------------
# ===============================================================
cat("--- Generating PCA plots... ---\n")

# The plotPCA function from DESeq2 is a convenient wrapper that uses the vsd object.
# We specify the clinical variables we want to color the points by.
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
save_plot_both(p1, "Lesson19_PCA_by_IDH")
save_plot_both(p2, "Lesson19_PCA_by_Grade")
save_plot_both(p3, "Lesson19_PCA_by_MGMT")
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

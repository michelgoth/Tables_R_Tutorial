# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")[["CRAN"]])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# List of required packages
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", 
                       "corrplot", "car", "psych", "ggpubr", "rstatix")

# Install missing packages
installed <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!(pkg %in% installed)) {
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
    }, error = function(e) {
      cat(sprintf("Failed to install %s: %s\n", pkg, e$message))
    })
  }
}

# Load libraries
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    cat(sprintf("Failed to load package: %s\n", pkg))
  }
}

# Data file path
DATA_PATH <- "Data/ClinicalData.xlsx"
if (!file.exists(DATA_PATH)) {
  stop(paste0("ERROR: Data file not found at ", DATA_PATH, ". Please ensure the file exists."))
}

# Load the data
suppressWarnings({
  data <- tryCatch({
    readxl::read_excel(DATA_PATH)
  }, error = function(e) {
    stop(paste0("ERROR: Could not read data file: ", e$message))
  })
})

# Convert key columns to appropriate types (if present)
if ("Grade" %in% names(data)) data$Grade <- as.factor(data$Grade)
if ("Gender" %in% names(data)) data$Gender <- as.factor(data$Gender)
if ("PRS_type" %in% names(data)) data$PRS_type <- as.factor(data$PRS_type)
if ("IDH_mutation_status" %in% names(data)) data$IDH_mutation_status <- as.factor(data$IDH_mutation_status)
if ("MGMTp_methylation_status" %in% names(data)) data$MGMTp_methylation_status <- as.factor(data$MGMTp_methylation_status)
if ("Histology" %in% names(data)) data$Histology <- as.factor(data$Histology)

# ===============================================================
# LESSON 7: ASSOCIATION TESTS (CHI-SQUARE & FISHER'S EXACT)
# ===============================================================

# LEARNING OBJECTIVES:
# - Test relationships between two categorical variables
# - Use Chi-square or Fisher's exact test appropriately
# - Interpret test results in a clinical context

# WHAT YOU'LL LEARN:
# Association tests help us evaluate whether two categorical features
# are statistically related — for example, does IDH mutation status
# vary significantly with Tumor Grade?

# SECTION 1: CHI-SQUARE TEST ----------------------------------

# Compare IDH mutation status across Tumor Grade
if (all(c("IDH_mutation_status", "Grade") %in% names(data))) {
  table_idh_grade <- table(data$IDH_mutation_status, data$Grade)
  print(chisq.test(table_idh_grade))
} else {
  cat("Required columns 'IDH_mutation_status' and/or 'Grade' not found in data.\n")
}

# Interpretation:
# - A small p-value (e.g., < 0.05) suggests the variables are associated
# - Check expected counts in the output to ensure test validity

# SECTION 2: FISHER'S EXACT TEST ------------------------------

# Use Fisher's Exact Test when sample sizes are small or expected frequencies < 5
if (all(c("Gender", "MGMTp_methylation_status") %in% names(data))) {
  print(fisher.test(table(data$Gender, data$MGMTp_methylation_status)))
} else {
  cat("Required columns 'Gender' and/or 'MGMTp_methylation_status' not found in data.\n")
}

# TIP:
# - Chi-Square works well with large datasets
# - Fisher's is more accurate with small sample sizes or sparse data

# PRACTICE TASKS ----------------------------------------------

# 1. Test association between PRS_type and Chemo_status
#    Hint: Use table() and apply chisq.test()

# 2. When should you use Fisher's test instead of Chi-square?

# 3. Try an association test between Radio_status and Grade

# 4. OPTIONAL: Use ggbarplot (from ggpubr) to visualize proportions
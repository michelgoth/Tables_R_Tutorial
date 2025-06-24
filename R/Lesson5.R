# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")[["CRAN"]])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# List of required packages
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", 
                       "corrplot", "car", "psych", "ggpubr", "rstatix", "survival")

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
if ("OS" %in% names(data)) data$OS <- as.numeric(data$OS)
if ("Censor (alive=0; dead=1)" %in% names(data)) data$`Censor (alive=0; dead=1)` <- as.numeric(data$`Censor (alive=0; dead=1)`)

# ===============================================================
# LESSON 5: STATISTICAL COMPARISON WITH LOG-RANK TEST
# ===============================================================

# LEARNING OBJECTIVES:
# - Understand the purpose of the log-rank test
# - Compare survival distributions between groups
# - Interpret p-values from survival analysis

# WHAT YOU'LL LEARN:
# Kaplan-Meier plots visualize survival, but are the differences significant?
# The log-rank test statistically compares survival curves between two or more groups.

# SECTION 1: RUNNING LOG-RANK TEST ----------------------------

# Compare survival between IDH mutation groups
if (all(c("OS", "Censor (alive=0; dead=1)", "IDH_mutation_status") %in% names(data))) {
  logrank_idh <- survdiff(Surv(OS, `Censor (alive=0; dead=1)`) ~ IDH_mutation_status, data = data)
  print(logrank_idh)
} else {
  cat("Required columns for IDH log-rank test not found in data.\n")
}

# Compare survival between MGMT methylation groups
if (all(c("OS", "Censor (alive=0; dead=1)", "MGMTp_methylation_status") %in% names(data))) {
  logrank_mgmt <- survdiff(Surv(OS, `Censor (alive=0; dead=1)`) ~ MGMTp_methylation_status, data = data)
  print(logrank_mgmt)
} else {
  cat("Required columns for MGMT log-rank test not found in data.\n")
}

# Interpretation:
# - A large test statistic with a small p-value suggests a significant difference in survival
# - This test assumes proportional hazards

# PRACTICE TASKS ----------------------------------------------

# 1. Perform a log-rank test comparing PRS_type
#    survdiff(Surv(OS, Censor) ~ PRS_type, data = data)

# 2. Try the test on Tumor Grade or Histology

# 3. For each test, interpret:
#    - What does the p-value suggest?
#    - Which group appears to have better survival?

# 4. BONUS: Plot KM curves side-by-side with log-rank results for context
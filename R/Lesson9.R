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
if ("Age" %in% names(data)) data$Age <- as.numeric(data$Age)

# ===============================================================
# LESSON 9: LOGISTIC REGRESSION FOR BINARY OUTCOMES
# ===============================================================

# LEARNING OBJECTIVES:
# - Build a logistic regression model
# - Interpret coefficients and p-values
# - Predict binary outcomes like mutation or treatment status

# WHAT YOU'LL LEARN:
# Logistic regression is used when your outcome variable is binary (e.g., Mutant vs Wildtype).
# This lesson teaches you how to model outcomes using clinical predictors.

# SECTION 1: FIT A LOGISTIC MODEL -----------------------------

# Check if required columns exist
required_cols <- c("IDH_mutation_status", "Age", "Gender", "Grade", "MGMTp_methylation_status")
missing_cols <- required_cols[!required_cols %in% names(data)]

if (length(missing_cols) > 0) {
  cat("Warning: Missing columns for logistic model:", paste(missing_cols, collapse = ", "), "\n")
  cat("Proceeding with available columns...\n")
}

# Model the probability of having an IDH mutation
tryCatch({
  logit_model <- glm(IDH_mutation_status ~ Age + Gender + Grade + MGMTp_methylation_status,
                     data = data, family = "binomial")
  
  # View the model summary
  print(summary(logit_model))
}, error = function(e) {
  cat("Error fitting logistic model:", e$message, "\n")
  cat("This may be due to missing data, insufficient sample size, or perfect separation.\n")
})

# Interpreting Output:
# - Coefficients: log odds (use exp() to interpret as odds ratios)
# - p-values: indicate significance of each predictor

# Example:
# exp(coef(logit_model))       # Converts log-odds to odds ratios

# PRACTICE TASKS ----------------------------------------------

# 1. Which predictors are statistically significant (p < 0.05)?

# 2. Interpret the sign of each coefficient:
#    - Does higher age increase or decrease odds of IDH mutation?

# 3. Try building a new logistic model to predict MGMTp_methylation_status

# 4. Optional: Use `predict()` with `type = "response"` to get probabilities
#    Example: predict(logit_model, type = "response")
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
if ("Age" %in% names(data)) data$Age <- as.numeric(data$Age)
if ("Chemo_status (TMZ treated=1;un-treated=0)" %in% names(data)) data$`Chemo_status (TMZ treated=1;un-treated=0)` <- as.numeric(data$`Chemo_status (TMZ treated=1;un-treated=0)`)
if ("Radio_status (treated=1;un-treated=0)" %in% names(data)) data$`Radio_status (treated=1;un-treated=0)` <- as.numeric(data$`Radio_status (treated=1;un-treated=0)`)

# ===============================================================
# LESSON 6: MULTIVARIABLE SURVIVAL ANALYSIS WITH COX MODEL
# ===============================================================

# LEARNING OBJECTIVES:
# - Understand how to use the Cox proportional hazards model
# - Model survival using multiple covariates
# - Interpret hazard ratios (HR) and statistical significance

# WHAT YOU'LL LEARN:
# The Cox model allows us to estimate how several clinical variables
# jointly affect the hazard (risk) of an event (e.g., death).
# It provides hazard ratios, which reflect how much a variable increases or decreases risk.

# SECTION 1: BUILD COX MODEL ----------------------------------

# Check if required columns exist
required_cols <- c("OS", "Censor (alive=0; dead=1)", "Age", "Gender", "Grade", 
                   "IDH_mutation_status", "MGMTp_methylation_status", "PRS_type", 
                   "Chemo_status (TMZ treated=1;un-treated=0)", "Radio_status (treated=1;un-treated=0)")

missing_cols <- required_cols[!required_cols %in% names(data)]
if (length(missing_cols) > 0) {
  cat("Warning: Missing columns for Cox model:", paste(missing_cols, collapse = ", "), "\n")
  cat("Proceeding with available columns...\n")
}

# Fit a multivariate Cox model using clinical predictors
tryCatch({
  cox_model <- coxph(Surv(OS, `Censor (alive=0; dead=1)`) ~ Age + Gender + Grade + 
                       IDH_mutation_status + MGMTp_methylation_status +
                       PRS_type + `Chemo_status (TMZ treated=1;un-treated=0)` + `Radio_status (treated=1;un-treated=0)`, 
                     data = data)
  
  # View model summary
  print(summary(cox_model))
}, error = function(e) {
  cat("Error fitting Cox model:", e$message, "\n")
  cat("This may be due to missing data or insufficient sample size.\n")
})

# Key Output Components:
# - coef: log hazard ratios
# - exp(coef): hazard ratio (HR)
# - p-value: significance of predictor
# - Concordance: model predictive ability

# TIP:
# HR > 1 → Higher risk; HR < 1 → Lower risk

# PRACTICE TASKS ----------------------------------------------

# 1. Which variables are statistically significant? (p < 0.05)

# 2. Interpret the hazard ratio for Age:
#    - Is older age associated with increased or decreased hazard?

# 3. Interpret the hazard ratio for IDH mutation:
#    - Does having a mutation reduce the risk of death?

# 4. Remove a variable (e.g., PRS_type) and re-run the model:
#    - How do other coefficients change?

# 5. OPTIONAL: Use `ggforest(cox_model, data = data)` from survminer
#    to visualize the hazard ratios as a forest plot.
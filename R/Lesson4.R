# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")[["CRAN"]])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# List of required packages
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", 
                       "corrplot", "car", "psych", "ggpubr", "rstatix", "survival", "survminer")

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
# LESSON 4: SURVIVAL ANALYSIS WITH KAPLAN-MEIER CURVES
# ===============================================================

# LEARNING OBJECTIVES:
# - Understand and construct Kaplan-Meier survival curves
# - Compare survival between patient groups
# - Use ggsurvplot for clean visualization

#  WHAT YOU'LL LEARN:
# The Kaplan-Meier estimator helps visualize how survival probability 
# changes over time. You'll learn how to compare survival based on key 
# features like IDH mutation or treatment status.

# REQUIREMENTS:
# Make sure the `survival` and `survminer` packages are loaded.

# SECTION 1: CREATE SURVIVAL OBJECT ----------------------------

# The Surv() function creates a survival object using OS and Censoring
# OS = Overall Survival Time
# Censor = 0 for alive, 1 for dead
if (all(c("OS", "Censor (alive=0; dead=1)") %in% names(data))) {
  surv_obj <- Surv(time = as.numeric(data$OS), event = data$`Censor (alive=0; dead=1)`)
} else {
  stop("ERROR: Required columns 'OS' and/or 'Censor (alive=0; dead=1)' not found in data.")
}

# SECTION 2: KAPLAN-MEIER FIT ----------------------------------

# Compare survival between IDH mutation statuses
if ("IDH_mutation_status" %in% names(data)) {
  fit_idh <- survfit(surv_obj ~ IDH_mutation_status, data = data)
  # Plot Kaplan-Meier curve
  print(
    ggsurvplot(
      fit_idh,
      data = data,
      pval = TRUE,             # Show p-value from log-rank test
      risk.table = TRUE,       # Show number at risk below the plot
      title = "Survival by IDH Mutation Status",
      xlab = "Time (days)",
      ylab = "Survival Probability"
    )
  )
} else {
  cat("Column 'IDH_mutation_status' not found in data.\n")
}

# PRACTICE TASKS ----------------------------------------------

# 1. Plot a KM curve for MGMTp_methylation_status
#    Hint: change the variable in the formula: survfit(surv_obj ~ ...)

# 2. Interpret the plot:
#    - Which group survives longer on average?
#    - What does the p-value tell you?

# 3. Try grouping by PRS_type or Grade and observe differences.

# 4. Optional: Try setting `conf.int = TRUE` in ggsurvplot()
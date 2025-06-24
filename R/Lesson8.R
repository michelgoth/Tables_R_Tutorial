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
if ("OS" %in% names(data)) data$OS <- as.numeric(data$OS)

# ===============================================================
# LESSON 8: COMPARING NUMERIC VARIABLES ACROSS GROUPS
# ===============================================================

# LEARNING OBJECTIVES:
# - Compare continuous variables across categories
# - Use the Wilcoxon test or t-test appropriately
# - Interpret p-values in clinical context

# WHAT YOU'LL LEARN:
# Do patients with different mutation statuses or treatment groups have
# different survival times or ages? In this lesson, you'll compare numeric
# outcomes (like Age or OS) across groups using statistical tests.

# SECTION 1: WILCOXON RANK-SUM TEST ---------------------------

# Compare Age between IDH mutation statuses (non-parametric test)
if (all(c("Age", "IDH_mutation_status") %in% names(data))) {
  # Check if we have exactly 2 groups for Wilcoxon test
  idh_levels <- levels(data$IDH_mutation_status)
  idh_levels <- idh_levels[!is.na(idh_levels)]
  
  if (length(idh_levels) == 2) {
    print(wilcox.test(Age ~ IDH_mutation_status, data = data))
  } else {
    cat("Wilcoxon test requires exactly 2 groups. IDH_mutation_status has", length(idh_levels), "levels:", paste(idh_levels, collapse = ", "), "\n")
    cat("Consider filtering data to compare specific groups.\n")
  }
} else {
  cat("Required columns 'Age' and/or 'IDH_mutation_status' not found in data.\n")
}

# Compare OS between MGMT methylation groups
if (all(c("OS", "MGMTp_methylation_status") %in% names(data))) {
  # Check if we have exactly 2 groups for Wilcoxon test
  mgmt_levels <- levels(data$MGMTp_methylation_status)
  mgmt_levels <- mgmt_levels[!is.na(mgmt_levels)]
  
  if (length(mgmt_levels) == 2) {
    print(wilcox.test(OS ~ MGMTp_methylation_status, data = data))
  } else {
    cat("Wilcoxon test requires exactly 2 groups. MGMTp_methylation_status has", length(mgmt_levels), "levels:", paste(mgmt_levels, collapse = ", "), "\n")
    cat("Consider filtering data to compare specific groups.\n")
  }
} else {
  cat("Required columns 'OS' and/or 'MGMTp_methylation_status' not found in data.\n")
}

# 💡 TIP:
# Use Wilcoxon when your data is not normally distributed

# SECTION 2: T-TEST (OPTIONAL) --------------------------------

# Compare OS using a parametric test (assumes normality)
if (all(c("OS", "MGMTp_methylation_status") %in% names(data))) {
  # Check if we have exactly 2 groups for t-test
  mgmt_levels <- levels(data$MGMTp_methylation_status)
  mgmt_levels <- mgmt_levels[!is.na(mgmt_levels)]
  
  if (length(mgmt_levels) == 2) {
    print(t.test(OS ~ MGMTp_methylation_status, data = data))
  } else {
    cat("T-test requires exactly 2 groups. MGMTp_methylation_status has", length(mgmt_levels), "levels:", paste(mgmt_levels, collapse = ", "), "\n")
    cat("Consider filtering data to compare specific groups.\n")
  }
} else {
  cat("Required columns 'OS' and/or 'MGMTp_methylation_status' not found in data.\n")
}

# PRACTICE TASKS ----------------------------------------------

# 1. Compare OS across PRS_type using:
#    - Wilcoxon test
#    - t-test
#
# 2. Compare Age between Grade III and Grade IV tumors (if applicable)

# 3. Try plotting boxplots for the comparisons you made above:
#    Hint: use ggplot + geom_boxplot()

# 4. When would you prefer a t-test over a Wilcoxon test?
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
# LESSON 3: CLINICAL FEATURE VISUALIZATION
# ===============================================================

# LEARNING OBJECTIVES:
# - Visualize relationships between categorical clinical variables
# - Customize plots using ggplot2
# - Interpret bar charts for group comparisons

# WHAT YOU'LL LEARN:
# Bar plots are excellent for showing counts and proportions of categorical features.
# In this lesson, you'll learn how to visualize the distribution of features like
# Tumor Grade, PRS Type, and molecular markers (e.g., IDH status).

# SECTION 1: BAR PLOTS FOR CATEGORICAL COMPARISONS -----------

# Tumor Grade across PRS Type
if (all(c("Grade", "PRS_type") %in% names(data))) {
  print(
    ggplot(data, aes(x = Grade, fill = PRS_type)) +
      geom_bar(position = "dodge") +
      labs(title = "Tumor Grade by PRS Type",
           x = "Tumor Grade", y = "Count") +
      theme_minimal()
  )
} else {
  cat("Required columns 'Grade' and/or 'PRS_type' not found in data.\n")
}

# IDH Mutation Status across Gender
if (all(c("IDH_mutation_status", "Gender") %in% names(data))) {
  print(
    ggplot(data, aes(x = IDH_mutation_status, fill = Gender)) +
      geom_bar(position = "dodge") +
      labs(title = "IDH Status by Gender",
           x = "IDH Mutation Status", y = "Count") +
      theme_minimal()
  )
} else {
  cat("Required columns 'IDH_mutation_status' and/or 'Gender' not found in data.\n")
}

# PRACTICE TASKS ----------------------------------------------

# 1. Visualize Histology by PRS_type
#    Hint: Use aes(x = Histology, fill = PRS_type)

# 2. Create a bar chart of MGMT methylation status by Grade
#    Hint: Try fill = MGMTp_methylation_status and position = "dodge"

# 3. Try position = "fill" to show proportions instead of counts

# 4. Add themes, labels, and color palettes to make your plots presentation-ready
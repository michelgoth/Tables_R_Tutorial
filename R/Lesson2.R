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
if ("Age" %in% names(data)) data$Age <- as.numeric(data$Age)

# ===============================================================
# LESSON 2: DESCRIPTIVE STATISTICS & DISTRIBUTIONS
# ===============================================================

# LEARNING OBJECTIVES:
# - Summarize clinical data using descriptive statistics
# - Explore variable distributions
# - Use visualizations to describe patterns

# WHAT YOU'LL LEARN:
# In this version of Lesson 2, we'll focus on describing the data.
# You'll learn how to explore distributions and counts using both
# summary statistics and visualizations.

# SECTION 1: DESCRIPTIVE STATISTICS ---------------------------

# Summary statistics for continuous variables
if ("Age" %in% names(data)) {
  print(summary(data$Age))
} else {
  cat("Column 'Age' not found in data.\n")
}

# Frequency tables for categorical variables
if ("Gender" %in% names(data)) print(table(data$Gender))
if ("Grade" %in% names(data)) print(table(data$Grade))
if ("IDH_mutation_status" %in% names(data)) print(table(data$IDH_mutation_status))

# SECTION 2: VISUALIZE DISTRIBUTIONS ---------------------------

if (all(c("Age", "Gender") %in% names(data))) {
  print(
    ggplot(data, aes(x = Age, fill = Gender)) +
      geom_histogram(binwidth = 5, alpha = 0.6, position = "identity") +
      theme_minimal() +
      labs(title = "Age Distribution by Gender", x = "Age", y = "Count")
  )
}

# PRACTICE TASKS ----------------------------------------------

# 1. Create a histogram for OS (Overall Survival)
#    Hint: aes(x = OS), use similar code to Age histogram

# 2. Which Tumor Grade is most common? Use table() or bar plot.

# 3. Compare Age distributions between PRS_type groups
#    Hint: Try using `facet_wrap(~ PRS_type)` or use `fill = PRS_type`

# 4. BONUS: Try summarizing Age by Grade using group_by() + summarise()
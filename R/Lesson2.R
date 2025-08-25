# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# Use utilities for loading packages and data
source("R/utils.R")
load_required_packages(c("readxl", "ggplot2", "dplyr"))

data <- load_clinical_data("Data/ClinicalData.xlsx")
data_age_gender <- filter_complete_cases(data, c("Age", "Gender"))

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

if (all(c("Age", "Gender") %in% names(data_age_gender))) {
  p <- ggplot(data_age_gender, aes(x = Age, fill = Gender)) +
    geom_histogram(binwidth = 5, alpha = 0.6, position = "identity") +
    theme_minimal() +
    labs(title = "Age Distribution by Gender", x = "Age", y = "Count")
  print(p)
  save_plot_both(p, base_filename = "Lesson2_Age_by_Gender")
}

# PRACTICE TASKS ----------------------------------------------

# 1. Create a histogram for OS (Overall Survival)
#    Hint: aes(x = OS), use similar code to Age histogram

# 2. Which Tumor Grade is most common? Use table() or bar plot.

# 3. Compare Age distributions between PRS_type groups
#    Hint: Try using `facet_wrap(~ PRS_type)` or use `fill = PRS_type`

# 4. BONUS: Try summarizing Age by Grade using group_by() + summarise()
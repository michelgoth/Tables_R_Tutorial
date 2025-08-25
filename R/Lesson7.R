# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

source("R/utils.R")
load_required_packages(c("readxl", "ggplot2"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# ===============================================================
# LESSON 7: ASSOCIATION TESTS (CHI-SQUARE & FISHER'S EXACT)
# ===============================================================

# LEARNING OBJECTIVES:
# - Test relationships between two categorical variables
# - Use Chi-square or Fisher's exact test appropriately
# - Interpret test results in a clinical context

# SECTION 1: CHI-SQUARE TEST ----------------------------------

if (all(c("IDH_mutation_status", "Grade") %in% names(data))) {
  table_idh_grade <- table(data$IDH_mutation_status, data$Grade)
  print(chisq.test(table_idh_grade))
  # Save a grouped bar plot
  p <- ggplot(data, aes(x = Grade, fill = IDH_mutation_status)) +
    geom_bar(position = "dodge") +
    labs(title = "IDH Status by Tumor Grade", x = "Grade", y = "Count") +
    theme_minimal()
  print(p)
  save_plot_both(p, base_filename = "Lesson7_IDH_by_Grade")
} else {
  cat("Required columns 'IDH_mutation_status' and/or 'Grade' not found in data.\n")
}

# SECTION 2: FISHER'S EXACT TEST ------------------------------

if (all(c("Gender", "MGMTp_methylation_status") %in% names(data))) {
  print(fisher.test(table(data$Gender, data$MGMTp_methylation_status)))
}

# PRACTICE TASKS ----------------------------------------------
# 1. Test association between PRS_type and Chemo_status
# 2. When should you use Fisher's test instead of Chi-square?
# 3. Test association between Radio_status and Grade
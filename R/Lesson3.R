# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

source("R/utils.R")
load_required_packages(c("readxl", "ggplot2", "dplyr"))

data <- load_clinical_data("Data/ClinicalData.xlsx")
data_grade_prs <- filter_complete_cases(data, c("Grade", "PRS_type"))
data_idh_gender <- filter_complete_cases(data, c("IDH_mutation_status", "Gender"))

# ===============================================================
# LESSON 3: CLINICAL FEATURE VISUALIZATION
# ===============================================================

# LEARNING OBJECTIVES:
# - Visualize relationships between categorical clinical variables
# - Customize plots using ggplot2
# - Interpret bar charts for group comparisons

# SECTION 1: BAR PLOTS FOR CATEGORICAL COMPARISONS -----------

# Tumor Grade across PRS Type
if (all(c("Grade", "PRS_type") %in% names(data_grade_prs))) {
  p1 <- ggplot(data_grade_prs, aes(x = Grade, fill = PRS_type)) +
    geom_bar(position = "dodge") +
    labs(title = "Tumor Grade by PRS Type",
         x = "Tumor Grade", y = "Count") +
    theme_minimal()
  print(p1)
  save_plot_both(p1, base_filename = "Lesson3_Grade_by_PRS")
} else {
  cat("Required columns 'Grade' and/or 'PRS_type' not found in data.\n")
}

# IDH Mutation Status across Gender
if (all(c("IDH_mutation_status", "Gender") %in% names(data_idh_gender))) {
  p2 <- ggplot(data_idh_gender, aes(x = IDH_mutation_status, fill = Gender)) +
    geom_bar(position = "dodge") +
    labs(title = "IDH Status by Gender",
         x = "IDH Mutation Status", y = "Count") +
    theme_minimal()
  print(p2)
  save_plot_both(p2, base_filename = "Lesson3_IDH_by_Gender")
} else {
  cat("Required columns 'IDH_mutation_status' and/or 'Gender' not found in data.\n")
}

# PRACTICE TASKS ----------------------------------------------
# 1. Visualize Histology by PRS_type
# 2. Create a bar chart of MGMT methylation status by Grade
# 3. Try position = "fill" to show proportions instead of counts
# 4. Add themes, labels, and color palettes to make your plots presentation-ready
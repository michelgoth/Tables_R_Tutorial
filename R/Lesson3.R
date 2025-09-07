# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# ===============================================================
# LESSON 3: VISUALIZING ASSOCIATIONS BETWEEN CATEGORICAL VARIABLES
# ===============================================================
#
# OBJECTIVE:
# To learn how to visualize the relationship between two categorical
# clinical variables using grouped bar charts. This is a fundamental
# step for understanding the composition of a cohort and identifying
# potential associations that warrant further statistical testing.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
load_required_packages(c("readxl", "ggplot2", "dplyr"))

# Load and impute the clinical data
raw_data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- impute_clinical_data(raw_data)

# ===============================================================
# SECTION 1: GROUPED BAR PLOTS FOR CATEGORICAL COMPARISONS ----
# ===============================================================

# --- Plot 1: Tumor Grade by Presentation Type (PRS) ---
# A grouped bar plot helps us see the counts of one variable, broken
# down by the categories of another variable.
if (all(c("Grade", "PRS_type") %in% names(data))) {
  p1 <- ggplot(data, aes(x = Grade, fill = PRS_type)) +
    # 'x = Grade' sets the variable for the x-axis.
    # 'fill = PRS_type' tells ggplot to color the bars based on the PRS_type,
    # and it will automatically create a legend.
    # 'position = "dodge"' places the bars for each PRS_type next to
    # each other within each Grade category.
    geom_bar(position = "dodge") +
    labs(title = "Tumor Grade by Presentation Type",
         x = "WHO Tumor Grade", y = "Number of Patients") +
    theme_minimal()
  print(p1)
  save_plot_both(p1, base_filename = "Lesson3_Grade_by_PRS")
} else {
  cat("Required columns 'Grade' and/or 'PRS_type' not found in data.\n")
}

# --- Plot 2: IDH Mutation Status by Gender ---
# Here we do the same thing to compare the number of IDH mutant vs.
# wildtype cases between male and female patients.
if (all(c("IDH_mutation_status", "Gender") %in% names(data))) {
  p2 <- ggplot(data, aes(x = IDH_mutation_status, fill = Gender)) +
    geom_bar(position = "dodge") +
    labs(title = "IDH Mutation Status by Gender",
         x = "IDH Mutation Status", y = "Number of Patients") +
    theme_minimal()
  print(p2)
  save_plot_both(p2, base_filename = "Lesson3_IDH_by_Gender")
} else {
  cat("Required columns 'IDH_mutation_status' and/or 'Gender' not found in data.\n")
}

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================

# 1. Visualize the distribution of 'Histology' for each 'PRS_type'.
if (all(c("Histology", "PRS_type") %in% names(data))) {
  p3 <- ggplot(data, aes(x = Histology, fill = PRS_type)) +
    geom_bar(position = "dodge") +
    labs(title = "Tumor Histology by Presentation Type",
         x = "Tumor Histology", y = "Number of Patients") +
    theme_minimal()
  print(p3)
  save_plot_both(p3, base_filename = "Lesson3_Histology_by_PRS")
} else {
  cat("Required columns 'Histology' and/or 'PRS_type' not found in data.\n")
}

# 2. Create a bar chart showing 'MGMTp_methylation_status' broken down by 'Grade'.
if (all(c("MGMTp_methylation_status", "Grade") %in% names(data))) {
  p4 <- ggplot(data, aes(x = MGMTp_methylation_status, fill = Grade)) +
    geom_bar(position = "dodge") +
    labs(title = "Tumor MGMTp_methylation_status by Grade",
         x = "MGMTp_methylation_status", y = "Number of Patients") +
    theme_minimal()
  print(p4)
  save_plot_both(p4, base_filename = "Lesson3_MGMTp_methylation_status_by_Grade")
} else {
  cat("Required columns 'MGMTp_methylation_status' and/or 'Grade' not found in data.\n")
}
# 3. In one of your new plots, try changing `position = "dodge"` to
#    `position = "fill"`. This will show the proportions of the 'fill'
#    variable within each x-axis category, rather than the raw counts.
if (all(c("MGMTp_methylation_status", "Grade") %in% names(data))) {
  p5 <- ggplot(data, aes(x = MGMTp_methylation_status, fill = Grade)) +
    geom_bar(position = "fill") +
    labs(title = "Tumor MGMTp_methylation_status by Grade",
         x = "MGMTp_methylation_status", y = "Number of Patients") +
    theme_minimal()
  print(p5)
  save_plot_both(p5, base_filename = "Lesson3_MGMTp_methylation_status_by_Grade_fill")
} else {
  cat("Required columns 'MGMTp_methylation_status' and/or 'Grade' not found in data.\n")
}

# 4. Make one of your plots "publication-ready" by adding a custom theme,
#    more descriptive labels, and a different color palette.
#    Hint: try adding `+ theme_classic()` or `+ scale_fill_viridis_d()`
if (all(c("MGMTp_methylation_status", "Grade") %in% names(data))) {
  p6 <- ggplot(data, aes(x = MGMTp_methylation_status, fill = Grade)) +
    geom_bar(position = "dodge") +
    labs(title = "Tumor MGMTp_methylation_status by Grade",
         x = "MGMTp_methylation_status", y = "Number of Patients") +
    theme_classic()
  print(p6)
  save_plot_both(p6, base_filename = "Lesson3_MGMTp_methylation_status_by_Grade_classic")
} else {
  cat("Required columns 'MGMTp_methylation_status' and/or 'Grade' not found in data.\n")
}

if (all(c("MGMTp_methylation_status", "Grade") %in% names(data))) {
  p7 <- ggplot(data, aes(x = MGMTp_methylation_status, fill = Grade)) +
    geom_bar(position = "dodge") +
    labs(title = "Tumor MGMTp_methylation_status by Grade",
         x = "MGMTp_methylation_status", y = "Number of Patients") +
    scale_fill_viridis_d()
    theme_minimal()
  print(p7)
  save_plot_both(p7, base_filename = "Lesson3_MGMTp_methylation_status_by_Grade_viridis")
} else {
  cat("Required columns 'MGMTp_methylation_status' and/or 'Grade' not found in data.\n")
}
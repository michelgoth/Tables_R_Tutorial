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

# Load the clinical data from the Excel file.
data <- load_clinical_data("Data/ClinicalData.xlsx")

# Create clean data frames for each plot, removing rows with missing data
# for the variables we intend to plot.
data_grade_prs <- filter_complete_cases(data, c("Grade", "PRS_type"))
data_idh_gender <- filter_complete_cases(data, c("IDH_mutation_status", "Gender"))

# ===============================================================
# SECTION 1: GROUPED BAR PLOTS FOR CATEGORICAL COMPARISONS ----
# ===============================================================

# --- Plot 1: Tumor Grade by Presentation Type (PRS) ---
# A grouped bar plot helps us see the counts of one variable, broken
# down by the categories of another variable.
if (all(c("Grade", "PRS_type") %in% names(data_grade_prs))) {
  p1 <- ggplot(data_grade_prs, aes(x = Grade, fill = PRS_type)) +
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
if (all(c("IDH_mutation_status", "Gender") %in% names(data_idh_gender))) {
  p2 <- ggplot(data_idh_gender, aes(x = IDH_mutation_status, fill = Gender)) +
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

# 2. Create a bar chart showing 'MGMTp_methylation_status' broken down by 'Grade'.

# 3. In one of your new plots, try changing `position = "dodge"` to
#    `position = "fill"`. This will show the proportions of the 'fill'
#    variable within each x-axis category, rather than the raw counts.

# 4. Make one of your plots "publication-ready" by adding a custom theme,
#    more descriptive labels, and a different color palette.
#    Hint: try adding `+ theme_classic()` or `+ scale_fill_viridis_d()`
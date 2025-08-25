# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# ===============================================================
# LESSON 7: TESTING ASSOCIATIONS BETWEEN CATEGORICAL VARIABLES
# ===============================================================
#
# OBJECTIVE:
# To statistically test for associations between two categorical variables
# using the Chi-squared test and Fisher's exact test. This moves beyond
# the visual inspection of plots (Lesson 3) to formal hypothesis testing.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
load_required_packages(c("readxl", "ggplot2"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# Create clean data frames. The 'droplevels()' function is used here to
# remove any unused categories (levels) from our factor variables, which
# can sometimes cause issues in statistical tests.
data_idh_grade <- filter_complete_cases(data, c("IDH_mutation_status", "Grade"))
data_idh_grade <- droplevels(data_idh_grade)
data_gender_mgmt <- filter_complete_cases(data, c("Gender", "MGMTp_methylation_status"))
data_gender_mgmt <- droplevels(data_gender_mgmt)

# ===============================================================
# SECTION 1: CHI-SQUARED TEST ----------------------------------
# The Chi-squared test is used to determine if there is a significant
# association between two categorical variables.
#
# Null Hypothesis (H0): The two variables are independent (no association).
# Alternative Hypothesis (Ha): The two variables are not independent.
# ===============================================================

if (all(c("IDH_mutation_status", "Grade") %in% names(data_idh_grade))) {
  # First, we create a "contingency table" which is a table of counts
  # showing the number of patients for each combination of the two variables.
  table_idh_grade <- table(data_idh_grade$IDH_mutation_status, data_idh_grade$Grade)

  # Run the test on the contingency table and print the results (p-value).
  print(chisq.test(table_idh_grade))

  # It's always a good idea to visualize the association you are testing.
  p <- ggplot(data_idh_grade, aes(x = Grade, fill = IDH_mutation_status)) +
    geom_bar(position = "dodge") +
    labs(title = "IDH Status by Tumor Grade", x = "Grade", y = "Count") +
    theme_minimal()
  print(p)
  save_plot_both(p, base_filename = "Lesson7_IDH_by_Grade")
} else {
  cat("Required columns 'IDH_mutation_status' and/or 'Grade' not found in data.\n")
}

# ===============================================================
# SECTION 2: FISHER'S EXACT TEST ------------------------------
# Fisher's exact test is used as an alternative to the Chi-squared test
# when you have small sample sizes.
#
# Guideline: Use Fisher's test if any "cell" in your contingency table
# has an expected count of less than 5.
# ===============================================================

if (all(c("Gender", "MGMTp_methylation_status") %in% names(data_gender_mgmt))) {
  # We can create the table and run the test in one line.
  print(fisher.test(table(data_gender_mgmt$Gender, data_gender_mgmt$MGMTp_methylation_status)))
}

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================

# 1. Test for an association between 'PRS_type' and 'Chemo_status'.
#    First, create the contingency table using `table()`, then decide
#    if a Chi-squared or Fisher's test is more appropriate.

# 2. When should you use Fisher's test instead of Chi-square?
#    (Hint: Examine the counts in the contingency table from task #1).

# 3. Test for an association between 'Radio_status' and 'Grade'.
#    Don't forget to visualize the result with a grouped bar plot.
# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# ===============================================================
# LESSON 8: COMPARING A CONTINUOUS VARIABLE BETWEEN TWO GROUPS
# ===============================================================
#
# OBJECTIVE:
# To compare a continuous variable (like age or survival time) between
# two different clinical groups using the Wilcoxon Rank-Sum test and
# to visualize the results with boxplots.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
load_required_packages(c("readxl", "ggplot2", "dplyr"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# Create clean data frames and drop unused factor levels.
data_age_idh <- filter_complete_cases(data, c("Age", "IDH_mutation_status"))
data_age_idh <- droplevels(data_age_idh)
data_os_mgmt <- filter_complete_cases(data, c("OS", "MGMTp_methylation_status"))
data_os_mgmt <- droplevels(data_os_mgmt)
data_age_grade <- filter_complete_cases(data, c("Age", "Grade"))
data_age_grade <- droplevels(data_age_grade)

# ===============================================================
# SECTION 1: WILCOXON RANK-SUM TEST ---------------------------
# This test is used to determine if there is a significant difference
# in a continuous variable between two independent groups. It is a
# "non-parametric" test, meaning it doesn't assume the data is normally
# distributed, which makes it a robust choice for clinical data.
# It is also known as the Mann-Whitney U test.
#
# Null Hypothesis (H0): The distributions of the variable in the two groups are the same.
# Alternative Hypothesis (Ha): The distributions are different.
# ===============================================================

# --- Test 1: Compare Age by IDH mutation status ---
if (all(c("Age", "IDH_mutation_status") %in% names(data_age_idh))) {
  # This code checks to make sure there are exactly two groups to compare.
  if (nlevels(data_age_idh$IDH_mutation_status) == 2) {
    # The formula 'Age ~ IDH_mutation_status' tells R to compare the 'Age'
    # variable between the groups defined in 'IDH_mutation_status'.
    print(wilcox.test(Age ~ IDH_mutation_status, data = data_age_idh))
  }
}

# --- Test 2: Compare Overall Survival by MGMT methylation status ---
if (all(c("OS", "MGMTp_methylation_status") %in% names(data_os_mgmt))) {
  if (nlevels(data_os_mgmt$MGMTp_methylation_status) == 2) {
    print(wilcox.test(OS ~ MGMTp_methylation_status, data = data_os_mgmt))
  }
}

# ===============================================================
# SECTION 2: VISUALIZATION WITH BOXPLOTS ----------------------
# A boxplot is an excellent way to visualize the distribution of a
# continuous variable between groups.
#
# How to read a boxplot:
# - The thick line in the box is the Median (50th percentile).
# - The bottom and top of the box are the 1st (25th) and 3rd (75th) quartiles.
# - The "whiskers" extend to the rest of the data's range.
# - Dots outside the whiskers are potential outliers.
# ===============================================================

if (all(c("OS", "MGMTp_methylation_status") %in% names(data_os_mgmt))) {
  p <- ggplot(data_os_mgmt, aes(x = MGMTp_methylation_status, y = OS, fill = MGMTp_methylation_status)) +
    geom_boxplot() +
    theme_minimal() +
    labs(title = "OS by MGMT Methylation Status", x = "MGMT Status", y = "Overall Survival (days)")
  print(p)
  save_plot_both(p, base_filename = "Lesson8_OS_by_MGMT")
# Fallback plot in case MGMT data is missing.
} else if (all(c("Age", "Grade") %in% names(data_age_grade))) {
  p <- ggplot(data_age_grade, aes(x = Grade, y = Age, fill = Grade)) +
    geom_boxplot() +
    theme_minimal() +
    labs(title = "Age by Tumor Grade", x = "Grade", y = "Age (years)")
  print(p)
  save_plot_both(p, base_filename = "Lesson8_Age_by_Grade")
}

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================

# 1. Compare 'OS' (Overall Survival) between patients who received
#    chemotherapy ('Chemo_status' == 1) and those who did not ('Chemo_status' == 0).
#    Is the difference statistically significant according to the Wilcoxon test?

# 2. Compare the 'Age' of patients with Grade III vs. Grade IV tumors.
#    You will need to filter your data frame first to only include these two grades.
#    Hint: `subset_data <- subset(data, Grade %in% c("III", "IV"))`

# 3. Create a boxplot to visualize the comparison from task #1.
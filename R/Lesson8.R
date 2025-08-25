# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

source("R/utils.R")
load_required_packages(c("readxl", "ggplot2", "dplyr"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# ===============================================================
# LESSON 8: COMPARING NUMERIC VARIABLES ACROSS GROUPS
# ===============================================================

# LEARNING OBJECTIVES:
# - Compare continuous variables across categories
# - Use the Wilcoxon test or t-test appropriately
# - Interpret p-values in clinical context

# SECTION 1: WILCOXON RANK-SUM TEST ---------------------------

if (all(c("Age", "IDH_mutation_status") %in% names(data))) {
  idh_levels <- levels(data$IDH_mutation_status)
  idh_levels <- idh_levels[!is.na(idh_levels)]
  if (length(idh_levels) == 2) {
    print(wilcox.test(Age ~ IDH_mutation_status, data = data))
  }
}

# Compare OS between MGMT methylation groups (if binary)
if (all(c("OS", "MGMTp_methylation_status") %in% names(data))) {
  mgmt_levels <- levels(data$MGMTp_methylation_status)
  mgmt_levels <- mgmt_levels[!is.na(mgmt_levels)]
  if (length(mgmt_levels) == 2) {
    print(wilcox.test(OS ~ MGMTp_methylation_status, data = data))
  }
}

# SECTION 2: VISUALIZATION ------------------------------------

# Boxplot of OS by MGMT methylation status (or fallback Age by Grade)
if (all(c("OS", "MGMTp_methylation_status") %in% names(data))) {
  p <- ggplot(data, aes(x = MGMTp_methylation_status, y = OS, fill = MGMTp_methylation_status)) +
    geom_boxplot() +
    theme_minimal() +
    labs(title = "OS by MGMT Methylation Status", x = "MGMT Status", y = "Overall Survival (days)")
  print(p)
  save_plot_both(p, base_filename = "Lesson8_OS_by_MGMT")
} else if (all(c("Age", "Grade") %in% names(data))) {
  p <- ggplot(data, aes(x = Grade, y = Age, fill = Grade)) +
    geom_boxplot() +
    theme_minimal() +
    labs(title = "Age by Tumor Grade", x = "Grade", y = "Age (years)")
  print(p)
  save_plot_both(p, base_filename = "Lesson8_Age_by_Grade")
}

# PRACTICE TASKS ----------------------------------------------
# 1. Compare OS across PRS_type using Wilcoxon or t-test
# 2. Compare Age between Grade III and Grade IV tumors
# 3. Create additional boxplots for your comparisons
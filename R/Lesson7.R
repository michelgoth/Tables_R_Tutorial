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
# Load our helper functions and required packages
source("R/utils.R")
load_required_packages(c("readxl", "ggplot2"))

# Load and impute the clinical data
raw_data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- impute_clinical_data(raw_data)
data <- droplevels(data)

# ===============================================================
# SECTION 1: CHI-SQUARED TEST ----------------------------------
# The Chi-squared test is used to determine if there is a significant
# association between two categorical variables.
#
# Null Hypothesis (H0): The two variables are independent (no association).
# Alternative Hypothesis (Ha): The two variables are not independent.
# ===============================================================

if (all(c("IDH_mutation_status", "Grade") %in% names(data))) {
  # First, we create a "contingency table" which is a table of counts
  # showing the number of patients for each combination of the two variables.
  table_idh_grade <- table(data$IDH_mutation_status, data$Grade)

  # Run the test on the contingency table and print the results (p-value).
  print(chisq.test(table_idh_grade))

  # It's always a good idea to visualize the association you are testing.
  p <- ggplot(data, aes(x = Grade, fill = IDH_mutation_status)) +
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

if (all(c("Gender", "MGMTp_methylation_status") %in% names(data))) {
  # We can create the table and run the test in one line.
  print(fisher.test(table(data$Gender, data$MGMTp_methylation_status)))
}

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================

# 1. Test for an association between 'PRS_type' and 'Chemo_status'.
#    First, create the contingency table using `table()`, then decide
#    if a Chi-squared or Fisher's test is more appropriate.

data$Chemo_status <- as.factor(data$Chemo_status) #utils.R puts Chemo_status nummeric, then the fill function wouldnt work

if (all(c("PRS_type", "Chemo_status") %in% names(data))) {
  table_PRS_chemo <- table(data$PRS_type, data$Chemo_status)
  print(chisq.test(table_PRS_chemo))
  
  p_PRS_chemo <- ggplot(data, aes(x = PRS_type, fill = Chemo_status)) +
    geom_bar(position = "dodge") +
    labs(title = "PRS_type by Chemo_status", x = "PRS_type", y = "Count") +
    theme_minimal()
  print(p_PRS_chemo)
  save_plot_both(p_PRS_chemo, base_filename = "Lesson7_PRS_by_Chemo")
} else {
  cat("Required columns 'PRS_type' and/or 'Chemo_status' not found in data.\n")
}

chi_res <- chisq.test(table_PRS_chemo)
chi_res$expected

# 2. When should you use Fisher's test instead of Chi-square?
#    (Hint: Examine the counts in the contingency table from task #1).
#	In the Chi-squared test, the expected frequency per table cell is calculated based on the observed counts and the assumed distributions.
#	A common rule of thumb:
# 	No expected frequency should be < 1
#	At most 20% of the cells may have an expected frequency < 5
#	If these conditions are violated, the test can be unreliable → in such cases, Fisher’s Exact Test is often used.

# 3. Test for an association between 'Radio_status' and 'Grade'.
#    Don't forget to visualize the result with a grouped bar plot.

library(dplyr)
library(ggpubr)
library(scales)

if (all(c("Radio_status", "Grade") %in% names(data))) {
  table_Radio_Grade <- table(data$Radio_status, data$Grade)
  print(chisq.test(table_Radio_Grade))
  
  # 1) Contingency table + Chi-square
  table_Radio_Grade <- table(data$Radio_status, data$Grade)
  chi_exRG <- chisq.test(table_Radio_Grade)
  
  # 2) Convert to long data frame
  df <- as.data.frame(table_Radio_Grade)
  names(df) <- c("Radio_status", "Grade", "n")
  
  p1 <- ggbarplot(
    df, x = "Radio_status", y = "n", fill = "Grade",
    position = position_fill()  # makes bars show proportions
  ) +
    ylab("Proportion") +
    scale_y_continuous(labels = percent_format()) +
    ggtitle("Radio status vs Grade",
            subtitle = paste0("Chi-square's exact p = ", signif(chi_exRG$p.value, 3))) +
    #theme_pubr()
  scale_fill_viridis_d()
  theme_minimal()

  print(p1)
  save_plot_both(p1, base_filename = "Lesson7_Radio_by_Grade")
  
} else {
  cat("Required columns 'Radio_status' and/or 'Grade' not found in data.\n")
}

chi_exRG <- chisq.test(table_Radio_Grade)
chi_exRG$expected
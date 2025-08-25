# ===============================================================
# LESSON 11: COMPARING A CONTINUOUS VARIABLE ACROSS MULTIPLE GROUPS (ANOVA)
# ===============================================================
#
# OBJECTIVE:
# To use Analysis of Variance (ANOVA) to compare the mean of a continuous
# variable across three or more groups. This lesson also introduces
# post-hoc tests, two-way ANOVA, and assumption checking.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
# The 'car' package is needed for Levene's test for assumption checking.
load_required_packages(c("readxl", "ggplot2", "dplyr", "car"))

data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- droplevels(data) # Clean up factor levels

# ===============================================================
# SECTION 1: ONE-WAY ANOVA -------------------------------------
# Use a one-way ANOVA when you are comparing the means of a single
# continuous variable across three or more groups.
#
# Null Hypothesis (H0): The means of all groups are equal.
# Alternative Hypothesis (Ha): At least one group's mean is different.
# ===============================================================
cat("--- SECTION 1: ONE-WAY ANOVA (OS by Grade) ---\n")
if (all(c("OS", "Grade") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$Grade), ]
  analysis_data <- droplevels(analysis_data)
  if (nrow(analysis_data) > 0) {
    # The 'aov()' function performs the ANOVA. The formula is similar to previous lessons.
    anova_result <- aov(OS ~ Grade, data = analysis_data)
    print(summary(anova_result)) # The summary gives the F-statistic and p-value.

    # Visualize the group differences with a boxplot.
    p <- ggplot(analysis_data, aes(x = Grade, y = OS, fill = Grade)) +
      geom_boxplot() + theme_minimal() +
      labs(title = "OS by Tumor Grade", x = "Grade", y = "Overall Survival (days)")
    print(p)
    save_plot_both(p, base_filename = "Lesson11_OS_by_Grade")
  }
}

# ===============================================================
# SECTION 2: POST-HOC ANALYSIS --------------------------------
# A significant p-value from ANOVA tells you that *at least one* group
# is different, but not *which* one. Post-hoc tests are needed to
# compare each pair of groups (e.g., Grade II vs III, III vs IV, etc.).
# ===============================================================
cat("\n--- SECTION 2: POST-HOC ANALYSIS ---\n")
if (all(c("OS", "Grade") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$Grade), ]
  analysis_data <- droplevels(analysis_data)
  if (nrow(analysis_data) > 0) {
    anova_model <- aov(OS ~ Grade, data = analysis_data)
    # Tukey's Honest Significant Difference (HSD) is a common post-hoc test.
    # It compares all possible pairs of group means.
    tukey_result <- TukeyHSD(anova_model)
    print(tukey_result) # Look for pairs with an adjusted p-value ('p adj') < 0.05.
  }
}

# ===============================================================
# SECTION 3: TWO-WAY ANOVA ------------------------------------
# Use a two-way ANOVA to test the effect of two categorical variables
# (and their interaction) on one continuous outcome variable.
# ===============================================================
cat("\n--- SECTION 3: TWO-WAY ANOVA (OS by Grade and Gender) ---\n")
if (all(c("OS", "Grade", "Gender") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$Grade) & !is.na(data$Gender), ]
  analysis_data <- droplevels(analysis_data)
  if (nrow(analysis_data) > 0) {
    # The formula 'OS ~ Grade * Gender' is shorthand for 'OS ~ Grade + Gender + Grade:Gender'.
    # It tests the "main effect" of Grade, the "main effect" of Gender, and the
    # "interaction effect" of Grade and Gender together.
    anova_2way <- aov(OS ~ Grade * Gender, data = analysis_data)
    print(summary(anova_2way))
  }
}

# ===============================================================
# SECTION 4: ASSUMPTION CHECKING FOR ANOVA ---------------------
# ANOVA has two main assumptions that should be checked:
# 1. Normality: The data (or residuals) should be normally distributed.
# 2. Homogeneity of Variances: The variance should be similar in each group.
# ===============================================================
cat("\n--- SECTION 4: ANOVA ASSUMPTION CHECKING ---\n")
if (all(c("OS", "Grade") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$Grade), ]
  analysis_data <- droplevels(analysis_data)
  if (nrow(analysis_data) > 0) {
    # 1. Normality Check: Shapiro-Wilk test on the model residuals.
    # A p-value > 0.05 suggests the residuals are normally distributed (assumption met).
    cat("\nNormality test of residuals (Shapiro-Wilk):\n")
    anova_model <- aov(OS ~ Grade, data = analysis_data)
    print(shapiro.test(residuals(anova_model)))

    # 2. Homogeneity of Variance Check: Levene's test.
    # A p-value > 0.05 suggests the variances are equal (assumption met).
    cat("\nHomogeneity of variance test (Levene's):\n")
    print(car::leveneTest(OS ~ Grade, data = analysis_data))
  }
}

# ===============================================================
# SECTION 5 (Optional): MANOVA ----------------------------------
# MANOVA (Multivariate ANOVA) is used when you have multiple
# continuous outcome variables that you want to test at the same time.
# ===============================================================
cat("\n--- SECTION 5 (Optional): MANOVA (Age and OS by Grade) ---\n")
if (all(c("Age", "OS", "Grade") %in% names(data))) {
  # Here we test if 'Grade' has a significant effect on 'Age' AND 'OS' simultaneously.
  analysis_data <- data[complete.cases(data[, c("Age", "OS", "Grade")]), ]
  manova_result <- manova(cbind(Age, OS) ~ Grade, data = analysis_data)
  print(summary(manova_result))
}

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================
# 1. Perform a one-way ANOVA comparing 'Age' across the different 'PRS_type' groups.
# 2. If the ANOVA from task #1 is significant, run a TukeyHSD post-hoc test.
# 3. Check the assumptions for the ANOVA model from task #1. Are they met? 
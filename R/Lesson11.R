# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

source("R/utils.R")
load_required_packages(c("readxl", "ggplot2"))

data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- droplevels(data)

# ===============================================================
# LESSON 11: MULTIVARIATE ANALYSIS (ANOVA, MANOVA)
# ===============================================================

cat("=== LESSON 11: MULTIVARIATE ANALYSIS ===\n")
cat("Sample size:", nrow(data), "patients\n")
cat("Available variables:", paste(names(data), collapse = ", "), "\n\n")

# SECTION 1: ONE-WAY ANOVA -------------------------------------

if (all(c("OS", "Grade") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$Grade), ]
  analysis_data <- droplevels(analysis_data)
  if (nrow(analysis_data) > 0) {
    anova_result <- aov(OS ~ Grade, data = analysis_data)
    print(summary(anova_result))
    
    # Save OS by Grade boxplot
    p <- ggplot(analysis_data, aes(x = Grade, y = OS, fill = Grade)) +
      geom_boxplot() +
      theme_minimal() +
      labs(title = "OS by Tumor Grade", x = "Grade", y = "Overall Survival (days)")
    print(p)
    save_plot_both(p, base_filename = "Lesson11_OS_by_Grade")
  }
}

# SECTION 2: TWO-WAY ANOVA ------------------------------------

cat("SECTION 2: TWO-WAY ANOVA\n")
cat("Analyzing survival time by grade and gender...\n\n")

if (all(c("OS", "Grade", "Gender") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$Grade) & !is.na(data$Gender), ]
  analysis_data <- droplevels(analysis_data)
  
  if (nrow(analysis_data) > 0) {
    tryCatch({
      # Two-way ANOVA
      anova_2way <- aov(OS ~ Grade * Gender, data = analysis_data)
      print(summary(anova_2way))
      
      # Check for interaction effects
      interaction_p <- summary(anova_2way)[[1]]["Grade:Gender", "Pr(>F)"]
      cat("\nInteraction Effect (Grade × Gender): p =", round(interaction_p, 4), "\n")
      
      if (interaction_p < 0.05) {
        cat("Significant interaction detected! Effects are not additive.\n")
      } else {
        cat("No significant interaction. Effects are additive.\n")
      }
      
    }, error = function(e) {
      cat("Error in two-way ANOVA:", e$message, "\n")
    })
  } else {
    cat("Insufficient data for two-way ANOVA.\n")
  }
} else {
  cat("Required columns not found for two-way ANOVA.\n")
}

# SECTION 3: POST-HOC ANALYSIS --------------------------------

cat("\nSECTION 3: POST-HOC ANALYSIS\n")
cat("Pairwise comparisons between groups...\n\n")

if (all(c("OS", "Grade") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$Grade), ]
  analysis_data <- droplevels(analysis_data)
  
  if (nrow(analysis_data) > 0) {
    tryCatch({
      # Tukey's HSD test
      anova_model <- aov(OS ~ Grade, data = analysis_data)
      tukey_result <- TukeyHSD(anova_model)
      print(tukey_result)
      
      # Bonferroni correction
      cat("\nBonferroni-corrected pairwise t-tests:\n")
      pairwise_result <- pairwise.t.test(analysis_data$OS, analysis_data$Grade, 
                                        p.adjust.method = "bonferroni")
      print(pairwise_result)
      
    }, error = function(e) {
      cat("Error in post-hoc analysis:", e$message, "\n")
    })
  } else {
    cat("Insufficient data for post-hoc analysis.\n")
  }
} else {
  cat("Required columns not found for post-hoc analysis.\n")
}

# SECTION 4: MANOVA (MULTIPLE DEPENDENT VARIABLES) ------------

cat("\nSECTION 4: MANOVA\n")
cat("Analyzing multiple outcomes simultaneously...\n\n")

# Check for multiple numeric variables
numeric_vars <- c("Age", "OS")
available_numeric <- numeric_vars[numeric_vars %in% names(data)]

if (length(available_numeric) >= 2 && "Grade" %in% names(data)) {
  analysis_data <- data[!is.na(data$Grade), ]
  
  # Remove rows with missing values in any numeric variable
  for (var in available_numeric) {
    analysis_data <- analysis_data[!is.na(analysis_data[[var]]), ]
  }
  
  if (nrow(analysis_data) > 0) {
    tryCatch({
      # Create formula for MANOVA
      manova_formula <- as.formula(paste("cbind(", paste(available_numeric, collapse = ", "), ") ~ Grade"))
      
      # Perform MANOVA
      manova_result <- manova(manova_formula, data = analysis_data)
      print(summary(manova_result))
      
      # Individual ANOVAs for each dependent variable
      cat("\nIndividual ANOVAs for each dependent variable:\n")
      print(summary.aov(manova_result))
      
    }, error = function(e) {
      cat("Error in MANOVA:", e$message, "\n")
    })
  } else {
    cat("Insufficient data for MANOVA.\n")
  }
} else {
  cat("Insufficient numeric variables or grouping variable for MANOVA.\n")
}

# SECTION 5: ASSUMPTION TESTING ------------------------------

cat("\nSECTION 5: ASSUMPTION TESTING\n")
cat("Checking ANOVA assumptions...\n\n")

if (all(c("OS", "Grade") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$Grade), ]
  
  if (nrow(analysis_data) > 0) {
    tryCatch({
      # Normality test for each group
      cat("Normality tests (Shapiro-Wilk) by group:\n")
      for (grade in unique(analysis_data$Grade)) {
        group_data <- analysis_data$OS[analysis_data$Grade == grade]
        if (length(group_data) >= 3) {
          sw_test <- shapiro.test(group_data)
          cat("Grade", grade, ": W =", round(sw_test$statistic, 3), 
              ", p =", round(sw_test$p.value, 4), "\n")
        }
      }
      
      # Homogeneity of variance (Levene's test)
      cat("\nHomogeneity of variance (Levene's test):\n")
      levene_result <- car::leveneTest(OS ~ Grade, data = analysis_data)
      print(levene_result)
      
      # Residuals analysis
      anova_model <- aov(OS ~ Grade, data = analysis_data)
      residuals_data <- residuals(anova_model)
      
      cat("\nResiduals normality test:\n")
      res_sw <- shapiro.test(residuals_data)
      cat("Shapiro-Wilk: W =", round(res_sw$statistic, 3), 
          ", p =", round(res_sw$p.value, 4), "\n")
      
    }, error = function(e) {
      cat("Error in assumption testing:", e$message, "\n")
    })
  } else {
    cat("Insufficient data for assumption testing.\n")
  }
} else {
  cat("Required columns not found for assumption testing.\n")
}

# PRACTICE TASKS ----------------------------------------------

cat("\n=== PRACTICE TASKS ===\n")
cat("1. Perform ANOVA comparing Age across different IDH mutation statuses\n")
cat("2. Conduct two-way ANOVA with Age ~ Grade * Gender\n")
cat("3. Run MANOVA with Age and OS as dependent variables\n")
cat("4. Check assumptions for your ANOVA models\n")
cat("5. Interpret effect sizes and clinical significance\n\n")

cat("=== CLINICAL INTERPRETATION TIPS ===\n")
cat("- p < 0.05: Statistically significant difference\n")
cat("- Effect size > 0.14: Large clinical effect\n")
cat("- Check assumptions before interpreting results\n")
cat("- Consider clinical significance beyond statistical significance\n")
cat("- Report confidence intervals and effect sizes\n") 
# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

source("R/utils.R")
load_required_packages(c("readxl", "ggplot2"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# ===============================================================
# LESSON 9: LOGISTIC REGRESSION FOR BINARY OUTCOMES
# ===============================================================

# LEARNING OBJECTIVES:
# - Build a logistic regression model
# - Interpret coefficients and p-values
# - Predict binary outcomes like mutation or treatment status

# SECTION 1: FIT A LOGISTIC MODEL -----------------------------

required_cols <- c("IDH_mutation_status", "Age", "Gender", "Grade", "MGMTp_methylation_status")
missing_cols <- required_cols[!required_cols %in% names(data)]

if (length(missing_cols) > 0) {
  cat("Warning: Missing columns for logistic model:", paste(missing_cols, collapse = ", "), "\n")
  cat("Proceeding with available columns...\n")
}

# Fit logistic model when outcome is binary
tryCatch({
  # Keep only non-missing outcome rows and ensure binary levels
  if ("IDH_mutation_status" %in% names(data)) {
    d2 <- data[!is.na(data$IDH_mutation_status) & data$IDH_mutation_status %in% c("Mutant", "Wildtype"), ]
    d2$IDH_mutation_status <- droplevels(d2$IDH_mutation_status)
    if (nrow(d2) > 0 && length(levels(d2$IDH_mutation_status)) == 2) {
      model <- glm(IDH_mutation_status ~ Age + Gender + Grade + MGMTp_methylation_status,
                   data = d2, family = "binomial")
      print(summary(model))
      
      # Coefficient plot
      coefs <- coef(summary(model))
      coefs_df <- data.frame(Term = rownames(coefs), Estimate = coefs[, "Estimate"])
      coefs_df <- coefs_df[coefs_df$Term != "(Intercept)", ]
      p <- ggplot(coefs_df, aes(x = reorder(Term, Estimate), y = Estimate)) +
        geom_col(fill = "steelblue") +
        coord_flip() +
        theme_minimal() +
        labs(title = "Logistic Regression Coefficients",
             x = "Term", y = "Estimate (log-odds)")
      print(p)
      save_plot_both(p, base_filename = "Lesson9_Logistic_Coefficients")
    } else {
      cat("IDH_mutation_status not binary after filtering; skipping model.\n")
    }
  }
}, error = function(e) {
  cat("Error fitting logistic model:", e$message, "\n")
})

# PRACTICE TASKS ----------------------------------------------
# 1. Which predictors are statistically significant (p < 0.05)?
# 2. Interpret the sign of each coefficient.
# 3. Build a model for MGMTp_methylation_status as outcome.
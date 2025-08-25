# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# ===============================================================
# LESSON 9: PREDICTING BINARY OUTCOMES WITH LOGISTIC REGRESSION
# ===============================================================
#
# OBJECTIVE:
# To use logistic regression to model a binary clinical outcome (e.g.,
# Mutant vs. Wildtype). This technique helps us understand how different
# predictor variables are associated with the probability of the outcome.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
load_required_packages(c("readxl", "ggplot2"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# ===============================================================
# SECTION 1: FITTING A LOGISTIC REGRESSION MODEL ----------------
#
# When our outcome variable is binary (two categories), we can't use
# standard linear regression. Logistic regression is the correct tool.
# It models the probability of the outcome occurring.
#
# The output is often interpreted as Odds Ratios (OR).
# ===============================================================

# Define the outcome and predictor variables for our model.
outcome_variable <- "IDH_mutation_status"
predictor_variables <- c("Age", "Gender", "Grade", "MGMTp_methylation_status")
model_variables <- c(outcome_variable, predictor_variables)

# Check if all required columns are present in the data.
if (!all(model_variables %in% names(data))) {
  stop("One or more required columns for the model are missing.")
}

tryCatch({
  # --- Data Preparation ---
  # 1. Filter out rows where the outcome is missing.
  # 2. Ensure the outcome is a factor with exactly two levels.
  clean_data <- data[!is.na(data[[outcome_variable]]), ]
  clean_data[[outcome_variable]] <- droplevels(factor(clean_data[[outcome_variable]]))

  if (nlevels(clean_data[[outcome_variable]]) == 2) {
    # --- Model Fitting ---
    # We use the 'glm()' function (Generalized Linear Model).
    # 'family = "binomial"' is what specifies that we are doing logistic regression.
    model_formula <- as.formula(paste(outcome_variable, "~", paste(predictor_variables, collapse = " + ")))

    model <- glm(model_formula, data = clean_data, family = "binomial")

    # The summary provides coefficients, standard errors, z-values, and p-values.
    print(summary(model))

    # --- Interpreting Coefficients ---
    # The 'Estimate' column is in a unit called "log-odds".
    # - A positive estimate means the variable increases the log-odds of the outcome.
    # - A negative estimate means the variable decreases the log-odds.
    # To get the more interpretable Odds Ratio (OR), you calculate exp(Estimate).

    # --- Visualizing Coefficients ---
    coefs <- coef(summary(model))
    coefs_df <- data.frame(Term = rownames(coefs), Estimate = coefs[, "Estimate"])
    # We remove the '(Intercept)' for a cleaner plot.
    coefs_df <- coefs_df[coefs_df$Term != "(Intercept)", ]

    p <- ggplot(coefs_df, aes(x = reorder(Term, Estimate), y = Estimate)) +
      geom_col(fill = "steelblue") +
      coord_flip() +
      theme_minimal() +
      labs(title = "Logistic Regression Coefficients",
           x = "Predictor Variable", y = "Estimate (log-odds)")
    print(p)
    save_plot_both(p, base_filename = "Lesson9_Logistic_Coefficients")

  } else {
    cat("The outcome variable '", outcome_variable, "' is not binary after filtering.\n")
  }

}, error = function(e) {
  cat("Error fitting logistic model:", e$message, "\n")
})

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================

# 1. Look at the summary output. Which predictors are statistically significant (p < 0.05)?

# 2. Interpret the sign (positive or negative) of the 'Age' coefficient. Does older
#    age increase or decrease the log-odds of having an IDH-wildtype tumor?
#    (Note: R models the second factor level, so check `levels(clean_data$IDH_mutation_status)`
#    to see if it's modeling "Mutant" or "Wildtype").

# 3. Build a new logistic regression model to predict 'MGMTp_methylation_status'
#    using 'Age', 'Grade', and 'IDH_mutation_status' as predictors.
# ===============================================================
# LESSON 6: MULTIVARIABLE SURVIVAL ANALYSIS WITH THE COX PROPORTIONAL HAZARDS MODEL
# ===============================================================
#
# OBJECTIVE:
# To perform multivariable survival analysis using the Cox Proportional
# Hazards model. This allows us to estimate the effect of several clinical
# variables on survival simultaneously and identify independent predictors of outcome.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
load_required_packages(c("survival", "readxl", "dplyr", "ggplot2"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# Create a clean data frame for the overall KM plot.
data_surv_all <- filter_complete_cases(data, c("OS", "Censor"))

# ===============================================================
# SECTION 1: BUILDING THE MULTIVARIABLE COX MODEL ---------------
# While the log-rank test is great for a single variable, a patient's
# outcome is influenced by many factors. The Cox model lets us assess
# the effect of one variable while statistically adjusting for the effects
# of others. This helps us find "independent" predictors.
# ===============================================================

# Check if all the columns we want to include in our model are present in the data.
required_cols <- c("OS", "Censor", "Age", "Gender", "Grade",
                   "IDH_mutation_status", "MGMTp_methylation_status", "PRS_type",
                   "Chemo_status", "Radio_status")
available_cols <- intersect(required_cols, names(data))

# Fit the Cox model using the 'coxph()' function.
# The formula includes multiple predictor variables separated by '+'.
# The model will automatically use only "complete cases" - patients who
# do not have missing data for ANY of the variables in the formula.
cox_formula <- as.formula(paste("Surv(OS, Censor) ~", paste(available_cols, collapse=" + ")))

tryCatch({
  cox_model <- coxph(cox_formula, data = data)

  # The 'summary()' of the model object provides the key results.
  print(summary(cox_model))
}, error = function(e) {
  cat("Error fitting Cox model:", e$message, "\n")
  cat("This may be due to missing data or insufficient sample size for the variables included.\n")
})

# ===============================================================
# INTERPRETING THE OUTPUT
#
# In the summary table, focus on these columns:
# - `exp(coef)`: This is the Hazard Ratio (HR).
#   - HR > 1: Increased hazard (risk) of death.
#   - HR < 1: Decreased hazard (protective effect).
#   - HR = 1: No effect.
# - `Pr(>|z|)`: This is the p-value. If < 0.05, the variable is a
#   statistically significant independent predictor of survival.
# - `lower .95`, `upper .95`: The 95% Confidence Interval for the HR.
#   If this interval does not include 1.0, the result is significant.
# ===============================================================


# --- For context, we also plot the overall survival of the cohort ---
surv_obj <- Surv(data_surv_all$OS, data_surv_all$Censor)
# A formula of '~ 1' means "no grouping", so it calculates the overall curve.
km_fit <- survfit(surv_obj ~ 1)
km_df <- data.frame(time = km_fit$time, surv = km_fit$surv)

p_km <- ggplot(km_df, aes(x = to_months(time), y = surv)) +
  geom_step(color = "steelblue") +
  labs(title = "Kaplan-Meier Overall Survival for the Cohort",
       x = "Time (months)", y = "Survival Probability") +
  theme_minimal()
print(p_km)
save_plot_both(p_km, base_filename = "Lesson6_KM_Overall")

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================

# 1. Look at the summary output. Which variables have a p-value < 0.05?

# 2. Interpret the Hazard Ratio for 'Age'. For every one-year increase in age,
#    by how much does the hazard of death change, according to this model?

# 3. Interpret the Hazard Ratio for 'IDH_mutation_statusMutant'. Does having
#    the mutation increase or decrease the risk compared to wildtype?

# 4. Create a new model that omits a non-significant variable (like 'PRS_type').
#    Use the formula `Surv(OS, Censor) ~ Age + Gender + Grade + ...` but without that term.
#    How do the Hazard Ratios and p-values of the other variables change?

# 5. If you have the 'survminer' package installed, try visualizing the Hazard Ratios
#    with a forest plot: `survminer::ggforest(cox_model, data = data)`
# ===============================================================
# LESSON 6: MULTIVARIABLE SURVIVAL ANALYSIS WITH THE COX PROPORTIONAL HAZARDS MODEL
# ===============================================================
#
# OBJECTIVE:
# To perform multivariable survival analysis using the Cox Proportional
# Hazards model, and to properly check the model's key assumptions. This
# allows us to estimate the effect of several clinical variables on
# survival simultaneously and identify independent predictors of outcome.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
load_required_packages(c("survival", "readxl", "dplyr", "ggplot2", "survminer"))

# of a patient while adjusting for all other variables in the model.
# Load and impute the clinical data
raw_data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- impute_clinical_data(raw_data)

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
# Note: In this refactored script, 'data' is already imputed, so we don't
# need special handling for missingness here. The model will run on the full cohort.
available_cols <- intersect(required_cols, names(data))
# We must remove the outcome variables from the list of predictors.
predictor_cols <- setdiff(available_cols, c("OS", "Censor"))

# Fit the Cox model using the 'coxph()' function.
# The formula includes multiple predictor variables separated by '+'.
cox_formula <- as.formula(paste("Surv(OS, Censor) ~", paste(predictor_cols, collapse=" + ")))

tryCatch({
  cox_model <- coxph(cox_formula, data = data)

  # The 'summary()' of the model object provides the key results.
  print(summary(cox_model))

  # A value > 1 means worse survival (higher risk).
  # A value < 1 means better survival (lower risk).
  summary(cox_model)

  # --- Forest Plot ---
  # We can use the ggforest function from the survminer package to visualize this.
  if (!is.null(cox_model)) {
      p_forest <- ggforest(cox_model, data = data)
      save_plot_both(p_forest, "Lesson6_Cox_Forest_Plot")
  }

}, error = function(e) {
  cat("Error fitting Cox model:", e$message, "\n")
  cat("This may be due to missing data or insufficient sample size for the variables included.\n")
})

# ===============================================================
# SECTION 2: CHECKING MODEL ASSUMPTIONS -------------------------
# A key part of robust modeling is to check that the model's
# assumptions are met. For a Cox model, the two most important are:
#   1. The Proportional Hazards (PH) assumption.
#   2. The linearity of the relationship for continuous variables.
# ===============================================================
if (exists("cox_model")) {
  cat("\n--- SECTION 2: CHECKING MODEL ASSUMPTIONS ---\n")

  # --- 2A: Proportional Hazards (PH) Assumption ---
  # This tests if the effect of each variable is constant over time.
  # A p-value > 0.05 suggests the assumption is met.
  cat("\n--- Proportional Hazards Assumption Test (Schoenfeld residuals) ---\n")
  ph_test <- cox.zph(cox_model)
  print(ph_test)

  # Visualize the PH test results. We look for flat, horizontal lines.
  p_ph_test <- ggcoxzph(ph_test)
  print(p_ph_test[[1]]) # Print the first plot in the list as an example
  # save_plot_list_both(p_ph_test, base_filename = "Lesson6_PH_Assumption_Checks")

  # --- 2B: Linearity Assumption for Continuous Variables (Age) ---
  # This tests if the effect of Age is linear. We compare the original
  # model to one where Age is modeled with a flexible spline.
  # A p-value > 0.05 in the anova() test suggests the linear model is sufficient.
  cat("\n--- Linearity Assumption Test for Age ---\n")
  predictor_cols_no_age <- setdiff(predictor_cols, "Age")
  fml_spline <- as.formula(paste("Surv(OS, Censor) ~ pspline(Age) +",
                                 paste(predictor_cols_no_age, collapse=" + ")))
  model_spline <- coxph(fml_spline, data = data)
  linearity_test <- anova(cox_model, model_spline)
  print(linearity_test)
}

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
surv_obj <- Surv(data$OS, data$Censor)
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
# Modell zusammenfassen
s <- summary(cox_model)
# coefficients-Matrix holen
coef_table <- as.data.frame(s$coefficients)
sig_vars <- coef_table[coef_table$`Pr(>|z|)` < 0.05, ]
sig_vars
sig_names <- rownames(sig_vars)
sig_names

# 2. Interpret the Hazard Ratio for 'Age'. For every one-year increase in age,
#    by how much does the hazard of death change, according to this model?

#answer:
#exp(coef) = 1.010455; Pr(>|z|)0.116587; theoretically about 1% per year, but its 
#not signifficant and also Linearity Assumption for Continuous Variables (Age) didnt 
#seem to work either, which is why the variablae age wont be helpful.

# 3. Interpret the Hazard Ratio for 'IDH_mutation_statusMutant'. Does having
#    the mutation increase or decrease the risk compared to wildtype?

#answer: 
#Being IDH wildtype increases the hazard (risk of death) by about 72% compared to 
#being IDH mutated, and this result is statistically significant.

# 4. Create a new model that omits a non-significant variable (like 'PRS_type').
#    Use the formula `Surv(OS, Censor) ~ Age + Gender + Grade + ...` but without that term.
#    How do the Hazard Ratios and p-values of the other variables change?
required_cols2 <- c("OS", "Censor", "Age", "Grade",
                    "IDH_mutation_status", "MGMTp_methylation_status", "PRS_type",
                    "Chemo_status", "Radio_status")
available_cols2 <- intersect(required_cols2, names(data))
predictor_cols2 <- setdiff(available_cols2, c("OS", "Censor"))
cox_formula2 <- as.formula(paste("Surv(OS, Censor) ~", paste(predictor_cols2, collapse=" + ")))
tryCatch({
  cox_model2 <- coxph(cox_formula2, data = data)
  print(summary(cox_model2))
  
  summary(cox_model2)
  if (!is.null(cox_model2)) {
    p_forest2 <- ggforest(cox_model2, data = data)
    save_plot_both(p_forest2, "Lesson6_Cox_Forest_Plot2")
  }
  
}, error = function(e) {
  cat("Error fitting Cox model:", e$message, "\n")
  cat("This may be due to missing data or insufficient sample size for the variables included.\n")
})

if (exists("cox_model2")) {
  cat("\n--- SECTION 2: CHECKING MODEL ASSUMPTIONS ---\n")
  cat("\n--- Proportional Hazards Assumption Test (Schoenfeld residuals) ---\n")
  ph_test2 <- cox.zph(cox_model2)
  print(ph_test2)
  
  p_ph_test2 <- ggcoxzph(ph_test2)
  print(p_ph_test2[[1]])
  
  cat("\n--- Linearity Assumption Test for Age ---\n")
  predictor_cols_no_age2 <- setdiff(predictor_cols, "Age")
  fml_spline2 <- as.formula(paste("Surv(OS, Censor) ~ pspline(Age) +",
                                  paste(predictor_cols_no_age2, collapse=" + ")))
  model_spline2 <- coxph(fml_spline2, data = data)
  linearity_test2 <- anova(cox_model2, model_spline2)
  print(linearity_test2)
}
# 5. If you have the 'survminer' package installed, try visualizing the Hazard Ratios
#    with a forest plot: `survminer::ggforest(cox_model, data = data)`
print(p_forest2)

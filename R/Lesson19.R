# ===============================================================
# LESSON 19: ADVANCED MODEL DIAGNOSTICS & STATISTICAL RIGOR
# ===============================================================
#
# OBJECTIVE:
# To introduce advanced diagnostic checks for the Cox Proportional
# Hazards model. This lesson moves beyond basic model fitting to
# ensure our model is statistically sound by formally testing its
# core assumptions, addressing the final layer of statistical rigor.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
# We add `survminer` for plotting diagnostics and `ggeffects` for visualizing model terms.
load_required_packages(c("dplyr", "ggplot2", "survival", "survminer", "ggeffects"))
data <- load_clinical_data("Data/ClinicalData.xlsx")
cat("--- LESSON 19: Advanced Model Diagnostics ---\n")

# ===============================================================
# SECTION 1: RE-CREATE THE TRAIN/TEST SPLIT AND TRAINED MODEL ---
# We must first reproduce the final model from Lesson 18, as we
# need a trained model object to perform diagnostics on.
# ===============================================================
predictors <- intersect(c("Age", "Grade", "IDH_mutation_status", "MGMTp_methylation_status"), names(data))
df_complete <- data[complete.cases(data[, c("OS", "Censor", predictors)]), ]

set.seed(42) # Use the same seed for reproducibility
train_indices <- sample(1:nrow(df_complete), size = 0.7 * nrow(df_complete))
train_data <- df_complete[train_indices, ]
test_data  <- df_complete[-train_indices, ]

surv_obj_train <- Surv(time = train_data$OS, event = train_data$Censor)
fml <- as.formula(paste("surv_obj_train ~", paste(predictors, collapse = " + ")))
model_trained <- coxph(fml, data = train_data)

cat("\n--- Re-trained the model from Lesson 18 ---\n")
print(summary(model_trained))

# ===============================================================
# SECTION 2: TESTING THE PROPORTIONAL HAZARDS (PH) ASSUMPTION -
#
# The fundamental assumption of a Cox model is that the hazard ratio
# (HR) of a variable is constant over time. For example, it assumes
# the risk associated with being IDH-wildtype is the same early after
# diagnosis as it is years later. We must test this.
# ===============================================================
cat("\n--- SECTION 2: Proportional Hazards Assumption Test ---\n")
# The `cox.zph()` function tests this assumption for each variable.
# H0: The assumption is met (the effect is constant over time).
# A p-value < 0.05 indicates a violation of the assumption.
ph_test <- cox.zph(model_trained)
print(ph_test)

# --- Visualizing the PH Test ---
# We can use the `ggcoxzph()` function from the `survminer` package to
# visualize the results. A flat, horizontal line is what you want to
# see. A sloped line indicates a violation of the assumption.
cat("\n--- Generating Proportional Hazards diagnostic plot... ---\n")
p_ph_test <- ggcoxzph(ph_test)
print(p_ph_test[[1]]) # Print the first plot in the list (Age)
save_plot_list_both(p_ph_test, base_filename = "Lesson19_PH_Assumption_Checks")
cat("--- Plot 'Lesson19_PH_Assumption_Checks.pdf/.png' saved. ---\n")

# --- Interpretation of the PH Test ---
# Look at the p-value for each variable and for the 'GLOBAL' test.
# If any p-value is < 0.05, it suggests the effect of that variable
# changes over time. This would require more advanced modeling
# techniques to fix (e.g., time-dependent covariates), but for now,
# the key is to identify if the problem exists.

# Visualizing the test can also be helpful.
# A flat, horizontal line is what you want to see. A sloped line
# indicates a violation. We will not generate these plots as part
# of the main script, but they can be plotted using:
# # plot(ph_test)

# ===============================================================
# SECTION 3: ASSESSING THE LINEARITY OF CONTINUOUS PREDICTORS --
#
# The model also assumes the effect of a continuous variable (like Age)
# is linear. This means that a one-year increase in age has the same
# impact on risk for a 30-year-old as it does for a 70-year-old.
# This is often not true in biology. We can check this by fitting a
# more flexible model using splines.
# ===============================================================
cat("\n--- SECTION 3: Linearity Assumption Test for Age ---\n")
# We will fit two models and compare them:
# 1. The original model assuming a linear effect of Age.
# 2. A new model using a "natural spline" for Age (`pspline`). This
#    allows the model to fit a flexible, non-linear curve for Age.

# Model 2: The non-linear model with splines
# The `pspline()` function allows for a flexible, smoothed fit.
# All other predictors remain the same.
fml_spline <- as.formula(paste("surv_obj_train ~ pspline(Age) +",
                               paste(predictors[-1], collapse=" + "))) # predictors[-1] removes 'Age'
model_spline <- coxph(fml_spline, data = train_data)

# We use an ANOVA to compare the two models.
# H0: The simpler (linear) model is sufficient.
# A p-value < 0.05 suggests the more complex (non-linear) model
# provides a significantly better fit, meaning the linearity
# assumption was violated.
linearity_test <- anova(model_trained, model_spline)
print(linearity_test)

# --- Visualizing the Linearity Test ---
# We can visualize the effect of Age from the spline model to see if it's
# linear. We use the `ggpredict()` function to get the estimated effect
# of Age from our non-linear model.
cat("\n--- Generating plot of non-linear effect for Age... ---\n")
# ggpredict calculates the predicted values (risk) for the term "Age".
age_effect <- ggpredict(model_spline, terms = "Age")

p_age_linearity <- ggplot(age_effect, aes(x = x, y = predicted)) +
  geom_line(color = "steelblue", size = 1) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.2) +
  theme_minimal() +
  labs(
    title = "Fitted Effect of Age on Log-Hazard (from Spline Model)",
    x = "Age",
    y = "Predicted Log-Hazard (Risk)"
  )
print(p_age_linearity)
save_plot_both(p_age_linearity, base_filename = "Lesson19_Age_Linearity_Check")
cat("--- Plot 'Lesson19_Age_Linearity_Check.pdf/.png' saved. ---\n")

# --- Interpretation of the Linearity Test ---
# If the p-value is small (< 0.05), it tells us that modeling Age with
# a flexible curve is significantly better. The simple linear term was
# not adequately capturing the risk associated with age. A clinician
# might interpret this as "the risk from age accelerates in older patients."

cat("\n--- Lesson 19 Complete ---\n")
cat("This lesson provides the tools to critically evaluate your own models.\n")
cat("A model that passes these checks is significantly more robust and trustworthy.\n")

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================
# 1. Look at the output of the `cox.zph()` test. Are any variables
#    violating the proportional hazards assumption? What about the
#    GLOBAL test?
#
# 2. Look at the ANOVA result comparing the linear and spline models
#    for Age. What does the p-value tell you about the linearity
#    assumption for Age in this dataset?
#
# 3. If a variable violates the PH assumption, what could you do?
#    (Hint: Research "stratification in Cox models" or "time-dependent
#    covariates"). This is an advanced topic but is the correct
#    next step in a real-world analysis.

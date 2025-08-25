# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# Load packages and data via utilities
source("R/utils.R")
load_required_packages(c("survival", "readxl", "dplyr", "ggplot2"))

data <- load_clinical_data("Data/ClinicalData.xlsx")
data_surv_all <- filter_complete_cases(data, c("OS", "Censor"))

# ===============================================================
# LESSON 6: MULTIVARIABLE SURVIVAL ANALYSIS WITH COX MODEL
# ===============================================================

# LEARNING OBJECTIVES:
# - Understand how to use the Cox proportional hazards model
# - Model survival using multiple covariates
# - Interpret hazard ratios (HR) and statistical significance

# WHAT YOU'LL LEARN:
# The Cox model allows us to estimate how several clinical variables
# jointly affect the hazard (risk) of an event (e.g., death).
# It provides hazard ratios, which reflect how much a variable increases or decreases risk.

# SECTION 1: BUILD COX MODEL ----------------------------------

# Check if required columns exist (standardized names)
required_cols <- c("OS", "Censor", "Age", "Gender", "Grade", 
                   "IDH_mutation_status", "MGMTp_methylation_status", "PRS_type", 
                   "Chemo_status", "Radio_status")

missing_cols <- required_cols[!required_cols %in% names(data)]
if (length(missing_cols) > 0) {
  cat("Warning: Missing columns for Cox model:", paste(missing_cols, collapse = ", "), "\n")
  cat("Proceeding with available columns...\n")
}

# Fit a multivariate Cox model using clinical predictors (OS in days)
tryCatch({
  cox_model <- coxph(Surv(OS, Censor) ~ Age + Gender + Grade + 
                       IDH_mutation_status + MGMTp_methylation_status +
                       PRS_type + Chemo_status + Radio_status, 
                     data = data)
  print(summary(cox_model))
}, error = function(e) {
  cat("Error fitting Cox model:", e$message, "\n")
  cat("This may be due to missing data or insufficient sample size.\n")
})

# Quick Kaplan-Meier plot (overall) for output
surv_obj <- Surv(data_surv_all$OS, data_surv_all$Censor)
km_fit <- survfit(surv_obj ~ 1)
km_df <- data.frame(time = km_fit$time, surv = km_fit$surv)

p_km <- ggplot(km_df, aes(x = to_months(time), y = surv)) +
  geom_step(color = "steelblue") +
  labs(title = "Kaplan-Meier Overall Survival",
       x = "Time (months)", y = "Survival Probability") +
  theme_minimal()
print(p_km)
save_plot_both(p_km, base_filename = "Lesson6_KM_Overall")

# TIP:
# HR > 1 → Higher risk; HR < 1 → Lower risk

# PRACTICE TASKS ----------------------------------------------

# 1. Which variables are statistically significant? (p < 0.05)
# 2. Interpret the hazard ratio for Age: is older age associated with increased hazard?
# 3. Interpret the hazard ratio for IDH mutation: does mutation reduce risk?
# 4. Remove a variable (e.g., PRS_type) and re-run the model: how do coefficients change?
# 5. OPTIONAL: Use ggforest(cox_model, data = data) from survminer to visualize HRs.
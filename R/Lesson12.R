# ===============================================================
# LESSON 12: A COMPREHENSIVE CLINICAL SURVIVAL ANALYSIS WORKFLOW
# ===============================================================
#
# OBJECTIVE:
# To integrate several key analytical steps into a comprehensive
# workflow that mirrors a typical clinical research project. This lesson
# covers creating a "Table 1", assessing missing data, screening
# variables with a forest plot, building a risk model, and checking
# model assumptions.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
load_required_packages(c("readxl", "dplyr", "ggplot2", "survival"))
data <- load_clinical_data("Data/ClinicalData.xlsx")
cat("--- LESSON 12: Comprehensive Survival Workflow ---\n")

# ===============================================================
# SECTION 1: BASELINE CHARACTERISTICS (TABLE 1) -----------------
# This section generates the descriptive statistics for your cohort,
# which are typically presented in the first table of a clinical paper.
# ===============================================================
cat("\n--- SECTION 1: BASELINE CHARACTERISTICS ---\n")
summarize_factor <- function(x) {
  tb <- sort(table(x, useNA = "no"), decreasing = TRUE)
  as.data.frame(tb)
}
cat("Categorical variable counts:\n")
if ("Gender" %in% names(data)) print(summarize_factor(data$Gender))
if ("Grade" %in% names(data)) print(summarize_factor(data$Grade))
# ... (add other key factors as needed) ...
cat("\nContinuous variable summary (Age):\n")
if ("Age" %in% names(data)) print(summary(data$Age))

# ===============================================================
# SECTION 2: MISSINGNESS PROFILE ------------------------------
# It is critical to assess how much data is missing for each variable.
# This informs the feasibility of your models and identifies data quality issues.
# ===============================================================
cat("\n--- SECTION 2: MISSINGNESS PROFILE ---\n")
miss_df <- data.frame(
  Variable = names(data),
  Missing = sapply(data, function(x) sum(is.na(x)))
)
p_miss <- ggplot(miss_df, aes(x = reorder(Variable, Missing), y = Missing)) +
  geom_col(fill = "firebrick", alpha = 0.8) + coord_flip() + theme_minimal() +
  labs(title = "Missing Data Profile", x = "Variable", y = "Count of Missing Values")
print(p_miss)
save_plot_both(p_miss, base_filename = "Lesson12_Missingness_Profile")

# ===============================================================
# SECTION 3: UNIVARIABLE COX ANALYSIS (FOREST PLOT) -------------
# This automates the process of testing each variable's association
# with survival one by one (univariable) and visualizes the results.
# ===============================================================
cat("\n--- SECTION 3: UNIVARIABLE COX HAZARD RATIOS ---\n")
if (all(c("OS", "Censor") %in% names(data))) {
  surv_obj <- Surv(time = data$OS, event = data$Censor)
  candidate_vars <- c("Age", "Gender", "Grade", "IDH_mutation_status", "MGMTp_methylation_status", "PRS_type")
  candidate_vars <- intersect(candidate_vars, names(data)) # Use only available vars
  results <- list()
  # This 'for' loop iterates through each variable in our list.
  for (v in candidate_vars) {
    fml <- as.formula(paste("surv_obj ~", v)) # Creates the formula, e.g., 'surv_obj ~ Age'
    fit <- tryCatch(coxph(fml, data = data), error = function(e) NULL)
    if (!is.null(fit)) {
      s <- summary(fit)
      # Extract HR, 95% CI, and p-value
      results[[v]] <- data.frame(Term = rownames(s$coef), HR = s$conf.int[,1],
                                 Lower = s$conf.int[,3], Upper = s$conf.int[,4],
                                 p = s$waldtest["pvalue"])
    }
  }
  if (length(results) > 0) {
    uni_df <- do.call(rbind, results)
    # A forest plot visualizes the Hazard Ratios and 95% CIs for multiple variables at once.
    p_forest <- ggplot(uni_df, aes(x = HR, y = reorder(Term, HR))) +
      geom_point(color = "steelblue") +
      geom_errorbarh(aes(xmin = Lower, xmax = Upper), height = 0.2) +
      geom_vline(xintercept = 1, linetype = "dashed") +
      scale_x_log10() + # Use a log scale for HRs
      theme_minimal() + labs(title = "Univariable Hazard Ratios", x = "Hazard Ratio (log scale)", y = "")
    print(p_forest)
    save_plot_both(p_forest, base_filename = "Lesson12_UniCox_Forest")
  }
}

# ===============================================================
# SECTION 4: MULTIVARIABLE RISK STRATIFICATION ---------------
# Here, we build a multivariable model and use its output to create
# low, medium, and high-risk groups for patients.
# ===============================================================
cat("\n--- SECTION 4: RISK STRATIFICATION FROM MULTIVARIABLE COX ---\n")
mv_fit <- NULL
if (all(c("OS", "Censor") %in% names(data))) {
  mv_vars <- c("Age", "Grade", "IDH_mutation_status", "MGMTp_methylation_status")
  mv_vars <- intersect(mv_vars, names(data))
  if (length(mv_vars) >= 2) {
    # Build the model using only complete cases for the selected variables.
    fml <- as.formula(paste("Surv(OS, Censor) ~", paste(mv_vars, collapse = " + ")))
    mv_fit <- tryCatch(coxph(fml, data = data, na.action = na.omit), error = function(e) NULL)
    if (!is.null(mv_fit)) {
      # 'predict(..., type = "lp")' calculates the linear predictor, a risk score for each patient.
      risk_score <- predict(mv_fit, type = "lp")
      # 'cut()' divides the continuous risk scores into three groups (tertiles).
      risk_groups <- cut(risk_score, breaks = quantile(risk_score, probs = c(0, 1/3, 2/3, 1)),
                         labels = c("Low", "Medium", "High"), include.lowest = TRUE)
      # Plot a KM curve to see if our risk groups have different survival outcomes.
      rg_fit <- survfit(Surv(OS, Censor) ~ risk_groups, data = na.omit(data[, all.vars(fml)]))
      # Plotting code follows...
    }
  }
}

# ===============================================================
# SECTION 5: PROPORTIONAL HAZARDS (PH) ASSUMPTION CHECKS --------
# A key assumption of the Cox model is that the effect of a variable
# (its HR) is constant over time. This test checks that assumption.
# ===============================================================
cat("\n--- SECTION 5: PROPORTIONAL HAZARDS CHECKS ---\n")
if (!is.null(mv_fit)) {
  # The 'cox.zph()' function performs the test.
  zph_test <- tryCatch(cox.zph(mv_fit), error = function(e) NULL)
  if (!is.null(zph_test)) {
    print(zph_test)
    # A p-value > 0.05 for GLOBAL and for each variable indicates the assumption is met.
    # A small p-value (< 0.05) suggests the assumption is violated for that term.
    # Diagnostic plots are also generated.
    # Plotting code follows...
  }
}

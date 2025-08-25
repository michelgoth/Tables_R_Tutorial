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
load_required_packages(c("readxl", "survival", "dplyr", "ggplot2", "gtsummary", "flextable", "survminer"))

# Load and impute the clinical data
# NOTE: For Table 1 and missingness, we use the raw_data. For modeling, we use the imputed data.
raw_data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- impute_clinical_data(raw_data)

cat("--- LESSON 12: Comprehensive Survival Workflow ---\n")

# ===============================================================
# SECTION 1: BASELINE CHARACTERISTICS (TABLE 1) ----------------
# In clinical papers, "Table 1" is the standard table of baseline
# patient demographics and clinical characteristics.
message("--- Generating and saving Table 1 ---")
table1 <- raw_data %>%
  select(Age, Gender, Grade, PRS_type, IDH_mutation_status, MGMTp_methylation_status, Chemo_status, Radio_status) %>%
  tbl_summary(
    by = Grade,
    label = list(
      Age ~ "Age (Years)",
      Gender ~ "Gender",
      PRS_type ~ "Tumor Type",
      IDH_mutation_status ~ "IDH Status",
      MGMTp_methylation_status ~ "MGMT Promoter Status",
      Chemo_status ~ "Received Chemotherapy",
      Radio_status ~ "Received Radiotherapy"
    )
  ) %>%
  add_overall() %>%
  add_p() %>%
  bold_labels()

# Save the table to a Word document
save_as_docx(table1, path = "plots/Table1_Baseline_Characteristics.docx")
message("--- Baseline characteristics table saved to 'plots/Table1_Baseline_Characteristics.docx' ---")

# ===============================================================
# SECTION 2: MISSINGNESS PROFILE ------------------------------
message("--- Generating Missingness Profile ---")
miss_df <- data.frame(
  Variable = names(raw_data),
  Missing = sapply(raw_data, function(x) sum(is.na(x)))
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
# NOTE: All modeling is performed on the IMPUTED 'data' object.
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
# NOTE: All modeling is performed on the IMPUTED 'data' object.
if (all(c("OS", "Censor") %in% names(data))) {
  mv_vars <- c("Age", "Grade", "IDH_mutation_status", "MGMTp_methylation_status")
  mv_vars <- intersect(mv_vars, names(data))
  if (length(mv_vars) >= 2) {
    # Build the model using the complete, imputed dataset.
    fml <- as.formula(paste("Surv(OS, Censor) ~", paste(mv_vars, collapse = " + ")))
    mv_fit <- tryCatch(coxph(fml, data = data), error = function(e) NULL)
    if (!is.null(mv_fit)) {
      # 'predict(..., type = "lp")' calculates the linear predictor, a risk score for each patient.
      risk_score <- predict(mv_fit, type = "lp")
      # 'cut()' divides the continuous risk scores into three groups (tertiles).
      risk_groups <- cut(risk_score, breaks = quantile(risk_score, probs = c(0, 1/3, 2/3, 1)),
                         labels = c("Low", "Medium", "High"), include.lowest = TRUE)
      # Plot a KM curve to see if our risk groups have different survival outcomes.
      # We can use the main 'data' object as it is complete.
      rg_fit <- survfit(Surv(OS, Censor) ~ risk_groups, data = data)
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

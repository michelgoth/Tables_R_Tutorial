# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")[["CRAN"]])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# List of required packages
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", 
                       "corrplot", "car", "psych", "ggpubr", "rstatix", 
                       "nlme", "lme4", "lmerTest", "emmeans", "multcomp")

# Install missing packages
installed <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!(pkg %in% installed)) {
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
    }, error = function(e) {
      cat(sprintf("Failed to install %s: %s\n", pkg, e$message))
    })
  }
}

# Load libraries
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    cat(sprintf("Failed to load package: %s\n", pkg))
  }
}

# Data file path
DATA_PATH <- "Data/ClinicalData.xlsx"
if (!file.exists(DATA_PATH)) {
  stop(paste0("ERROR: Data file not found at ", DATA_PATH, ". Please ensure the file exists."))
}

# Load the data
suppressWarnings({
  data <- tryCatch({
    readxl::read_excel(DATA_PATH)
  }, error = function(e) {
    stop(paste0("ERROR: Could not read data file: ", e$message))
  })
})

# Convert key columns to appropriate types (if present)
if ("Grade" %in% names(data)) data$Grade <- as.factor(data$Grade)
if ("Gender" %in% names(data)) data$Gender <- as.factor(data$Gender)
if ("PRS_type" %in% names(data)) data$PRS_type <- as.factor(data$PRS_type)
if ("IDH_mutation_status" %in% names(data)) data$IDH_mutation_status <- as.factor(data$IDH_mutation_status)
if ("MGMTp_methylation_status" %in% names(data)) data$MGMTp_methylation_status <- as.factor(data$MGMTp_methylation_status)
if ("Histology" %in% names(data)) data$Histology <- as.factor(data$Histology)
if ("Age" %in% names(data)) data$Age <- as.numeric(data$Age)
if ("OS" %in% names(data)) data$OS <- as.numeric(data$OS)

# ===============================================================
# LESSON 14: LONGITUDINAL DATA ANALYSIS
# ===============================================================

# LEARNING OBJECTIVES:
# - Understand repeated measures and longitudinal data
# - Fit linear mixed-effects models (LMM)
# - Analyze time trends and treatment effects
# - Handle missing data and correlation structures
# - Interpret results in clinical context

# WHAT YOU'LL LEARN:
# Longitudinal data analysis is essential for clinical trials and
# observational studies where patients are measured repeatedly over time.
# This lesson covers mixed-effects models and time-series analysis.

cat("=== LESSON 14: LONGITUDINAL DATA ANALYSIS ===\n")
cat("Sample size:", nrow(data), "patients\n")
cat("Available variables:", paste(names(data), collapse = ", "), "\n\n")

# SECTION 1: CREATING LONGITUDINAL DATASET -------------------

cat("SECTION 1: CREATING LONGITUDINAL DATASET\n")
cat("Simulating longitudinal clinical data...\n\n")

# Create a simulated longitudinal dataset
# In real scenarios, this would come from repeated measurements
set.seed(123)

# Create patient IDs
n_patients <- min(100, nrow(data))
patient_ids <- 1:n_patients

# Create time points (baseline, 3 months, 6 months, 12 months)
time_points <- c(0, 3, 6, 12)

# Create longitudinal dataset
long_data <- expand.grid(
  patient_id = patient_ids,
  time = time_points
)

# Add baseline characteristics
baseline_data <- data[1:n_patients, ]
long_data <- merge(long_data, baseline_data[, c("Age", "Gender", "Grade")], 
                   by.x = "patient_id", by.y = 0, all.x = TRUE)

# Simulate longitudinal outcome (e.g., quality of life score)
# Baseline QoL score based on age and grade
long_data$baseline_qol <- 80 - (long_data$Age - 50) * 0.5 + 
                         ifelse(long_data$Grade == "WHO IV", -10, 0) +
                         rnorm(nrow(long_data), 0, 5)

# Time effect (decline over time)
long_data$time_effect <- -2 * long_data$time

# Treatment effect (chemotherapy improves QoL initially, then declines)
long_data$treatment_effect <- ifelse(long_data$time <= 3, 5, -3)

# Random effects (patient-specific variation)
patient_effects <- rnorm(n_patients, 0, 3)
long_data$patient_effect <- patient_effects[long_data$patient_id]

# Final QoL score
long_data$qol_score <- long_data$baseline_qol + long_data$time_effect + 
                      long_data$treatment_effect + long_data$patient_effect + 
                      rnorm(nrow(long_data), 0, 2)

# Ensure QoL scores are within reasonable bounds
long_data$qol_score <- pmax(0, pmin(100, long_data$qol_score))

cat("Longitudinal dataset created:\n")
cat("Number of patients:", n_patients, "\n")
cat("Number of time points:", length(time_points), "\n")
cat("Total observations:", nrow(long_data), "\n")
cat("Variables: patient_id, time, Age, Gender, Grade, qol_score\n\n")

# SECTION 2: EXPLORATORY DATA ANALYSIS -----------------------

cat("SECTION 2: EXPLORATORY DATA ANALYSIS\n")
cat("Exploring longitudinal patterns...\n\n")

# Summary statistics by time point
cat("QoL Score Summary by Time Point:\n")
time_summary <- aggregate(qol_score ~ time, data = long_data, 
                         FUN = function(x) c(mean = mean(x), sd = sd(x), n = length(x)))
print(time_summary)

# Summary by treatment group (simulate treatment assignment)
long_data$treatment <- ifelse(long_data$patient_id %% 2 == 0, "Treatment", "Control")

cat("\nQoL Score Summary by Treatment Group:\n")
treatment_summary <- aggregate(qol_score ~ treatment + time, data = long_data, 
                              FUN = function(x) c(mean = mean(x), sd = sd(x), n = length(x)))
print(treatment_summary)

# SECTION 3: LINEAR MIXED-EFFECTS MODEL ----------------------

cat("\nSECTION 3: LINEAR MIXED-EFFECTS MODEL\n")
cat("Fitting mixed-effects model for longitudinal data...\n\n")

tryCatch({
  # Fit linear mixed-effects model
  # Fixed effects: time, treatment, time*treatment interaction
  # Random effects: patient-specific intercepts and slopes
  
  lmm_model <- lmer(qol_score ~ time * treatment + (1 + time | patient_id), 
                    data = long_data)
  
  cat("Linear Mixed-Effects Model Summary:\n")
  print(summary(lmm_model))
  
  # Extract fixed effects
  fixed_effects <- fixef(lmm_model)
  cat("\nFixed Effects:\n")
  for (i in 1:length(fixed_effects)) {
    cat(names(fixed_effects)[i], ":", round(fixed_effects[i], 3), "\n")
  }
  
  # Extract random effects variance
  random_effects <- VarCorr(lmm_model)
  cat("\nRandom Effects Variance:\n")
  print(random_effects)
  
  # Model fit statistics
  cat("\nModel Fit Statistics:\n")
  cat("AIC:", round(AIC(lmm_model), 2), "\n")
  cat("BIC:", round(BIC(lmm_model), 2), "\n")
  cat("Log-likelihood:", round(logLik(lmm_model), 2), "\n")
  
}, error = function(e) {
  cat("Error in mixed-effects modeling:", e$message, "\n")
})

# SECTION 4: TIME TREND ANALYSIS -----------------------------

cat("\nSECTION 4: TIME TREND ANALYSIS\n")
cat("Analyzing time trends and treatment effects...\n\n")

tryCatch({
  # Fit simpler model for time trend analysis
  time_model <- lmer(qol_score ~ time + (1 | patient_id), data = long_data)
  
  cat("Time Trend Model:\n")
  print(summary(time_model))
  
  # Test for significant time effect
  time_coef <- fixef(time_model)["time"]
  time_se <- sqrt(vcov(time_model)["time", "time"])
  time_t <- time_coef / time_se
  time_p <- 2 * pt(-abs(time_t), df = nrow(long_data) - 2)
  
  cat("\nTime Effect Test:\n")
  cat("Coefficient:", round(time_coef, 3), "\n")
  cat("Standard Error:", round(time_se, 3), "\n")
  cat("t-value:", round(time_t, 3), "\n")
  cat("p-value:", round(time_p, 4), "\n")
  
  if (time_p < 0.05) {
    cat("Interpretation: Significant time trend detected\n")
  } else {
    cat("Interpretation: No significant time trend\n")
  }
  
}, error = function(e) {
  cat("Error in time trend analysis:", e$message, "\n")
})

# SECTION 5: TREATMENT EFFECT ANALYSIS -----------------------

cat("\nSECTION 5: TREATMENT EFFECT ANALYSIS\n")
cat("Analyzing treatment effects over time...\n\n")

tryCatch({
  # Fit treatment model
  treatment_model <- lmer(qol_score ~ treatment * time + (1 | patient_id), 
                         data = long_data)
  
  cat("Treatment Effect Model:\n")
  print(summary(treatment_model))
  
  # Test treatment effect at each time point
  cat("\nTreatment Effects by Time Point:\n")
  
  for (t in time_points) {
    # Create contrast for treatment effect at specific time
    contrast_data <- data.frame(
      time = t,
      treatment = c("Control", "Treatment")
    )
    
    # Predict values
    predictions <- predict(treatment_model, newdata = contrast_data, re.form = NA)
    treatment_effect <- predictions[2] - predictions[1]
    
    cat("Time", t, "months - Treatment effect:", round(treatment_effect, 2), "\n")
  }
  
  # Test for treatment-by-time interaction
  interaction_test <- anova(treatment_model)
  cat("\nTreatment × Time Interaction Test:\n")
  print(interaction_test)
  
}, error = function(e) {
  cat("Error in treatment effect analysis:", e$message, "\n")
})

# SECTION 6: MISSING DATA HANDLING ---------------------------

cat("\nSECTION 6: MISSING DATA HANDLING\n")
cat("Handling missing data in longitudinal studies...\n\n")

# Create missing data pattern
set.seed(456)
missing_prob <- 0.1  # 10% missing data
long_data$missing_indicator <- rbinom(nrow(long_data), 1, missing_prob)

# Create dataset with missing values
long_data_missing <- long_data
long_data_missing$qol_score[long_data_missing$missing_indicator == 1] <- NA

cat("Missing Data Summary:\n")
cat("Total observations:", nrow(long_data_missing), "\n")
cat("Missing observations:", sum(is.na(long_data_missing$qol_score)), "\n")
cat("Missing percentage:", round(mean(is.na(long_data_missing$qol_score)) * 100, 1), "%\n")

# Analyze missing data pattern
missing_by_time <- aggregate(is.na(qol_score) ~ time, data = long_data_missing, FUN = mean)
cat("\nMissing Data by Time Point:\n")
print(missing_by_time)

missing_by_treatment <- aggregate(is.na(qol_score) ~ treatment, data = long_data_missing, FUN = mean)
cat("\nMissing Data by Treatment Group:\n")
print(missing_by_treatment)

# Fit model with missing data (lmer handles missing data automatically)
tryCatch({
  missing_model <- lmer(qol_score ~ time * treatment + (1 | patient_id), 
                       data = long_data_missing)
  
  cat("\nModel with Missing Data:\n")
  print(summary(missing_model))
  
  cat("\nNote: Mixed-effects models handle missing data automatically\n")
  cat("under the assumption of missing at random (MAR)\n")
  
}, error = function(e) {
  cat("Error in missing data analysis:", e$message, "\n")
})

# SECTION 7: CORRELATION STRUCTURE ANALYSIS ------------------

cat("\nSECTION 7: CORRELATION STRUCTURE ANALYSIS\n")
cat("Analyzing correlation patterns in longitudinal data...\n\n")

tryCatch({
  # Calculate correlation matrix for repeated measures
  # Reshape data to wide format
  wide_data <- reshape(long_data[, c("patient_id", "time", "qol_score")], 
                      idvar = "patient_id", 
                      timevar = "time", 
                      direction = "wide")
  
  # Remove patient_id column for correlation analysis
  cor_data <- wide_data[, -1]
  names(cor_data) <- paste("Time", time_points, "months")
  
  # Calculate correlation matrix
  cor_matrix <- cor(cor_data, use = "pairwise.complete.obs")
  
  cat("Correlation Matrix for QoL Scores:\n")
  print(round(cor_matrix, 3))
  
  # Test for compound symmetry (equal correlations)
  cat("\nCorrelation Pattern Analysis:\n")
  cat("High correlations suggest strong patient-level effects\n")
  cat("Declining correlations suggest time-dependent changes\n")
  
  # Calculate average correlation
  avg_cor <- mean(cor_matrix[upper.tri(cor_matrix)], na.rm = TRUE)
  cat("Average correlation:", round(avg_cor, 3), "\n")
  
}, error = function(e) {
  cat("Error in correlation analysis:", e$message, "\n")
})

# SECTION 8: CLINICAL INTERPRETATION -------------------------

cat("\nSECTION 8: CLINICAL INTERPRETATION\n")
cat("Translating longitudinal analysis to clinical practice...\n\n")

cat("Clinical Applications of Longitudinal Analysis:\n")
cat("1. Treatment Efficacy: Monitor patient response over time\n")
cat("2. Disease Progression: Track symptom changes\n")
cat("3. Quality of Life: Assess patient-reported outcomes\n")
cat("4. Biomarker Dynamics: Study biological changes\n")
cat("5. Personalized Medicine: Individual treatment trajectories\n\n")

cat("Key Considerations:\n")
cat("- Account for within-patient correlation\n")
cat("- Handle missing data appropriately\n")
cat("- Consider time-varying covariates\n")
cat("- Interpret clinical significance\n")
cat("- Validate findings in independent cohorts\n\n")

cat("Reporting Guidelines:\n")
cat("- Describe missing data patterns\n")
cat("- Report model assumptions and diagnostics\n")
cat("- Present effect sizes and confidence intervals\n")
cat("- Discuss clinical relevance of findings\n")
cat("- Consider multiple comparison adjustments\n")

# PRACTICE TASKS ----------------------------------------------

cat("\n=== PRACTICE TASKS ===\n")
cat("1. Fit mixed-effects model with different random effects structures\n")
cat("2. Analyze treatment effects at specific time points\n")
cat("3. Test for different correlation structures\n")
cat("4. Handle missing data using multiple imputation\n")
cat("5. Create patient-specific prediction plots\n\n")

cat("=== CLINICAL INTERPRETATION TIPS ===\n")
cat("- Focus on clinically meaningful time points\n")
cat("- Consider individual patient trajectories\n")
cat("- Account for treatment timing and duration\n")
cat("- Validate models with external data\n")
cat("- Integrate with clinical decision-making\n") 
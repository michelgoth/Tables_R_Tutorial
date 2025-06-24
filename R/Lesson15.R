# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")[["CRAN"]])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# List of required packages
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", 
                       "corrplot", "car", "psych", "ggpubr", "rstatix")

# Optional meta-analysis packages
optional_packages <- c("meta", "metafor", "dmetar", "robvis", "netmeta")

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

# Try to load optional packages
meta_available <- FALSE
for (pkg in optional_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    meta_available <- TRUE
    cat(sprintf("Loaded optional package: %s\n", pkg))
  }
}

if (!meta_available) {
  cat("Note: Meta-analysis packages not available. Running with basic R functions.\n")
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
# LESSON 15: META-ANALYSIS AND SYSTEMATIC REVIEWS
# ===============================================================

# LEARNING OBJECTIVES:
# - Understand meta-analysis principles and methodology
# - Perform fixed and random effects meta-analysis
# - Assess heterogeneity and publication bias
# - Create forest plots and funnel plots
# - Interpret meta-analysis results in clinical context

# WHAT YOU'LL LEARN:
# Meta-analysis combines results from multiple studies to provide
# more precise estimates of treatment effects and identify patterns
# across different populations and settings.

cat("=== LESSON 15: META-ANALYSIS AND SYSTEMATIC REVIEWS ===\n")
cat("Sample size:", nrow(data), "patients\n")
cat("Available variables:", paste(names(data), collapse = ", "), "\n\n")

# SECTION 1: CREATING META-ANALYSIS DATASET ------------------

cat("SECTION 1: CREATING META-ANALYSIS DATASET\n")
cat("Simulating multiple study results for meta-analysis...\n\n")

# Create simulated meta-analysis dataset
# In real scenarios, this would come from systematic literature review
set.seed(123)

# Simulate 10 studies with different sample sizes and effects
n_studies <- 10
study_data <- data.frame(
  study_id = paste("Study", 1:n_studies),
  year = sample(2015:2023, n_studies, replace = TRUE),
  n_treatment = sample(50:200, n_studies, replace = TRUE),
  n_control = sample(50:200, n_studies, replace = TRUE),
  mean_treatment = rnorm(n_studies, 15, 2),  # Survival months
  mean_control = rnorm(n_studies, 12, 2),
  sd_treatment = rnorm(n_studies, 4, 0.5),
  sd_control = rnorm(n_studies, 4, 0.5)
)

# Calculate effect sizes (mean difference)
study_data$mean_diff <- study_data$mean_treatment - study_data$mean_control

# Calculate standard errors
study_data$se_diff <- sqrt(
  (study_data$sd_treatment^2 / study_data$n_treatment) + 
  (study_data$sd_control^2 / study_data$n_control)
)

# Calculate 95% confidence intervals
study_data$ci_lower <- study_data$mean_diff - 1.96 * study_data$se_diff
study_data$ci_upper <- study_data$mean_diff + 1.96 * study_data$se_diff

# Calculate weights (inverse variance)
study_data$weight <- 1 / (study_data$se_diff^2)

cat("Meta-Analysis Dataset Summary:\n")
cat("Number of studies:", nrow(study_data), "\n")
cat("Year range:", min(study_data$year), "-", max(study_data$year), "\n")
cat("Total sample size:", sum(study_data$n_treatment + study_data$n_control), "\n\n")

print(study_data[, c("study_id", "year", "n_treatment", "n_control", "mean_diff", "se_diff")])

# SECTION 2: BASIC META-ANALYSIS CALCULATIONS ----------------

cat("\nSECTION 2: BASIC META-ANALYSIS CALCULATIONS\n")
cat("Performing basic meta-analysis calculations...\n\n")

# Fixed effects meta-analysis (manual calculation)
total_weight <- sum(study_data$weight)
weighted_mean <- sum(study_data$mean_diff * study_data$weight) / total_weight
se_fixed <- sqrt(1 / total_weight)
ci_lower_fixed <- weighted_mean - 1.96 * se_fixed
ci_upper_fixed <- weighted_mean + 1.96 * se_fixed
z_fixed <- weighted_mean / se_fixed
p_fixed <- 2 * (1 - pnorm(abs(z_fixed)))

cat("Fixed Effects Meta-Analysis (Manual Calculation):\n")
cat("Effect size:", round(weighted_mean, 3), "\n")
cat("Standard error:", round(se_fixed, 3), "\n")
cat("95% CI:", round(ci_lower_fixed, 3), "to", round(ci_upper_fixed, 3), "\n")
cat("Z-statistic:", round(z_fixed, 3), "\n")
cat("p-value:", round(p_fixed, 4), "\n")

if (p_fixed < 0.05) {
  cat("Interpretation: Significant treatment effect (fixed effects)\n")
} else {
  cat("Interpretation: No significant treatment effect (fixed effects)\n")
}

# Random effects meta-analysis (manual calculation)
# Calculate Q statistic
q_statistic <- sum(study_data$weight * (study_data$mean_diff - weighted_mean)^2)
df_q <- n_studies - 1

# Calculate tau-squared (DerSimonian-Laird estimator)
if (q_statistic > df_q) {
  tau_squared <- (q_statistic - df_q) / (total_weight - sum(study_data$weight^2) / total_weight)
} else {
  tau_squared <- 0
}

# Calculate random effects weights
study_data$weight_random <- 1 / (study_data$se_diff^2 + tau_squared)
total_weight_random <- sum(study_data$weight_random)
weighted_mean_random <- sum(study_data$mean_diff * study_data$weight_random) / total_weight_random
se_random <- sqrt(1 / total_weight_random)
ci_lower_random <- weighted_mean_random - 1.96 * se_random
ci_upper_random <- weighted_mean_random + 1.96 * se_random
z_random <- weighted_mean_random / se_random
p_random <- 2 * (1 - pnorm(abs(z_random)))

# Calculate I-squared
i_squared <- max(0, (q_statistic - df_q) / q_statistic * 100)

cat("\nRandom Effects Meta-Analysis (Manual Calculation):\n")
cat("Effect size:", round(weighted_mean_random, 3), "\n")
cat("Standard error:", round(se_random, 3), "\n")
cat("95% CI:", round(ci_lower_random, 3), "to", round(ci_upper_random, 3), "\n")
cat("Z-statistic:", round(z_random, 3), "\n")
cat("p-value:", round(p_random, 4), "\n")
cat("Tau-squared:", round(tau_squared, 3), "\n")
cat("I-squared:", round(i_squared, 1), "%\n")

if (p_random < 0.05) {
  cat("Interpretation: Significant treatment effect (random effects)\n")
} else {
  cat("Interpretation: No significant treatment effect (random effects)\n")
}

# SECTION 3: HETEROGENEITY ANALYSIS --------------------------

cat("\nSECTION 3: HETEROGENEITY ANALYSIS\n")
cat("Assessing study heterogeneity...\n\n")

cat("Heterogeneity Analysis:\n")
cat("Q statistic:", round(q_statistic, 3), "\n")
cat("Degrees of freedom:", df_q, "\n")
cat("p-value for heterogeneity:", round(1 - pchisq(q_statistic, df_q), 4), "\n")
cat("I-squared:", round(i_squared, 1), "%\n")
cat("Tau-squared:", round(tau_squared, 3), "\n")

# Interpret heterogeneity
cat("\nHeterogeneity Interpretation:\n")
if (1 - pchisq(q_statistic, df_q) < 0.05) {
  cat("- Significant heterogeneity detected (p < 0.05)\n")
} else {
  cat("- No significant heterogeneity (p >= 0.05)\n")
}

if (i_squared < 25) {
  cat("- Low heterogeneity (I² < 25%)\n")
} else if (i_squared < 50) {
  cat("- Moderate heterogeneity (I² 25-50%)\n")
} else if (i_squared < 75) {
  cat("- Substantial heterogeneity (I² 50-75%)\n")
} else {
  cat("- Considerable heterogeneity (I² > 75%)\n")
}

# SECTION 4: FOREST PLOT SIMULATION ---------------------------

cat("\nSECTION 4: FOREST PLOT SIMULATION\n")
cat("Creating forest plot data...\n\n")

# Create forest plot data
forest_data <- data.frame(
  Study = study_data$study_id,
  Effect = study_data$mean_diff,
  Lower = study_data$ci_lower,
  Upper = study_data$ci_upper,
  Weight = study_data$weight / total_weight * 100
)

cat("Forest Plot Data:\n")
print(forest_data)

# Overall effect
overall_effect <- data.frame(
  Study = "Overall (Fixed)",
  Effect = weighted_mean,
  Lower = ci_lower_fixed,
  Upper = ci_upper_fixed,
  Weight = 100
)

cat("\nOverall Effect (Fixed):\n")
print(overall_effect)

# SECTION 5: PUBLICATION BIAS ASSESSMENT ---------------------

cat("\nSECTION 5: PUBLICATION BIAS ASSESSMENT\n")
cat("Assessing potential publication bias...\n\n")

# Egger's test (simplified version)
# Calculate precision (1/SE) and effect size
study_data$precision <- 1 / study_data$se_diff

# Linear regression of effect size on precision
egger_model <- lm(mean_diff ~ precision, data = study_data)
egger_intercept <- coef(egger_model)[1]
egger_se <- summary(egger_model)$coefficients[1, 2]
egger_t <- egger_intercept / egger_se
egger_p <- 2 * (1 - pt(abs(egger_t), df = n_studies - 2))

cat("Egger's Test for Publication Bias:\n")
cat("Intercept:", round(egger_intercept, 3), "\n")
cat("Standard error:", round(egger_se, 3), "\n")
cat("t-value:", round(egger_t, 3), "\n")
cat("p-value:", round(egger_p, 4), "\n")

if (egger_p < 0.05) {
  cat("Interpretation: Potential publication bias detected\n")
} else {
  cat("Interpretation: No significant publication bias\n")
}

# SECTION 6: SENSITIVITY ANALYSIS -----------------------------

cat("\nSECTION 6: SENSITIVITY ANALYSIS\n")
cat("Performing sensitivity analysis...\n\n")

# Leave-one-out sensitivity analysis
cat("Leave-One-Out Sensitivity Analysis:\n")

sensitivity_results <- data.frame(
  study_removed = character(),
  effect_size = numeric(),
  ci_lower = numeric(),
  ci_upper = numeric(),
  p_value = numeric()
)

for (i in 1:nrow(study_data)) {
  # Remove one study at a time
  subset_data <- study_data[-i, ]
  
  # Recalculate fixed effects
  subset_weight <- sum(subset_data$weight)
  subset_mean <- sum(subset_data$mean_diff * subset_data$weight) / subset_weight
  subset_se <- sqrt(1 / subset_weight)
  subset_ci_lower <- subset_mean - 1.96 * subset_se
  subset_ci_upper <- subset_mean + 1.96 * subset_se
  subset_z <- subset_mean / subset_se
  subset_p <- 2 * (1 - pnorm(abs(subset_z)))
  
  # Store results
  sensitivity_results <- rbind(sensitivity_results, data.frame(
    study_removed = study_data$study_id[i],
    effect_size = subset_mean,
    ci_lower = subset_ci_lower,
    ci_upper = subset_ci_upper,
    p_value = subset_p
  ))
}

print(sensitivity_results)

# Identify influential studies
original_effect <- weighted_mean
effect_changes <- abs(sensitivity_results$effect_size - original_effect)
most_influential <- sensitivity_results$study_removed[which.max(effect_changes)]

cat("\nMost Influential Study:", most_influential, "\n")
cat("Effect change when removed:", round(max(effect_changes), 3), "\n")

# SECTION 7: QUALITY ASSESSMENT -------------------------------

cat("\nSECTION 7: QUALITY ASSESSMENT\n")
cat("Assessing study quality and risk of bias...\n\n")

# Simulate quality assessment data
set.seed(456)
study_data$randomization <- sample(c("Low", "Unclear", "High"), n_studies, replace = TRUE, prob = c(0.2, 0.3, 0.5))
study_data$blinding <- sample(c("Low", "Unclear", "High"), n_studies, replace = TRUE, prob = c(0.3, 0.4, 0.3))
study_data$allocation <- sample(c("Low", "Unclear", "High"), n_studies, replace = TRUE, prob = c(0.1, 0.2, 0.7))
study_data$incomplete_outcome <- sample(c("Low", "Unclear", "High"), n_studies, replace = TRUE, prob = c(0.6, 0.3, 0.1))
study_data$selective_reporting <- sample(c("Low", "Unclear", "High"), n_studies, replace = TRUE, prob = c(0.7, 0.2, 0.1))

cat("Quality Assessment Summary:\n")
quality_summary <- data.frame(
  Domain = c("Randomization", "Blinding", "Allocation", "Incomplete Outcome", "Selective Reporting"),
  Low_Risk = c(sum(study_data$randomization == "Low"), 
               sum(study_data$blinding == "Low"),
               sum(study_data$allocation == "Low"),
               sum(study_data$incomplete_outcome == "Low"),
               sum(study_data$selective_reporting == "Low")),
  Unclear = c(sum(study_data$randomization == "Unclear"),
              sum(study_data$blinding == "Unclear"),
              sum(study_data$allocation == "Unclear"),
              sum(study_data$incomplete_outcome == "Unclear"),
              sum(study_data$selective_reporting == "Unclear")),
  High_Risk = c(sum(study_data$randomization == "High"),
                sum(study_data$blinding == "High"),
                sum(study_data$allocation == "High"),
                sum(study_data$incomplete_outcome == "High"),
                sum(study_data$selective_reporting == "High"))
)

print(quality_summary)

# Overall risk of bias
study_data$overall_bias <- ifelse(
  rowSums(study_data[, c("randomization", "blinding", "allocation", "incomplete_outcome", "selective_reporting")] == "High") >= 3,
  "High",
  ifelse(
    rowSums(study_data[, c("randomization", "blinding", "allocation", "incomplete_outcome", "selective_reporting")] == "Low") >= 3,
    "Low",
    "Unclear"
  )
)

cat("\nOverall Risk of Bias:\n")
print(table(study_data$overall_bias))

# SECTION 8: CLINICAL INTERPRETATION -------------------------

cat("\nSECTION 8: CLINICAL INTERPRETATION\n")
cat("Translating meta-analysis results to clinical practice...\n\n")

cat("Clinical Applications of Meta-Analysis:\n")
cat("1. Evidence Synthesis: Combine results from multiple studies\n")
cat("2. Treatment Guidelines: Inform clinical practice recommendations\n")
cat("3. Research Priorities: Identify gaps in evidence\n")
cat("4. Regulatory Decisions: Support drug approval processes\n")
cat("5. Health Policy: Guide healthcare decision-making\n\n")

cat("Key Considerations for Clinical Interpretation:\n")
cat("- Effect Size: Clinical significance vs. statistical significance\n")
cat("- Heterogeneity: Consistency across studies and populations\n")
cat("- Quality: Risk of bias and study limitations\n")
cat("- Applicability: Generalizability to target population\n")
cat("- Precision: Confidence in the estimate\n\n")

cat("Reporting Guidelines (PRISMA):\n")
cat("- Systematic review protocol\n")
cat("- Literature search strategy\n")
cat("- Study selection process\n")
cat("- Quality assessment methods\n")
cat("- Statistical analysis plan\n")
cat("- Results and interpretation\n")
cat("- Limitations and conclusions\n")

# PRACTICE TASKS ----------------------------------------------

cat("\n=== PRACTICE TASKS ===\n")
cat("1. Perform meta-analysis with different effect measures (OR, RR, SMD)\n")
cat("2. Conduct subgroup analysis by study characteristics\n")
cat("3. Assess publication bias using multiple methods\n")
cat("4. Perform sensitivity analysis excluding low-quality studies\n")
cat("5. Create forest plot and funnel plot visualizations\n\n")

cat("=== CLINICAL INTERPRETATION TIPS ===\n")
cat("- Consider clinical relevance of effect sizes\n")
cat("- Evaluate heterogeneity and its sources\n")
cat("- Assess risk of bias and study quality\n")
cat("- Consider publication bias and small study effects\n")
cat("- Integrate with clinical expertise and patient values\n") 
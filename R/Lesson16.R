# ===============================================================
# LESSON 16: EVALUATING TREATMENT EFFECTS WITH ADJUSTED SURVIVAL ANALYSIS
# ===============================================================
#
# OBJECTIVE:
# To assess the association of a treatment (Radiotherapy) with
# survival while statistically adjusting for other key prognostic
# factors, which helps to mitigate confounding.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
# For this lesson, we will focus on the `survival` and `survminer` packages.
source("R/utils.R")
load_required_packages(c("readxl", "dplyr", "survival", "survminer"))

# Load and impute the clinical data
raw_data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- impute_clinical_data(raw_data)
cat("--- LESSON 16: Radiotherapy Adjusted Analysis ---\n")

# ===============================================================
# SECTION 1: DATA PREPARATION -----------------------------------
# ===============================================================
required_cols <- c("OS", "Censor", "Radio_status")
if (!all(required_cols %in% names(data))) {
  stop("Missing one or more required columns for this analysis.")
}

df <- data %>%
  # Create a clearer factor variable for radiotherapy status.
  dplyr::mutate(Radio_factor = factor(Radio_status, levels = c(0, 1), labels = c("No RT", "RT")))
  # NOTE: The original script filtered for complete cases here. This is
  # no longer necessary as we are using the full, imputed dataset.

# ===============================================================
# SECTION 2: UNAJUSTED (UNIVARIABLE) ANALYSIS -------------------
# First, we look at the "raw" or unadjusted difference in survival
# between the two treatment groups with a Kaplan-Meier plot.
# This can be misleading if the groups are not balanced.
# ===============================================================
# NOTE: The 'df' object is now the full imputed cohort.
surv_obj <- Surv(time = df$OS, event = df$Censor)
fit_km <- survfit(surv_obj ~ Radio_factor, data = df)

# Generate and save a publication-quality Kaplan-Meier plot.
p_km_rt <- ggsurvplot(
  fit_km,
  data = df,
  pval = TRUE,
  conf.int = TRUE,
  risk.table = TRUE,
  title = "Unadjusted Survival by Radiotherapy",
  xlab = "Time (days)",
  legend.title = "Treatment",
  palette = c("firebrick", "forestgreen")
)
ensure_plots_dir()
pdf(file.path("plots", "Lesson16_KM_Radiotherapy.pdf"), width = 9, height = 7)
print(p_km_rt, newpage = FALSE)
dev.off()

# ===============================================================
# SECTION 3: ADJUSTED MULTIVARIABLE COX MODEL -------------------
# To get a more reliable estimate of the treatment effect, we must
# adjust for other important variables (confounders) that might differ
# between the treatment groups, like Age, Grade, and molecular status.
# ===============================================================
adj_vars <- intersect(c("Age", "Grade", "IDH_mutation_status", "MGMTp_methylation_status"), names(df))
# NOTE: The 'df' object is now the full imputed cohort.
cox_formula <- as.formula(paste(
  "Surv(OS, Censor) ~ Radio_factor", # Our variable of interest
  if (length(adj_vars) > 0) paste("+", paste(adj_vars, collapse = " + ")) else "" # Adjusters
))

fit <- tryCatch(coxph(cox_formula, data = df), error = function(e) NULL)
if (!is.null(fit)) {
  print(summary(fit))
  # The Hazard Ratio for 'Radio_factorRT' in this model is the "adjusted HR".
  # It represents the effect of RT after accounting for the other variables.

  # --- Create a Forest Plot of the Adjusted HR ---
  s <- summary(fit)
  # ... (Code to extract coefficients and build the ggplot forest plot) ...
}

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================
# 1. Compare the unadjusted Kaplan-Meier plot with the adjusted Hazard Ratio
#    from the Cox model. Does the story change?

# 2. In the summary output of the Cox model, is the adjusted HR for Radiotherapy
#    statistically significant (p < 0.05)?

# 3. Build a new model to find the adjusted HR for Chemotherapy ('Chemo_factor'),
#    adjusting for the same set of variables.



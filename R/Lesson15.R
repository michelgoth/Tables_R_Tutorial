# ===============================================================
# LESSON 15: TESTING FOR INTERACTION EFFECTS (TMZ x MGMT)
# ===============================================================
#
# OBJECTIVE:
# To test for a statistical interaction, addressing the question:
# Does the effect of a treatment (Temozolomide) on survival depend on
# a patient's biomarker status (MGMT methylation)?
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
# For this lesson, we will focus on the `survival` and `survminer` packages.
source("R/utils.R")
load_required_packages(c("readxl", "dplyr", "survival", "survminer"))

# Load and impute the clinical data
raw_data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- impute_clinical_data(raw_data)
cat("--- LESSON 15: TMZ × MGMT Interaction ---\n")

# ===============================================================
# SECTION 1: DATA PREPARATION -----------------------------------
# ===============================================================
required_cols <- c("OS", "Censor", "Chemo_status", "MGMTp_methylation_status")
if (!all(required_cols %in% names(data))) {
  stop("Missing one or more required columns for this analysis.")
}

df <- data %>%
  # Create a clearer factor variable for chemotherapy status.
  dplyr::mutate(
    Chemo_factor = factor(Chemo_status, levels = c(0, 1), labels = c("No TMZ", "TMZ"))
  ) %>%
  # NOTE: The original script filtered for complete cases here. This is
  # no longer necessary as we are using the full, imputed dataset.
  droplevels()

# ===============================================================
# SECTION 2: VISUALIZING THE INTERACTION WITH STRATIFIED KM PLOTS
# A good first step is to visually check for an interaction. We can do
# this by splitting our data by MGMT status and then plotting the
# effect of TMZ within each subgroup.
# ===============================================================
ensure_plots_dir()
# This 'for' loop iterates through each level of MGMT status (e.g., "methylated", "un-methylated").
for (lvl in levels(df$MGMTp_methylation_status)) {
  # Create a subset of the data for just one MGMT status group.
  df_subset <- df[df$MGMTp_methylation_status == lvl, ]
  if (nrow(df_subset) < 5) next # Skip if the group is too small.

  # Create and plot a Kaplan-Meier curve comparing TMZ vs. No TMZ for this subset.
  surv_obj <- Surv(time = df_subset$OS, event = df_subset$Censor)
  fit_km <- survfit(surv_obj ~ Chemo_factor, data = df_subset)

  # Use ggsurvplot for a publication-quality KM plot for the stratum.
  p_km_stratified <- ggsurvplot(
    fit_km,
    data = df_subset,
    pval = TRUE,
    conf.int = TRUE,
    risk.table = TRUE,
    title = paste("Effect of TMZ in MGMT-", lvl, "Patients"),
    xlab = "Time (days)",
    legend.title = "Treatment",
    palette = c("orange", "purple")
  )

  # Save the plot for the current stratum.
  pdf(file.path("plots", paste0("Lesson15_KM_Treatment_by_MGMT_", lvl, ".pdf")), width = 9, height = 7)
  print(p_km_stratified, newpage = FALSE)
  dev.off()
}

# ===============================================================
# SECTION 3: FORMAL TEST WITH A COX INTERACTION MODEL -----------
# The visual check is suggestive, but the formal statistical test is
# done by including an "interaction term" in the Cox model.
# ===============================================================
# Define other variables to adjust for.
adj_vars <- intersect(c("Age", "Grade"), names(df))
# NOTE: The 'df' object is now the full imputed cohort.
surv_obj_all <- Surv(time = df$OS, event = df$Censor)

# The formula 'Chemo_factor * MGMTp_methylation_status' is key.
# It tells R to include:
#   1. The main effect of Chemo_factor.
#   2. The main effect of MGMTp_methylation_status.
#   3. The interaction term (Chemo_factor:MGMTp_methylation_status).
cox_formula <- as.formula(paste(
  "surv_obj_all ~ Chemo_factor * MGMTp_methylation_status",
  if (length(adj_vars) > 0) paste("+", paste(adj_vars, collapse = " + ")) else ""
))

fit <- tryCatch(coxph(cox_formula, data = df), error = function(e) NULL)

if (!is.null(fit)) {
  # In the summary output, look for the interaction term. Its p-value
  # tells you if the interaction is statistically significant.
  print(summary(fit))

  # --- Create a Forest Plot of the Interaction Model ---
  s <- summary(fit)
  # ... (Code to extract coefficients and build the ggplot forest plot) ...
}

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================
# 1. Look at the two Kaplan-Meier plots generated. Is the separation between
#    "TMZ" and "No TMZ" curves more pronounced in the methylated or unmethylated group?

# 2. In the Cox model summary, find the p-value for the interaction term
#    (e.g., Chemo_factorTMZ:MGMTp_methylation_statusmethylated). Is it < 0.05?

# 3. Hypothesize about another potential interaction. For example, does the
#    effect of Radiotherapy differ by Grade? Modify this script to test that hypothesis.



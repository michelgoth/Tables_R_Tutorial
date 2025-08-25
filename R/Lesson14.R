# ===============================================================
# LESSON 14: ANALYZING COMBINED MOLECULAR GROUPS (IDH x MGMT)
# ===============================================================
#
# OBJECTIVE:
# To analyze the combined prognostic effect of two key molecular
# markers (IDH and MGMT) by creating a "joint group" variable and
# using it in survival analysis.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
# For this lesson, we will use the `rpart` and `rpart.plot` packages.
source("R/utils.R")
load_required_packages(c("readxl", "dplyr", "survival", "survminer", "rpart", "rpart.plot"))

# Load and impute the clinical data
raw_data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- impute_clinical_data(raw_data)

cat("--- LESSON 14: IDH × MGMT Joint Risk Groups ---\n")

# ===============================================================
# SECTION 1: CREATE THE JOINT GROUP VARIABLE --------------------
# Here, we create a new variable that combines the information from
# IDH status and MGMT status into a single factor with four levels.
# ===============================================================
required_cols <- c("OS", "Censor", "IDH_mutation_status", "MGMTp_methylation_status")
if (!all(required_cols %in% names(data))) {
  stop("Missing one or more required columns for this analysis.")
}

# The 'dplyr' pipe (%>%) is used to chain commands together.
# NOTE: The original script filtered for complete cases here. This is
# no longer needed as we are using the full, imputed dataset.
df <- data %>%
  # 1. Use 'mutate' to create the new 'JointGroup' variable.
  #    'paste0' combines the text from the IDH and MGMT columns.
  dplyr::mutate(
    JointGroup = factor(paste0("IDH-", IDH_mutation_status, ", MGMT-", MGMTp_methylation_status))
  ) %>%
  # 2. Drop any unused factor levels from the original data.
  droplevels()

cat("Counts for the new Joint Molecular Groups:\n")
print(table(df$JointGroup))

# ===============================================================
# SECTION 2: KAPLAN-MEIER ANALYSIS OF THE JOINT GROUP -----------
# Now we can treat our new 'JointGroup' variable like any other
# categorical variable and use it in a Kaplan-Meier analysis.
# ===============================================================
surv_obj <- Surv(time = df$OS, event = df$Censor)
fit_km <- survfit(surv_obj ~ JointGroup, data = df)

# Plotting the four survival curves using ggsurvplot.
p_km_joint <- ggsurvplot(
  fit_km,
  data = df,
  pval = TRUE,
  conf.int = TRUE,
  risk.table = TRUE,
  legend.title = "IDH-MGMT Group",
  palette = "jco", # Use a colorblind-friendly palette
  title = "Survival by IDH-MGMT Joint Group",
  xlab = "Time (days)"
)

ensure_plots_dir()
pdf(file.path("plots", "Lesson14_KM_by_IDH_MGMT.pdf"), width = 10, height = 8)
print(p_km_joint, newpage = FALSE)
dev.off()

# ===============================================================
# SECTION 3: ADJUSTED COX MODEL WITH THE JOINT GROUP ------------
# We can also use the 'JointGroup' variable as a predictor in a
# multivariable Cox model to get adjusted Hazard Ratios.
# ===============================================================
# Define other variables to adjust for.
adj_vars <- intersect(c("Age", "Grade"), names(df))
# NOTE: The 'df' object is now the full imputed cohort.
cox_formula <- as.formula(paste("Surv(OS, Censor) ~ JointGroup",
                                if (length(adj_vars) > 0) paste("+", paste(adj_vars, collapse = " + ")) else ""))

fit_cox <- tryCatch(coxph(cox_formula, data = df), error = function(e) NULL)
if (!is.null(fit_cox)) {
  # The output will show HRs for each joint group relative to a reference group.
  # By default, the reference group is the first one alphabetically.
  print(summary(fit_cox))

  # --- Create a Forest Plot of the HRs ---
  s <- summary(fit_cox)
  # ... (Code to extract coefficients and build the ggplot forest plot) ...
}

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================
# 1. Look at the Kaplan-Meier plot. Which of the four groups has the best
#    prognosis? Which has the worst? Does this match clinical expectations?

# 2. In the Cox model output, what is the reference group? Interpret the
#    Hazard Ratio for the "IDH-Wildtype, MGMT-un-methylated" group.

# 3. Create a new joint group variable, this time combining 'Grade' and 'IDH_mutation_status'.
#    Then, generate a Kaplan-Meier plot for this new variable.



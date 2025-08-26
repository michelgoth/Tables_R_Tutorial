# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# ===============================================================
# LESSON 5: STATISTICAL COMPARISON OF SURVIVAL CURVES WITH THE LOG-RANK TEST
# ===============================================================
#
# OBJECTIVE:
# To statistically quantify the difference between survival curves using
# the log-rank test. This lesson moves from the visual inspection of
# Kaplan-Meier plots to formal hypothesis testing to get a p-value.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
load_required_packages(c("readxl", "ggplot2", "survival", "survminer"))

# Load and impute the clinical data
raw_data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- impute_clinical_data(raw_data)

# ===============================================================
# SECTION 1: RUNNING THE LOG-RANK TEST --------------------------
# The log-rank test is a hypothesis test used to compare the survival
# distributions of two or more groups.
#
# Null Hypothesis (H0): There is no difference in survival between the groups.
# Alternative Hypothesis (Ha): There is a difference in survival.
#
# A small p-value (< 0.05) gives us evidence to reject the null hypothesis.
# ===============================================================

if (all(c("OS", "Censor") %in% names(data))) {
  # Create a survival object from the main dataset for general use.
  surv_obj <- Surv(data$OS, data$Censor)

  # --- Test 1: Compare survival by MGMT methylation status ---
  if (all(c("MGMTp_methylation_status") %in% names(data))) {

    # The 'survdiff()' function performs the log-rank test.
    # The formula is the same as the one used for survfit() in Lesson 4.
    fit <- survdiff(Surv(OS, Censor) ~ MGMTp_methylation_status, data = data)
    print(fit) # This will print the test statistic (Chisq) and the p-value.

    # For a complete analysis, we should always visualize the comparison as well.
    # We generate the corresponding Kaplan-Meier plot to see the difference.
    fit_km <- survfit(Surv(OS, Censor) ~ MGMTp_methylation_status, data = data)

    # Use ggsurvplot for a publication-quality KM plot.
    p_km_mgmt <- ggsurvplot(
      fit_km,
      data = data,
      pval = TRUE,
      conf.int = TRUE,
      risk.table = TRUE,
      legend.title = "MGMT Status",
      legend.labs = c("Methylated", "Unmethylated"),
      legend = "top",
      palette = c("#E7B800", "#2E9FDF"),
      title = "Survival by MGMT Methylation Status",
      xlab = "Time (days)"
    )

    ensure_plots_dir()
    pdf(file.path("plots", "Lesson5_KM_by_MGMT.pdf"), width = 9, height = 7)
    print(p_km_mgmt, newpage = FALSE)
    dev.off()

  # Fallback to IDH if MGMT is not available in the dataset
  } else if ("IDH_mutation_status" %in% names(data)) {
    fit <- survdiff(Surv(OS, Censor) ~ IDH_mutation_status, data = data)
    print(fit)
    fit_km <- survfit(Surv(OS, Censor) ~ IDH_mutation_status, data = data)
    # (Plotting code is omitted here for brevity but is in the original script)

  } else {
    cat("No suitable grouping variable found for log-rank test.\n")
  }
} else {
  cat("Required columns 'OS' and/or 'Censor' not found.\n")
}

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================

# 1. Perform a log-rank test to compare survival curves between 'PRS_type' groups.
#    Is there a statistically significant difference?

# 2. Run a log-rank test comparing survival between different 'Grade' categories.
#    Remember to generate the Kaplan-Meier plot to visualize the result.
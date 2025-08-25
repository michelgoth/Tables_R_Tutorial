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
load_required_packages(c("readxl", "ggplot2", "survival"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# Create clean data frames for the survival analysis, removing patients
# with missing data for the key variables.
data_surv <- filter_complete_cases(data, c("OS", "Censor"))
data_surv_mgmt <- filter_complete_cases(data, c("OS", "Censor", "MGMTp_methylation_status"))
data_surv_idh <- filter_complete_cases(data, c("OS", "Censor", "IDH_mutation_status"))

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

if (all(c("OS", "Censor") %in% names(data_surv))) {
  # Create a survival object from the main dataset for general use.
  surv_obj <- Surv(data_surv$OS, data_surv$Censor)

  # --- Test 1: Compare survival by MGMT methylation status ---
  if (all(c("MGMTp_methylation_status") %in% names(data_surv_mgmt))) {

    # The 'survdiff()' function performs the log-rank test.
    # The formula is the same as the one used for survfit() in Lesson 4.
    fit <- survdiff(Surv(OS, Censor) ~ MGMTp_methylation_status, data = data_surv_mgmt)
    print(fit) # This will print the test statistic (Chisq) and the p-value.

    # For a complete analysis, we should always visualize the comparison as well.
    # We generate the corresponding Kaplan-Meier plot to see the difference.
    fit_km <- survfit(Surv(OS, Censor) ~ MGMTp_methylation_status, data = data_surv_mgmt)
    ensure_plots_dir()
    png(file.path("plots", "Lesson5_KM_by_MGMT.png"), width = 1200, height = 900, res = 150)
    plot(fit_km, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
         main = "Survival by MGMT Methylation Status")
    legend("topright", legend = levels(data_surv_mgmt$MGMTp_methylation_status), col = 1:3, lwd = 2)
    dev.off()
    pdf(file.path("plots", "Lesson5_KM_by_MGMT.pdf"), width = 9, height = 7)
    plot(fit_km, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
         main = "Survival by MGMT Methylation Status")
    legend("topright", legend = levels(data_surv_mgmt$MGMTp_methylation_status), col = 1:3, lwd = 2)
    dev.off()

  # Fallback to IDH if MGMT is not available in the dataset
  } else if ("IDH_mutation_status" %in% names(data_surv_idh)) {
    fit <- survdiff(Surv(OS, Censor) ~ IDH_mutation_status, data = data_surv_idh)
    print(fit)
    fit_km <- survfit(Surv(OS, Censor) ~ IDH_mutation_status, data = data_surv_idh)
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
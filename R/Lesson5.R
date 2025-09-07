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
if (all(c("OS", "Censor") %in% names(data))) {
  # Create a survival object from the main dataset for general use.
  surv_obj <- Surv(data$OS, data$Censor)
  
  if (all(c("PRS_type") %in% names(data))) {
    log_PRS <- survdiff(Surv(OS, Censor)~ PRS_type, data = data)
    print(log_PRS)
    
    fit_PRS <- survfit(surv_obj ~ PRS_type, data = data)
    p_km_PRS <- ggsurvplot(
      fit_PRS,
      data = data,
      pval = TRUE,             # Add log-rank p-value
      conf.int = TRUE,         # Add confidence intervals
      risk.table = TRUE, #legend = "top",       # Add at-risk table
      legend.title = "PRS-Type",
      legend.labs = c("Primary", "Recurrent", "Secondary"),
      legend = "top",          # Explicitly set legend position
      palette = c("#00BA38", "#F8766D", "#C8024F"),
      title = "Survival by PRS-Type",
      xlab = "Time (days)"
    )
    print(p_km_PRS$plot)
    
    ensure_plots_dir()
    pdf(file.path("plots", "Lesson5_KM_by_PRS.pdf"), width = 9, height = 7)
    print(p_km_PRS, newpage = FALSE)
    dev.off()
    
  } else {
    cat("No suitable grouping variable found for log-rank test.\n")
  }
} else {
  cat("Required columns 'OS' and/or 'Censor' not found.\n")
}

# 2. Run a log-rank test comparing survival between different 'Grade' categories.
#    Remember to generate the Kaplan-Meier plot to visualize the result.
if (all(c("OS", "Censor") %in% names(data))) {
  # Create a survival object from the main dataset for general use.
  surv_obj <- Surv(data$OS, data$Censor)
  
  if (all(c("Grade") %in% names(data))) {
    log_Grade <- survdiff(Surv(OS, Censor)~ Grade, data = data)
    print(log_Grade)
    
    fit_Grade <- survfit(surv_obj ~ Grade, data = data)
    p_km_Grade <- ggsurvplot(
      fit_Grade,
      data = data,
      pval = TRUE,             # Add log-rank p-value
      conf.int = TRUE,         # Add confidence intervals
      risk.table = TRUE, #legend = "top",       # Add at-risk table
      legend.title = "Grade",
      legend.labs = c("WHO II", "WHO III", "WHO IV"),
      legend = "top",          # Explicitly set legend position
      palette = c("#00BA38", "#F8766D", "#C8024F"),
      title = "Survival by Grade",
      xlab = "Time (days)"
    )
    print(p_km_Grade$plot)
    
    ensure_plots_dir()
    pdf(file.path("plots", "Lesson5_KM_by_PRS.pdf"), width = 9, height = 7)
    print(p_km_PRS, newpage = FALSE)
    dev.off()
    
  } else {
    cat("No suitable grouping variable found for log-rank test.\n")
  }
} else {
  cat("Required columns 'OS' and/or 'Censor' not found.\n")
}
# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

source("R/utils.R")
load_required_packages(c("readxl", "ggplot2", "survival"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# ===============================================================
# LESSON 5: STATISTICAL COMPARISON WITH LOG-RANK TEST
# ===============================================================

# LEARNING OBJECTIVES:
# - Understand the purpose of the log-rank test
# - Compare survival distributions between groups
# - Interpret p-values from survival analysis

# SECTION 1: RUNNING LOG-RANK TEST ----------------------------

if (all(c("OS", "Censor") %in% names(data))) {
  surv_obj <- Surv(data$OS, data$Censor)
  if (all(c("MGMTp_methylation_status") %in% names(data))) {
    fit <- survdiff(surv_obj ~ MGMTp_methylation_status, data = data)
    print(fit)
    # Save KM plot
    fit_km <- survfit(surv_obj ~ MGMTp_methylation_status, data = data)
    ensure_plots_dir()
    png(file.path("plots", "Lesson5_KM_by_MGMT.png"), width = 1200, height = 900, res = 150)
    plot(fit_km, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
         main = "Survival by MGMT Methylation Status")
    legend("topright", legend = levels(data$MGMTp_methylation_status), col = 1:3, lwd = 2)
    dev.off()
    pdf(file.path("plots", "Lesson5_KM_by_MGMT.pdf"), width = 9, height = 7)
    plot(fit_km, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
         main = "Survival by MGMT Methylation Status")
    legend("topright", legend = levels(data$MGMTp_methylation_status), col = 1:3, lwd = 2)
    dev.off()
  } else if ("IDH_mutation_status" %in% names(data)) {
    fit <- survdiff(surv_obj ~ IDH_mutation_status, data = data)
    print(fit)
    fit_km <- survfit(surv_obj ~ IDH_mutation_status, data = data)
    ensure_plots_dir()
    png(file.path("plots", "Lesson5_KM_by_IDH.png"), width = 1200, height = 900, res = 150)
    plot(fit_km, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
         main = "Survival by IDH Mutation Status")
    legend("topright", legend = levels(data$IDH_mutation_status), col = 1:3, lwd = 2)
    dev.off()
    pdf(file.path("plots", "Lesson5_KM_by_IDH.pdf"), width = 9, height = 7)
    plot(fit_km, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
         main = "Survival by IDH Mutation Status")
    legend("topright", legend = levels(data$IDH_mutation_status), col = 1:3, lwd = 2)
    dev.off()
  } else {
    cat("No suitable grouping variable found for log-rank test.\n")
  }
} else {
  cat("Required columns 'OS' and/or 'Censor' not found.\n")
}

# PRACTICE TASKS ----------------------------------------------
# 1. Perform a log-rank test comparing PRS_type
# 2. Try the test on Tumor Grade or Histology
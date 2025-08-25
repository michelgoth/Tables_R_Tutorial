# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

source("R/utils.R")
load_required_packages(c("readxl", "ggplot2", "survival"))

data <- load_clinical_data("Data/ClinicalData.xlsx")
data_surv_idh <- filter_complete_cases(data, c("OS", "Censor", "IDH_mutation_status"))

# ===============================================================
# LESSON 4: SURVIVAL ANALYSIS WITH KAPLAN-MEIER CURVES
# ===============================================================

# LEARNING OBJECTIVES:
# - Understand and construct Kaplan-Meier survival curves
# - Compare survival between patient groups

# SECTION 1: CREATE SURVIVAL OBJECT ----------------------------

if (all(c("OS", "Censor") %in% names(data_surv_idh))) {
  surv_obj <- Surv(time = as.numeric(data_surv_idh$OS), event = data_surv_idh$Censor)
} else {
  stop("ERROR: Required columns 'OS' and/or 'Censor' not found in data.")
}

# SECTION 2: KAPLAN-MEIER FIT ----------------------------------

# Compare survival between IDH mutation statuses
if ("IDH_mutation_status" %in% names(data_surv_idh)) {
  fit_idh <- survfit(surv_obj ~ IDH_mutation_status, data = data_surv_idh)
  
  # Save KM plot using base graphics for portability
  ensure_plots_dir()
  png(file.path("plots", "Lesson4_KM_by_IDH.png"), width = 1200, height = 900, res = 150)
  plot(fit_idh, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
       main = "Survival by IDH Mutation Status")
  legend("topright", legend = levels(data_surv_idh$IDH_mutation_status), col = 1:3, lwd = 2)
  dev.off()
  
  pdf(file.path("plots", "Lesson4_KM_by_IDH.pdf"), width = 9, height = 7)
  plot(fit_idh, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
       main = "Survival by IDH Mutation Status")
  legend("topright", legend = levels(data_surv_idh$IDH_mutation_status), col = 1:3, lwd = 2)
  dev.off()
} else {
  cat("Column 'IDH_mutation_status' not found in data.\n")
}

# PRACTICE TASKS ----------------------------------------------
# 1. Plot a KM curve for MGMTp_methylation_status
# 2. Try grouping by PRS_type or Grade and observe differences.
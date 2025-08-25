# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# ===============================================================
# LESSON 4: INTRODUCTION TO SURVIVAL ANALYSIS WITH KAPLAN-MEIER CURVES
# ===============================================================
#
# OBJECTIVE:
# To introduce the fundamentals of survival analysis by creating and
# interpreting a Kaplan-Meier (KM) survival curve. This is one of the
# most common and important analyses in clinical research, used to
# visualize time-to-event data.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
# We add the 'survival' package, which is the core package for this type of analysis in R.
load_required_packages(c("readxl", "ggplot2", "survival", "survminer"))

# Load and impute the clinical data
raw_data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- impute_clinical_data(raw_data)

# ===============================================================
# SECTION 1: CREATE A SURVIVAL OBJECT ----------------------------
# To perform survival analysis in R, you first need to combine your
# time and event data into a special 'survival object'.
# ===============================================================

if (all(c("OS", "Censor") %in% names(data))) {
  # The Surv() function from the 'survival' package does this for us.
  # 'time' is the follow-up time (Overall Survival in days).
  # 'event' is the status at the end of follow-up. In our data:
  #   - 1 = Deceased (the "event" happened)
  #   - 0 = Alive (the patient was "censored")
  surv_obj <- Surv(time = as.numeric(data$OS), event = data$Censor)
} else {
  stop("ERROR: Required columns 'OS' and/or 'Censor' not found in data.")
}

# ===============================================================
# SECTION 2: FIT AND PLOT THE KAPLAN-MEIER CURVE -----------------
# The Kaplan-Meier curve is a graph that shows the probability of
# survival over time.
# ===============================================================

# We will compare survival between different IDH mutation statuses.
if ("IDH_mutation_status" %in% names(data)) {

  # The 'survfit()' function calculates the Kaplan-Meier survival curve.
  # The formula 'surv_obj ~ IDH_mutation_status' tells the function to create
  # separate survival curves for each category within the 'IDH_mutation_status' variable.
  fit_idh <- survfit(surv_obj ~ IDH_mutation_status, data = data)

  # --- Plotting the KM Curve ---
  # We will now use the ggsurvplot function from the 'survminer' package
  # to create a publication-quality plot.
  p_km_idh <- ggsurvplot(
    fit_idh,
    data = data,
    pval = TRUE,             # Add log-rank p-value
    conf.int = TRUE,         # Add confidence intervals
    risk.table = TRUE,       # Add at-risk table
    legend.title = "IDH Status",
    legend.labs = c("Mutant", "Wildtype"),
    palette = c("#00BA38", "#F8766D"),
    title = "Survival by IDH Mutation Status",
    xlab = "Time (days)"
  )

  # ggsurvplot returns a complex object; we print the plot component.
  print(p_km_idh$plot)

  # To save a ggsurvplot, we need a different approach as it is a grid of plots.
  # We will save to PDF which handles this object well.
  ensure_plots_dir()
  pdf(file.path("plots", "Lesson4_KM_by_IDH.pdf"), width = 9, height = 7)
  print(p_km_idh, newpage = FALSE)
  dev.off()

} else {
  cat("Column 'IDH_mutation_status' not found in data.\n")
}

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================

# 1. Create a Kaplan-Meier plot comparing survival between patients with
#    different 'MGMTp_methylation_status'.

# 2. Try creating another KM plot, this time grouping by 'PRS_type' or 'Grade'.
#    Do you see a clear separation between the survival curves?
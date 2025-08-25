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
load_required_packages(c("readxl", "ggplot2", "survival"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# For survival analysis, we need the time variable ('OS'), the event variable
# ('Censor'), and the grouping variable ('IDH_mutation_status'). We remove
# any patients missing any of these essential data points.
data_surv_idh <- filter_complete_cases(data, c("OS", "Censor", "IDH_mutation_status"))

# ===============================================================
# SECTION 1: CREATE A SURVIVAL OBJECT ----------------------------
# To perform survival analysis in R, you first need to combine your
# time and event data into a special 'survival object'.
# ===============================================================

if (all(c("OS", "Censor") %in% names(data_surv_idh))) {
  # The Surv() function from the 'survival' package does this for us.
  # 'time' is the follow-up time (Overall Survival in days).
  # 'event' is the status at the end of follow-up. In our data:
  #   - 1 = Deceased (the "event" happened)
  #   - 0 = Alive (the patient was "censored")
  surv_obj <- Surv(time = as.numeric(data_surv_idh$OS), event = data_surv_idh$Censor)
} else {
  stop("ERROR: Required columns 'OS' and/or 'Censor' not found in data.")
}

# ===============================================================
# SECTION 2: FIT AND PLOT THE KAPLAN-MEIER CURVE -----------------
# The Kaplan-Meier curve is a graph that shows the probability of
# survival over time.
# ===============================================================

# We will compare survival between different IDH mutation statuses.
if ("IDH_mutation_status" %in% names(data_surv_idh)) {

  # The 'survfit()' function calculates the Kaplan-Meier survival curve.
  # The formula 'surv_obj ~ IDH_mutation_status' tells the function to create
  # separate survival curves for each category within the 'IDH_mutation_status' variable.
  fit_idh <- survfit(surv_obj ~ IDH_mutation_status, data = data_surv_idh)

  # --- Plotting the KM Curve ---
  # This lesson uses R's base graphics for plotting, which is simple and effective.
  # The 'plot()' function, when used on a 'survfit' object, automatically
  # creates a Kaplan-Meier plot.
  # The dev.off() commands close the file-saving device.
  
  # Save the plot as a PNG file
  ensure_plots_dir()
  png(file.path("plots", "Lesson4_KM_by_IDH.png"), width = 1200, height = 900, res = 150)
  plot(fit_idh, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
       main = "Survival by IDH Mutation Status")
  legend("topright", legend = levels(data_surv_idh$IDH_mutation_status), col = 1:3, lwd = 2)
  dev.off()

  # Save the same plot as a high-quality PDF file
  pdf(file.path("plots", "Lesson4_KM_by_IDH.pdf"), width = 9, height = 7)
  plot(fit_idh, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
       main = "Survival by IDH Mutation Status")
  legend("topright", legend = levels(data_surv_idh$IDH_mutation_status), col = 1:3, lwd = 2)
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
# ===============================================================
# LESSON 4: SURVIVAL ANALYSIS WITH KAPLAN-MEIER CURVES
# ===============================================================

# LEARNING OBJECTIVES:
# - Understand and construct Kaplan-Meier survival curves
# - Compare survival between patient groups
# - Use ggsurvplot for clean visualization

#  WHAT YOU'LL LEARN:
# The Kaplan-Meier estimator helps visualize how survival probability 
# changes over time. You'll learn how to compare survival based on key 
# features like IDH mutation or treatment status.

# REQUIREMENTS:
# Make sure the `survival` and `survminer` packages are loaded.

# SECTION 1: CREATE SURVIVAL OBJECT ----------------------------

# The Surv() function creates a survival object using OS and Censoring
# OS = Overall Survival Time
# Censor = 0 for alive, 1 for dead
library(survival)
library(survminer)
surv_obj <- Surv(time = as.numeric(data$OS), event = data$`Censor (alive=0; dead=1)`)

# SECTION 2: KAPLAN-MEIER FIT ----------------------------------

# Compare survival between IDH mutation statuses
fit_idh <- survfit(surv_obj ~ IDH_mutation_status, data = data)

# Plot Kaplan-Meier curve
ggsurvplot(
  fit_idh,
  data = data,
  pval = TRUE,             # Show p-value from log-rank test
  risk.table = TRUE,       # Show number at risk below the plot
  title = "Survival by IDH Mutation Status",
  xlab = "Time (days)",
  ylab = "Survival Probability"
)

# PRACTICE TASKS ----------------------------------------------

# 1. Plot a KM curve for MGMTp_methylation_status
#    Hint: change the variable in the formula: survfit(surv_obj ~ ...)

# 2. Interpret the plot:
#    - Which group survives longer on average?
#    - What does the p-value tell you?

# 3. Try grouping by PRS_type or Grade and observe differences.

# 4. Optional: Try setting `conf.int = TRUE` in ggsurvplot()
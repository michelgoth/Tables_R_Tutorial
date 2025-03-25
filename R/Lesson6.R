# ===============================================================
# LESSON 6: MULTIVARIABLE SURVIVAL ANALYSIS WITH COX MODEL
# ===============================================================

# LEARNING OBJECTIVES:
# - Understand how to use the Cox proportional hazards model
# - Model survival using multiple covariates
# - Interpret hazard ratios (HR) and statistical significance

# WHAT YOU'LL LEARN:
# The Cox model allows us to estimate how several clinical variables
# jointly affect the hazard (risk) of an event (e.g., death).
# It provides hazard ratios, which reflect how much a variable increases or decreases risk.

# SECTION 1: BUILD COX MODEL ----------------------------------

# Fit a multivariate Cox model using clinical predictors
cox_model <- coxph(Surv(OS, Censor) ~ Age + Gender + Grade + 
                     IDH_mutation_status + MGMTp_methylation_status +
                     PRS_type + Chemo_status + Radio_status, 
                   data = data)

# View model summary
summary(cox_model)

# Key Output Components:
# - coef: log hazard ratios
# - exp(coef): hazard ratio (HR)
# - p-value: significance of predictor
# - Concordance: model predictive ability

# TIP:
# HR > 1 → Higher risk; HR < 1 → Lower risk

# PRACTICE TASKS ----------------------------------------------

# 1. Which variables are statistically significant? (p < 0.05)

# 2. Interpret the hazard ratio for Age:
#    - Is older age associated with increased or decreased hazard?

# 3. Interpret the hazard ratio for IDH mutation:
#    - Does having a mutation reduce the risk of death?

# 4. Remove a variable (e.g., PRS_type) and re-run the model:
#    - How do other coefficients change?

# 5. OPTIONAL: Use `ggforest(cox_model, data = data)` from survminer
#    to visualize the hazard ratios as a forest plot.
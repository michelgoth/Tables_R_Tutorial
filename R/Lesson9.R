# ===============================================================
# LESSON 9: LOGISTIC REGRESSION FOR BINARY OUTCOMES
# ===============================================================

# LEARNING OBJECTIVES:
# - Build a logistic regression model
# - Interpret coefficients and p-values
# - Predict binary outcomes like mutation or treatment status

# WHAT YOU'LL LEARN:
# Logistic regression is used when your outcome variable is binary (e.g., Mutant vs Wildtype).
# This lesson teaches you how to model outcomes using clinical predictors.

# SECTION 1: FIT A LOGISTIC MODEL -----------------------------

# Model the probability of having an IDH mutation
logit_model <- glm(IDH_mutation_status ~ Age + Gender + Grade + MGMTp_methylation_status,
                   data = data, family = "binomial")

# View the model summary
summary(logit_model)

# Interpreting Output:
# - Coefficients: log odds (use exp() to interpret as odds ratios)
# - p-values: indicate significance of each predictor

# Example:
# exp(coef(logit_model))       # Converts log-odds to odds ratios

# PRACTICE TASKS ----------------------------------------------

# 1. Which predictors are statistically significant (p < 0.05)?

# 2. Interpret the sign of each coefficient:
#    - Does higher age increase or decrease odds of IDH mutation?

# 3. Try building a new logistic model to predict MGMTp_methylation_status

# 4. Optional: Use `predict()` with `type = "response"` to get probabilities
#    Example: predict(logit_model, type = "response")
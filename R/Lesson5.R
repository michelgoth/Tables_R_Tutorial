# ===============================================================
# LESSON 5: STATISTICAL COMPARISON WITH LOG-RANK TEST
# ===============================================================

# LEARNING OBJECTIVES:
# - Understand the purpose of the log-rank test
# - Compare survival distributions between groups
# - Interpret p-values from survival analysis

# WHAT YOU'LL LEARN:
# Kaplan-Meier plots visualize survival, but are the differences significant?
# The log-rank test statistically compares survival curves between two or more groups.

# SECTION 1: RUNNING LOG-RANK TEST ----------------------------

# Compare survival between IDH mutation groups
logrank_idh <- survdiff(Surv(OS, Censor) ~ IDH_mutation_status, data = data)
print(logrank_idh)

# Compare survival between MGMT methylation groups
logrank_mgmt <- survdiff(Surv(OS, Censor) ~ MGMTp_methylation_status, data = data)
print(logrank_mgmt)

# Interpretation:
# - A large test statistic with a small p-value suggests a significant difference in survival
# - This test assumes proportional hazards

# PRACTICE TASKS ----------------------------------------------

# 1. Perform a log-rank test comparing PRS_type
#    survdiff(Surv(OS, Censor) ~ PRS_type, data = data)

# 2. Try the test on Tumor Grade or Histology

# 3. For each test, interpret:
#    - What does the p-value suggest?
#    - Which group appears to have better survival?

# 4. BONUS: Plot KM curves side-by-side with log-rank results for context
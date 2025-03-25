# ===============================================================
# LESSON 7: ASSOCIATION TESTS (CHI-SQUARE & FISHER'S EXACT)
# ===============================================================

# LEARNING OBJECTIVES:
# - Test relationships between two categorical variables
# - Use Chi-square or Fisher's exact test appropriately
# - Interpret test results in a clinical context

# WHAT YOU'LL LEARN:
# Association tests help us evaluate whether two categorical features
# are statistically related — for example, does IDH mutation status
# vary significantly with Tumor Grade?

# SECTION 1: CHI-SQUARE TEST ----------------------------------

# Compare IDH mutation status across Tumor Grade
table_idh_grade <- table(data$IDH_mutation_status, data$Grade)
chisq.test(table_idh_grade)

# Interpretation:
# - A small p-value (e.g., < 0.05) suggests the variables are associated
# - Check expected counts in the output to ensure test validity

# SECTION 2: FISHER'S EXACT TEST ------------------------------

# Use Fisher’s Exact Test when sample sizes are small or expected frequencies < 5
fisher.test(table(data$Gender, data$MGMTp_methylation_status))

# TIP:
# - Chi-Square works well with large datasets
# - Fisher's is more accurate with small sample sizes or sparse data

# PRACTICE TASKS ----------------------------------------------

# 1. Test association between PRS_type and Chemo_status
#    Hint: Use table() and apply chisq.test()

# 2. When should you use Fisher's test instead of Chi-square?

# 3. Try an association test between Radio_status and Grade

# 4. OPTIONAL: Use ggbarplot (from ggpubr) to visualize proportions
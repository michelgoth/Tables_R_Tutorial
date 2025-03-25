# ===============================================================
# LESSON 8: COMPARING NUMERIC VARIABLES ACROSS GROUPS
# ===============================================================

# LEARNING OBJECTIVES:
# - Compare continuous variables across categories
# - Use the Wilcoxon test or t-test appropriately
# - Interpret p-values in clinical context

# WHAT YOU'LL LEARN:
# Do patients with different mutation statuses or treatment groups have
# different survival times or ages? In this lesson, you'll compare numeric
# outcomes (like Age or OS) across groups using statistical tests.

# SECTION 1: WILCOXON RANK-SUM TEST ---------------------------

# Compare Age between IDH mutation statuses (non-parametric test)
wilcox.test(Age ~ IDH_mutation_status, data = data)

# Compare OS between MGMT methylation groups
wilcox.test(OS ~ MGMTp_methylation_status, data = data)

# 💡 TIP:
# Use Wilcoxon when your data is not normally distributed

# SECTION 2: T-TEST (OPTIONAL) --------------------------------

# Compare OS using a parametric test (assumes normality)
t.test(OS ~ MGMTp_methylation_status, data = data)

# PRACTICE TASKS ----------------------------------------------

# 1. Compare OS across PRS_type using:
#    - Wilcoxon test
#    - t-test
#
# 2. Compare Age between Grade III and Grade IV tumors (if applicable)

# 3. Try plotting boxplots for the comparisons you made above:
#    Hint: use ggplot + geom_boxplot()

# 4. When would you prefer a t-test over a Wilcoxon test?
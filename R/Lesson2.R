# ===============================================================
# LESSON 2: DESCRIPTIVE STATISTICS & DISTRIBUTIONS
# ===============================================================

# LEARNING OBJECTIVES:
# - Summarize clinical data using descriptive statistics
# - Explore variable distributions
# - Use visualizations to describe patterns

# WHAT YOU'LL LEARN:
# In this version of Lesson 2, we’ll focus on describing the data.
# You’ll learn how to explore distributions and counts using both
# summary statistics and visualizations.

# SECTION 1: DESCRIPTIVE STATISTICS ---------------------------

# Summary statistics for continuous variables
summary(data$Age)

# Frequency tables for categorical variables
table(data$Gender)
table(data$Grade)
table(data$IDH_mutation_status)

# SECTION 2: VISUALIZE DISTRIBUTIONS ---------------------------

# Age distribution by Gender
ggplot(data, aes(x = Age, fill = Gender)) +
  geom_histogram(binwidth = 5, alpha = 0.6, position = "identity") +
  theme_minimal() +
  labs(title = "Age Distribution by Gender", x = "Age", y = "Count")

# PRACTICE TASKS ----------------------------------------------

# 1. Create a histogram for OS (Overall Survival)
#    Hint: aes(x = OS), use similar code to Age histogram

# 2. Which Tumor Grade is most common? Use table() or bar plot.

# 3. Compare Age distributions between PRS_type groups
#    Hint: Try using `facet_wrap(~ PRS_type)` or use `fill = PRS_type`

# 4. BONUS: Try summarizing Age by Grade using group_by() + summarise()
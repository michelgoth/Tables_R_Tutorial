# ===============================================================
# LESSON 3: CLINICAL FEATURE VISUALIZATION
# ===============================================================

# LEARNING OBJECTIVES:
# - Visualize relationships between categorical clinical variables
# - Customize plots using ggplot2
# - Interpret bar charts for group comparisons

# WHAT YOU'LL LEARN:
# Bar plots are excellent for showing counts and proportions of categorical features.
# In this lesson, you’ll learn how to visualize the distribution of features like
# Tumor Grade, PRS Type, and molecular markers (e.g., IDH status).

# SECTION 1: BAR PLOTS FOR CATEGORICAL COMPARISONS -----------

# Tumor Grade across PRS Type
ggplot(data, aes(x = Grade, fill = PRS_type)) +
  geom_bar(position = "dodge") +
  labs(title = "Tumor Grade by PRS Type",
       x = "Tumor Grade", y = "Count") +
  theme_minimal()

# IDH Mutation Status across Gender
ggplot(data, aes(x = IDH_mutation_status, fill = Gender)) +
  geom_bar(position = "dodge") +
  labs(title = "IDH Status by Gender",
       x = "IDH Mutation Status", y = "Count") +
  theme_minimal()

# PRACTICE TASKS ----------------------------------------------

# 1. Visualize Histology by PRS_type
#    Hint: Use aes(x = Histology, fill = PRS_type)

# 2. Create a bar chart of MGMT methylation status by Grade
#    Hint: Try fill = MGMTp_methylation_status and position = "dodge"

# 3. Try position = "fill" to show proportions instead of counts

# 4. Add themes, labels, and color palettes to make your plots presentation-ready
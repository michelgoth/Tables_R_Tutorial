# ===============================================================
# LESSON 1: SETUP, DATA IMPORT & BASIC VISUALIZATION
# ===============================================================

# LEARNING OBJECTIVES:
# - Set up your R environment
# - Load a clinical dataset
# - Explore the data structure
# - Create basic plots using ggplot2
# - Practice reading and interpreting outputs

# WHAT YOU'LL LEARN:
# This lesson introduces you to data import and visualization.
# You'll install essential packages, load your dataset, and 
# create your first clinical plots using R.

# SECTION 1: LOAD PACKAGES & DATA -----------------------------

# Assumes you have run: source('R/setup.R')
source("R/utils.R")
load_required_packages(c("ggplot2", "dplyr", "tidyr", "ggpubr", "rstatix", "readxl"))

# Load the standardized dataset
data <- load_clinical_data("Data/ClinicalData.xlsx")

# Drop NA rows per-plot to keep visuals clean
data_age <- filter_complete_cases(data, c("Age"))
data_grade_gender <- filter_complete_cases(data, c("Grade", "Gender"))
data_prs_grade <- filter_complete_cases(data, c("PRS_type", "Grade"))

# SECTION 2: DATA STRUCTURE CHECK -----------------------------

# View structure and summary of the dataset
str(data)
summary(data)
head(data)

# SECTION 4: BASIC VISUALIZATION ------------------------------

# Histogram of Age
p1 <- ggplot(data_age, aes(x = Age)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "white") +
  labs(title = "Age Distribution", x = "Age", y = "Count") +
  theme_minimal()
print(p1)
save_plot_both(p1, base_filename = "Lesson1_Age_Distribution")

# Bar plot of Tumor Grade by Gender
p2 <- ggplot(data_grade_gender, aes(x = Grade, fill = Gender)) +
  geom_bar(position = "dodge") +
  labs(title = "Tumor Grade by Gender", x = "Grade", y = "Count") +
  theme_minimal()
print(p2)
save_plot_both(p2, base_filename = "Lesson1_Grade_by_Gender")

# SECTION 5: CUSTOMIZING PLOTS --------------------------------

# Customize with color, labels, and themes
p3 <- ggplot(data_prs_grade, aes(x = PRS_type, fill = Grade)) +
  geom_bar(position = "fill") +
  labs(title = "Proportion of Grades within PRS Types", 
       y = "Proportion", x = "PRS Type") +
  scale_fill_brewer(palette = "Set2") +
  theme_minimal()
print(p3)
save_plot_both(p3, base_filename = "Lesson1_Grades_within_PRS")

# PRACTICE TASKS ----------------------------------------------

# 1. Create a histogram of OS (overall survival)
# 2. Create a bar plot of MGMT methylation status by Gender
# 3. Customize a plot using your own colors and labels
# 4. Use str() and summary() to check variables you're unfamiliar with
# 5. Try converting another column (e.g., Histology) into a factor
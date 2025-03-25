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

# SECTION 1: INSTALL & LOAD PACKAGES --------------------------

# List of packages needed
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", 
                       "corrplot", "car", "psych", "ggpubr", "rstatix")

# Install missing packages
installed <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!(pkg %in% installed)) install.packages(pkg, dependencies = TRUE)
}

# Load libraries
lapply(required_packages, library, character.only = TRUE)

# SECTION 2: IMPORT DATA --------------------------------------

# Set your working directory or provide full path
# Make sure Data_Table.xlsx is saved in this directory
# setwd("path_to_your_directory")

# Load the data
data <- read_excel("Data_Table.xlsx")

# SECTION 3: DATA STRUCTURE CHECK -----------------------------

# View structure and summary of the dataset
str(data)
summary(data)
head(data)

# Convert key categorical variables
data$Grade <- factor(data$Grade)
data$Gender <- factor(data$Gender)
data$PRS_type <- factor(data$PRS_type)

# SECTION 4: BASIC VISUALIZATION ------------------------------

# Histogram of Age
ggplot(data, aes(x = Age)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "white") +
  labs(title = "Age Distribution", x = "Age", y = "Count") +
  theme_minimal()

# Bar plot of Tumor Grade by Gender
ggplot(data, aes(x = Grade, fill = Gender)) +
  geom_bar(position = "dodge") +
  labs(title = "Tumor Grade by Gender", x = "Grade", y = "Count") +
  theme_minimal()

# SECTION 5: CUSTOMIZING PLOTS --------------------------------

# Customize with color, labels, and themes
ggplot(data, aes(x = PRS_type, fill = Grade)) +
  geom_bar(position = "fill") +
  labs(title = "Proportion of Grades within PRS Types", 
       y = "Proportion", x = "PRS Type") +
  scale_fill_brewer(palette = "Set2") +
  theme_minimal()

# PRACTICE TASKS ----------------------------------------------

# 1. Create a histogram of OS (overall survival)
# 2. Create a bar plot of MGMT methylation status by Gender
# 3. Customize a plot using your own colors and labels
# 4. Use str() and summary() to check variables you're unfamiliar with
# 5. Try converting another column (e.g., Histology) into a factor
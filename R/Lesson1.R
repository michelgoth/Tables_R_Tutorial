# ===============================================================
# LESSON 1: SETUP, DATA IMPORT & BASIC VISUALIZATION
# ===============================================================
#
# OBJECTIVE:
# This first lesson will guide you through loading the clinical dataset
# and creating three fundamental plots to get a "first look" at the
# patient cohort. This process is a key part of Exploratory Data Analysis (EDA).
#
# To run this script:
# 1. Open R or RStudio
# 2. Make sure your working directory is the root of this project
# 3. Run the command: source("R/Lesson1.R")
# ===============================================================

# SECTION 1: LOAD PACKAGES & DATA -----------------------------

# It's good practice to run the setup script first to ensure all
# packages are installed. This only needs to be done once.
# source('R/setup.R')

# The 'source()' command runs another R script. Here, we're loading
# our custom helper functions from 'utils.R'.
source("R/utils.R")

# Now, we load the specific packages needed for this lesson.
# 'ggplot2' is for plotting, and 'dplyr' is for data manipulation.
load_required_packages(c("ggplot2", "dplyr", "tidyr", "ggpubr", "rstatix", "readxl"))

# Load and preprocess the clinical data using our helper function
raw_data <- load_clinical_data("Data/ClinicalData.xlsx")

# Use the new imputation function to handle missing data
data <- impute_clinical_data(raw_data)

# SECTION 2: DATA STRUCTURE CHECK -----------------------------

# Before analyzing, it's crucial to inspect your data.
# 'str()' shows the structure (e.g., column names, data types like number/text).
# 'summary()' gives descriptive statistics for each column (e.g., mean, median, counts).
# 'head()' displays the first 6 rows of the data frame.
str(data)
summary(data)
head(data)

# SECTION 3: BASIC VISUALIZATION WITH ggplot2 -----------------
# ggplot2 is a powerful library for creating plots in layers.

# --- Plot 1: Histogram of Age ---
# A histogram is used to visualize the distribution of a single continuous variable.
p1 <- ggplot(data, aes(x = Age)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "white") +
  labs(title = "Age Distribution", x = "Age", y = "Count") +
  theme_minimal()

# 'print()' displays the plot in your R session.
print(p1)

# This custom function saves the plot as both a PDF and a PNG in the 'plots/' folder.
save_plot_both(p1, base_filename = "Lesson1_Age_Distribution")

# --- Plot 2: Bar plot of Tumor Grade by Gender ---
# A bar plot is used to show the relationship between two categorical variables.
p2 <- ggplot(data, aes(x = Grade, fill = Gender)) +
  # 'geom_bar()' creates the bars. 'position = "dodge"' places the bars for
  # different genders next to each other, rather than stacked.
  geom_bar(position = "dodge") +
  labs(title = "Tumor Grade by Gender", x = "Grade", y = "Count") +
  theme_minimal()

print(p2)
save_plot_both(p2, base_filename = "Lesson1_Grade_by_Gender")

# --- Plot 3: Proportional Bar Plot ---
# We can also customize plots to show proportions instead of counts.
p3 <- ggplot(data, aes(x = PRS_type, fill = Grade)) +
  # 'position = "fill"' makes each bar go up to 100% and shows the
  # proportion of each 'Grade' within each 'PRS_type'.
  geom_bar(position = "fill") +
  labs(title = "Proportion of Grades within PRS Types",
       y = "Proportion", x = "PRS Type") +
  # 'scale_fill_brewer' applies a pre-defined color palette to the plot.
  scale_fill_brewer(palette = "Set2") +
  theme_minimal()

print(p3)
save_plot_both(p3, base_filename = "Lesson1_Grades_within_PRS")


# PRACTICE TASKS ----------------------------------------------
# Now, try to create some plots on your own!

# 1. Create a histogram of OS (overall survival in days).
#    Hint: Use the code for the Age histogram as a template. You'll need a
#    'data_os' data frame first.

# 2. Create a bar plot of MGMT methylation status by Gender.

# 3. Customize one of your plots using different colors and labels.
#    Search online for "ggplot colors" or "ggplot themes" for ideas.

# 4. Use str() and summary() to inspect columns you're unfamiliar with.

# 5. The 'Histology' column is currently text. Can you create a bar plot
#    showing the count of each Histology type?
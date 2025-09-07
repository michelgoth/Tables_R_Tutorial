# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# ===============================================================
# LESSON 2: DESCRIPTIVE STATISTICS & DISTRIBUTIONS
# ===============================================================
#
# OBJECTIVE:
# To move from the initial plots in Lesson 1 to quantitative summaries
# of the data. This lesson covers how to calculate and interpret the
# descriptive statistics that form the basis of a "Table 1" in any
# clinical research paper.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
# As before, we load our helper functions and the packages needed for this lesson.
source("R/utils.R")
load_required_packages(c("readxl", "ggplot2", "dplyr", "rstatix"))

# Load and impute the clinical data
raw_data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- impute_clinical_data(raw_data)

# ===============================================================
# SECTION 1: DESCRIPTIVE STATISTICS ---------------------------
# "Descriptive statistics" are numbers that summarize the main
# features of a dataset.
# ===============================================================

# --- For Continuous Variables (like Age) ---
# The 'summary()' function provides a five-number summary: Min, 1st Quartile,
# Median, 3rd Quartile, and Max, along with the Mean.
# The '$' operator is used to select a specific column from a data frame.
if ("Age" %in% names(data)) {
  print(summary(data$Age))
} else {
  cat("Column 'Age' not found in data.\n")
}

# --- For Categorical Variables (like Gender or Grade) ---
# The 'table()' function creates a frequency table, showing the
# count of patients in each category.
if ("Gender" %in% names(data)) print(table(data$Gender))
if ("Grade" %in% names(data)) print(table(data$Grade))
if ("IDH_mutation_status" %in% names(data)) print(table(data$IDH_mutation_status))

# ===============================================================
# SECTION 2: VISUALIZE DISTRIBUTIONS ---------------------------
# An overlapping histogram is a great way to visually compare the
# distribution of a continuous variable between two or more groups.
# ===============================================================

if (all(c("Age", "Gender") %in% names(data))) {
  p <- ggplot(data, aes(x = Age, fill = Gender)) +
    # 'geom_histogram' creates the histogram.
    # 'alpha = 0.6' makes the bars semi-transparent so you can see both distributions.
    # 'position = "identity"' tells ggplot to overlay the histograms directly,
    # rather than stacking or dodging them.
    geom_histogram(binwidth = 5, alpha = 0.6, position = "identity") +
    theme_minimal() +
    labs(title = "Age Distribution by Gender", x = "Age", y = "Count")

  print(p)
  save_plot_both(p, base_filename = "Lesson2_Age_by_Gender")
}

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================

# 1. Create a histogram for OS (Overall Survival in days).
#    Hint: aes(x = OS). Don't forget to create a clean data frame first
#    that handles missing values for OS.

any(is.na(data))
#if yes: df_os <- data %>% 
#filter(!is.na(OS))
if (all(c("OS", "Gender") %in% names(data))) {
  data$OS <- as.numeric(data$OS)
  p_os <- ggplot(data, aes(x = OS, fill = Gender)) +
    geom_histogram(binwidth = 50, alpha = 0.6, position = "identity") +
    theme_minimal() +
    labs(title = "OS Distribution by Gender", x = "Overall Survival", y = "Count")
  
  print(p_os)
  save_plot_both(p_os, "Lesson2_OS_Distribution")
}

# 2. Which Tumor Grade is most common in this dataset?
#    Use the 'table()' function or create a 'geom_bar()' plot.
if ("Grade" %in% names(data)) print(table(data$Grade))

if ("Grade" %in% names(data)){
  p_bg <- ggplot(data, aes(x=Grade))+
    geom_bar()+
    labs(title ="Grade Count", x="Grade", y="Count")+
      theme_minimal()
    
    print(p_bg)
    save_plot_both(p_bg, "Lesson2_Grade_Count")
}
# 3. Compare the distribution of 'Age' among the different 'PRS_type' groups.
#    Hint: In your ggplot code, you can use 'fill = PRS_type' to create an
#    overlapping histogram, or add 'facet_wrap(~ PRS_type)' to create
#    separate plots for each presentation type.
if (all(c("Age", "PRS_type") %in% names(data))) {
  p_ap <- ggplot(data, aes(x = Age, fill = PRS_type)) +
    geom_bar(position = "dodge") +
    theme_minimal() +
    labs(title = "Age Distribution by PRS-Type", x = "Age", y = "Count")
  
  print(p_ap)
  save_plot_both(p_ap, "Lesson2_Age_by_PRSType")
}
#or
if (all(c("Age", "PRS_type") %in% names(data))) {
  p_ap_fw <- ggplot(data, aes(x = Age)) +
    geom_bar()+
    facet_wrap(~PRS_type)+
    labs(title="Age by PRS-Type", x="Age")+
    theme_minimal()
  
  print(p_ap_fw)
  save_plot_both(p_ap_fw, "Lesson2_Age_by_PRSType_fw")
}

# 4. BONUS: Use the 'group_by()' and 'summarise()' functions from the 'dplyr'
#    package to calculate the median age for each Tumor Grade.
#    Example: data %>% group_by(Grade) %>% summarise(median_age = median(Age, na.rm=TRUE))
data %>% 
  group_by(Grade) %>% 
  summarise(median_age = median(Age, na.rm=TRUE))

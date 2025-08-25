### Lesson 1: Setup, Data Import, and First Clinical Plots

**Objective:** To introduce the R environment and perform a basic but essential first look at a clinical dataset. This lesson transforms a raw data table into three fundamental plots that characterize the patient cohort.

---

#### **Why This Matters**

Before any complex statistical modeling, the first step in any clinical research project is to understand your cohort. This process, often called **Exploratory Data Analysis (EDA)**, helps you:

*   **Generate "Table 1":** The descriptive statistics from this initial analysis form the basis of the first table in most clinical research papers, describing the patient population.
*   **Identify Data Quality Issues:** EDA can immediately flag potential problems like outliers (e.g., a patient age of 150), incorrect data entry, or systematic missingness that need to be addressed.
*   **Formulate Hypotheses:** Visualizing the data can reveal patterns that suggest relationships between variables, guiding your research questions. For example, is a particular tumor grade more common in one gender?

---

#### **What the R Script Does**

The `R/Lesson1.R` script automates the following:

*   **Loads the Dataset:** It uses a helper function `load_clinical_data()` to import `ClinicalData.xlsx`, which also standardizes column names and correctly interprets "NA" or "Unknown" as missing data.
*   **Handles Missing Data (for plotting):** For each plot, it temporarily removes patients with missing values *for the variables being plotted*. This keeps the visualizations clean.
*   **Generates and Saves Plots:** It creates three plots and saves them as both PDF and PNG files in the `plots/` directory.

---

#### **Step-by-Step Analysis in `R/Lesson1.R`**

The R script walks through these analytical steps. Here, we frame each step with the clinical question it answers.

**1. Loading and Inspecting the Data**
*Clinical Question:* What variables are in our dataset and what do they look like?
```r
# Load helper functions and required packages
source("R/utils.R")
load_required_packages(c("ggplot2","dplyr","tidyr","ggpubr","rstatix","readxl"))

# Load data and inspect its structure
data <- load_clinical_data("Data/ClinicalData.xlsx")
str(data)
summary(data)
```

**2. Age Distribution**
*Clinical Question:* What is the age profile of our glioma cohort?
```r
p1 <- ggplot(data[!is.na(data$Age),], aes(x = Age)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "white") +
  labs(title = "Age Distribution in Glioma Cohort", x = "Age (years)", y = "Number of Patients") +
  theme_minimal()
save_plot_both(p1, "Lesson1_Age_Distribution")
```

**3. Tumor Grade by Gender**
*Clinical Question:* Is there an apparent difference in tumor grade distribution between male and female patients?
```r
df <- subset(data, !is.na(Grade) & !is.na(Gender))
p2 <- ggplot(df, aes(x = Grade, fill = Gender)) +
  geom_bar(position = "dodge") +
  labs(title = "Tumor Grade by Gender", x = "WHO Tumor Grade", y = "Number of Patients") +
  theme_minimal()
save_plot_both(p2, "Lesson1_Grade_by_Gender")
```

**4. Grade Composition by Presentation Type**
*Clinical Question:* How does the distribution of tumor grades differ based on whether the presentation is primary, recurrent, or secondary?
```r
df <- subset(data, !is.na(PRS_type) & !is.na(Grade))
p3 <- ggplot(df, aes(x = PRS_type, fill = Grade)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Proportion of Tumor Grades by Presentation Type", x = "Presentation Type", y = "Proportion of Patients") +
  theme_minimal()
save_plot_both(p3, "Lesson1_Grades_within_PRS")
```

---

#### **Key Clinical Insights & Interpretation**

When you run the script, you should see:

*   **Age Profile:** The age distribution is right-skewed, with a peak around middle age. This is a known epidemiological feature of adult glioma cohorts.
*   **Grade and Gender:** A quick look at the counts of different tumor grades, separated by gender. This allows for a visual check for any large, unexpected disparities.
*   **Presentation Context:** The plot of grade composition reveals how tumor grades are distributed among primary, recurrent, and secondary gliomas. For instance, you might observe a higher proportion of high-grade gliomas in recurrent cases.

---

#### **How to Run the Script**

To generate the plots yourself, run the following command from your terminal in the project's root directory:

```bash
Rscript R/Lesson1.R
```
Or run the code interactively in RStudio.

**Next:** In Lesson 2, we will move from visualizing to quantifying these distributions with formal descriptive statistics.

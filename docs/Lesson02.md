### Lesson 2: Descriptive Statistics and Distributions

**Objective:** To move from initial plots to quantitative summaries of the data. This lesson introduces how to calculate and interpret descriptive statistics, which are the backbone of any "Table 1" in a clinical study.

---

#### **Why This Matters**

Descriptive statistics provide a precise, quantitative summary of your cohort. While plots from Lesson 1 give a feel for the data, these numbers are essential for formal reporting and for making comparisons. Key applications include:

*   **Establishing a Baseline:** Understanding the central tendency (e.g., median age) and spread (e.g., age range) of your patient population.
*   **Characterizing Subgroups:** Quantifying the number of patients in clinically relevant categories, such as tumor grade or IDH mutation status.
*   **Informing Statistical Test Selection:** The distribution of your data (e.g., whether it's normally distributed or skewed) determines which statistical tests are appropriate for later analyses.

---

#### **What the R Script Does**

The `R/Lesson2.R` script performs two main tasks:

1.  **Calculates Descriptive Statistics:**
    *   For continuous variables like `Age`, it computes a five-number summary (minimum, 1st quartile, median, 3rd quartile, maximum).
    *   For categorical variables (`Gender`, `Grade`, `IDH_mutation_status`), it counts the number of patients in each category.
2.  **Visualizes Distributions:**
    *   It generates an overlapping histogram to visually compare the age distribution between male and female patients.

---

#### **Step-by-Step Analysis in `R/Lesson2.R`**

**1. Summaries and Counts**
*Clinical Question:* What is the exact age profile and categorical breakdown of our cohort?
```r
# Get a statistical summary for the 'Age' variable
summary(data$Age)

# Count the number of patients for each category
table(data$Gender)
table(data$Grade)
table(data$IDH_mutation_status)
```
*Interpretation:* The `summary()` output for age gives you the median and interquartile range (IQR), which are often more robust for skewed clinical data than the mean. The `table()` outputs provide the counts for key clinical and molecular subgroups.

**2. Age Distribution by Gender**
*Clinical Question:* Is there a visible difference in the age distribution between male and female patients?
```r
df <- subset(data, !is.na(Age) & !is.na(Gender))
p <- ggplot(df, aes(x = Age, fill = Gender)) +
  geom_histogram(binwidth = 5, alpha = 0.6, position = "identity") +
  theme_minimal() +
  labs(title = "Age Distribution by Gender", x = "Age (years)", y = "Number of Patients")
save_plot_both(p, "Lesson2_Age_by_Gender")
```

---

#### **Key Clinical Insights & Interpretation**

*   **Quantitative Cohort Profile:** You now have the precise numbers to report in a publication, such as "The median age was X years (IQR: Y-Z)" or "N% of patients had an IDH mutation."
*   **Visual Comparison of Subgroups:** The overlapping histogram allows for a direct visual comparison of the age profiles of male and female patients. You can look for differences in the peak age or the spread of ages between the two groups. This can be an early indicator of demographic differences that might be relevant for prognosis or treatment response.

---

#### **How to Run the Script**

To generate the output yourself, run this command from your terminal:

```bash
Rscript R/Lesson2.R
```

**Next:** In Lesson 3, we will explore relationships between two categorical variables, a common task in clinical research (e.g., "Is there an association between tumor grade and PRS type?").

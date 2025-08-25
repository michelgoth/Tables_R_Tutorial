### Lesson 8: Comparing Continuous Variables Between Clinical Groups

**Objective:** To learn how to compare a continuous variable (like age or survival time) between two different clinical groups using appropriate statistical tests (t-test or Wilcoxon test) and visualize the results with boxplots.

---

#### **Why This Matters**

A common task in clinical research is to compare a continuous measurement between two groups. For example:

*   Is there a difference in age at diagnosis between patients with IDH-mutant and IDH-wildtype tumors?
*   Do patients with MGMT-methylated tumors have a longer overall survival than those with unmethylated tumors?

Answering these questions requires a formal statistical test. The two most common are:

*   **T-test:** Used when the data in each group are approximately normally distributed.
*   **Wilcoxon Rank-Sum Test (or Mann-Whitney U Test):** A "non-parametric" test that does not assume the data is normally distributed. It's often a safer and more robust choice for clinical data, which is frequently skewed.

This lesson focuses on the Wilcoxon test.

---

#### **What the R Script Does**

The `R/Lesson8.R` script performs two main comparisons:

1.  **Age by IDH Mutation Status:** It uses a Wilcoxon test to determine if there is a statistically significant difference in the age of patients with IDH-mutant versus IDH-wildtype tumors.
2.  **Overall Survival by MGMT Methylation Status:** It applies a Wilcoxon test to compare the overall survival (in days) between MGMT-methylated and unmethylated groups.
3.  **Visualizes with Boxplots:** It generates a boxplot to visually represent the distribution of overall survival for each MGMT methylation status group.

---

#### **Step-by-Step Analysis in `R/Lesson8.R`**

**1. Compare Age by IDH Status (Wilcoxon Test)**
*Clinical Question:* Is there a significant difference in the age at diagnosis between IDH-mutant and IDH-wildtype patients?
```r
df <- subset(data, !is.na(Age) & !is.na(IDH_mutation_status))

# The formula 'Age ~ IDH_mutation_status' tells the test to compare 'Age' between the IDH groups
wilcox.test(Age ~ IDH_mutation_status, data = df)
```

**2. Compare Overall Survival by MGMT Status and Visualize**
*Clinical Question:* Do patients with MGMT-methylated tumors have a different overall survival distribution compared to unmethylated patients?
```r
df <- subset(data, !is.na(OS) & !is.na(MGMTp_methylation_status))

# Perform the Wilcoxon test
wilcox.test(OS ~ MGMTp_methylation_status, data = df)

# Create a boxplot to visualize the distributions
p <- ggplot(df, aes(x = MGMTp_methylation_status, y = OS, fill = MGMTp_methylation_status)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "OS by MGMT Methylation Status", x = "MGMT Status", y = "Overall Survival (days)")
save_plot_both(p, "Lesson8_OS_by_MGMT")
```

---

#### **Key Clinical Insights & Interpretation**

*   **Interpreting the p-value:** As with previous tests, the p-value is the key output. A p-value < 0.05 suggests a statistically significant difference in the continuous variable between the two groups. For the first test, a significant result would confirm the known clinical observation that patients with IDH-mutant gliomas are typically younger at diagnosis.
*   **Interpreting the Boxplot:**
    *   The **thick line** in the middle of the box is the **median**. Comparing the medians gives you a sense of the central tendency of the two groups.
    *   The **box** represents the **interquartile range (IQR)**, the middle 50% of the data. A taller box means more variability in that group.
    *   The **whiskers** extend to the range of the data, excluding outliers.
    *   **Dots** beyond the whiskers are potential **outliers**.

---

#### **How to Run the Script**

To run the tests and generate the boxplot, use this command:

```bash
Rscript R/Lesson8.R
```

**Next:** In Lesson 9, we will introduce **logistic regression**, a powerful technique used when your outcome of interest is binary (e.g., presence or absence of a mutation).



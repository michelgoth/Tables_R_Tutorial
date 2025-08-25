### Lesson 7: Testing Associations Between Categorical Variables

**Objective:** To statistically test for associations between two categorical variables using the **Chi-squared test** and **Fisher's exact test**. This moves beyond the visual inspection of plots (Lesson 3) to formal hypothesis testing.

---

#### **Why This Matters**

In clinical research, we constantly need to determine if certain characteristics are independent of each other or if they are associated. For example:

*   Is a specific molecular marker (like IDH mutation) more common in certain tumor grades?
*   Is a particular treatment prescribed more often to one gender?

These tests provide a p-value to help decide if an observed association in the data is likely real or just due to random chance. This is a fundamental component of building the "Table 1" of a paper, where you often report the distribution of baseline characteristics between different groups.

*   **Chi-squared test:** Used for larger sample sizes.
*   **Fisher's exact test:** Used when the sample size is small (e.g., when any cell in your comparison table has fewer than 5 counts).

---

#### **What the R Script Does**

The `R/Lesson7.R` script performs two separate statistical tests:

1.  **Chi-squared Test (IDH Status vs. Tumor Grade):** It first creates a contingency table (a table of counts) for IDH status versus tumor grade and then runs the Chi-squared test on it.
2.  **Fisher's Exact Test (Gender vs. MGMT Status):** It performs a Fisher's exact test to check for an association between gender and MGMT methylation status, which is more appropriate if some of the subgroups are small.
3.  **Visualizes the Association:** It also generates a bar plot for the IDH vs. Grade comparison to provide a visual counterpart to the statistical test.

---

#### **Step-by-Step Analysis in `R/Lesson7.R`**

**1. Chi-squared Test: IDH Status by Tumor Grade**
*Clinical Question:* Is there a statistically significant association between WHO grade and IDH mutation status?
```r
# Create a contingency table of counts
table_idh_grade <- table(data_idh_grade$IDH_mutation_status, data_idh_grade$Grade)

# Perform the Chi-squared test
chisq.test(table_idh_grade)

# Visualize the relationship
ggplot(data_idh_grade, aes(x = Grade, fill = IDH_mutation_status)) +
  geom_bar(position = "dodge") +
  labs(title = "IDH Status by Tumor Grade", x = "Grade", y = "Count") +
  theme_minimal()
```

**2. Fisher's Exact Test: Gender by MGMT Status**
*Clinical Question:* Is there a statistically significant association between gender and MGMT methylation status?
```r
# Fisher's test can be run directly on the table
fisher.test(table(data_gender_mgmt$Gender, data_gender_mgmt$MGMTp_methylation_status))
```

---

#### **Key Clinical Insights & Interpretation**

*   **Interpreting the p-value:** For both tests, the key output is the p-value. A p-value less than 0.05 suggests that there is a statistically significant association between the two variables. For example, a significant result for the first test would imply that the distribution of IDH mutations is not the same across different tumor grades. This is a known and critical association in neuro-oncology (lower-grade gliomas are much more likely to be IDH-mutant).
*   **Context is Crucial:** A significant p-value tells you an association exists, but you must look at the contingency table or the plot to understand the *nature* of that association. For instance, which grade has the highest proportion of IDH-mutant tumors?
*   **Association is Not Causation:** Remember, these tests only show an association. They do not prove that one variable causes the other.

---

#### **How to Run the Script**

To run the tests and generate the plot, use this command:

```bash
Rscript R/Lesson7.R
```

**Next:** In Lesson 8, we will perform similar comparisons, but for a continuous variable against a categorical variable (e.g., comparing the age distribution between two groups) using t-tests and Wilcoxon tests.



### Lesson 5: Testing for Survival Differences with the Log-Rank Test

**Objective:** To statistically quantify the difference between survival curves using the log-rank test. This lesson moves from visual inspection of Kaplan-Meier plots to hypothesis testing, allowing us to determine if observed differences are statistically significant.

---

#### **Why This Matters**

A Kaplan-Meier plot can show a *visual* difference between groups, but it doesn't tell you the *probability* that this difference is due to chance. The log-rank test provides a p-value to address this. It is the standard method for comparing survival distributions between two or more groups and is fundamental to interpreting clinical trial data. You would use it to formally answer questions like:

*   "Is the survival difference between MGMT-methylated and unmethylated patients statistically significant?"
*   "Does this new treatment lead to a significant survival benefit compared to the standard of care?"

In this lesson, we focus on `MGMTp_methylation_status`, a key predictive biomarker in glioblastoma for response to temozolomide.

---

#### **What the R Script Does**

The `R/Lesson5.R` script performs the following:

1.  **Builds a Survival Object:** As in Lesson 4, it combines the `OS` (time) and `Censor` (event) variables.
2.  **Performs the Log-Rank Test:** It uses the `survdiff()` function to compare the survival curves between groups based on `MGMTp_methylation_status`.
3.  **Prints the Results:** It displays the test statistic (Chi-Square) and the p-value in the console.
4.  **Generates a KM Plot:** For visual confirmation, it also generates and saves the corresponding Kaplan-Meier plot.

---

#### **Step-by-Step Analysis in `R/Lesson5.R`**

**1. Perform the Log-Rank Test for MGMT Status**
*Clinical Question:* Is there a statistically significant difference in overall survival between patients with different MGMT methylation statuses?
```r
# The survdiff() function performs the log-rank test
# The formula is the same as for the Kaplan-Meier fit
df_mgmt <- subset(data, !is.na(OS) & !is.na(Censor) & !is.na(MGMTp_methylation_status))

test_result <- survdiff(Surv(OS, Censor) ~ MGMTp_methylation_status, data = df_mgmt)

print(test_result)
```

**2. Visualize the Result with a Kaplan-Meier Plot**
*Clinical Question:* What does the difference we just tested look like?
```r
# We create a KM plot to accompany the log-rank test result
fit_km <- survfit(Surv(OS, Censor) ~ MGMTp_methylation_status, data = df_mgmt)

plot(fit_km, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
     main = "Survival by MGMT Methylation Status")
legend("topright", legend = levels(df_mgmt$MGMTp_methylation_status), col = 1:3, lwd = 2)
```

---

#### **Key Clinical Insights & Interpretation**

The output of the `survdiff` function is key:

```
# Example Output
Call:
survdiff(formula = Surv(OS, Censor) ~ MGMTp_methylation_status, data = df_mgmt)

                                  N Observed Expected (O-E)^2/E (O-E)^2/V
MGMTp_methylation_status=methylated   ...      ...      ...       ...       ...
MGMTp_methylation_status=un-methylated ...      ...      ...       ...       ...

 Chisq= 25.3  on 1 degrees of freedom, p= 4.9e-07
```

*   **The p-value:** This is the most important number. A small p-value (typically < 0.05) indicates that it is unlikely the observed difference in survival curves is due to random chance. You would conclude there is a statistically significant difference between the groups.
*   **Chi-Square (`Chisq`) Statistic:** This value is used to calculate the p-value. A larger Chi-Square value corresponds to a smaller p-value.
*   **Pairing with the Plot:** Always interpret the p-value in the context of the KM plot. The plot shows the *direction* and *magnitude* of the difference (i.e., which group has better survival and by how much), while the p-value tells you if that difference is statistically significant.

---

#### **How to Run the Script**

To perform the log-rank test and generate the plot, run this command:

```bash
Rscript R/Lesson5.R
```

**Next:** The log-rank test is great for comparing groups on a single variable. But what if we want to account for multiple factors at once (e.g., age, grade, AND MGMT status)? For that, we need **Cox regression**, which is covered in Lesson 6.

### Lesson 6: Multivariable Survival Analysis with the Cox Proportional Hazards Model

**Objective:** To learn how to perform multivariable survival analysis using the Cox Proportional Hazards model. This allows us to estimate the effect of several clinical variables on survival simultaneously and understand which factors are independent predictors of outcome.

---

#### **Why This Matters**

While the log-rank test (Lesson 5) is excellent for comparing survival for a *single* factor, patients have multiple characteristics that influence their outcome (e.g., age, tumor grade, molecular markers). A patient's risk is a combination of these factors. The Cox model is the standard method to disentangle these effects. It helps answer the critical question:

**"When we account for other known prognostic factors, does our variable of interest still have a significant impact on survival?"**

For example, if a new biomarker is associated with better survival in a log-rank test, a Cox model can tell you if that association holds true *after* adjusting for the powerful effects of age, IDH mutation, and grade. The output of this model is the **Hazard Ratio (HR)**, a measure you will constantly encounter in clinical literature.

---

#### **What the R Script Does**

The `R/Lesson6.R` script performs the following:

1.  **Fits a Multivariable Cox Model:** It uses the `coxph()` function to build a single model that includes multiple predictor variables (`Age`, `Gender`, `Grade`, `IDH_mutation_status`, etc.) to predict survival. The model automatically handles using only patients who have complete data for all included variables.
2.  **Prints the Model Summary:** It displays a detailed summary of the model, including the hazard ratio for each variable, the 95% confidence interval, and a p-value.
3.  **Generates an Overall KM Plot:** For context, it also plots the overall survival of the entire cohort used in the model.

---

#### **Step-by-Step Analysis in `R/Lesson6.R`**

**1. Fit the Multivariable Cox Model**
*Clinical Question:* What are the independent effects of key clinical and molecular variables on overall survival?
```r
# The formula now includes multiple variables separated by '+'
cox_model <- coxph(Surv(OS, Censor) ~ Age + Gender + Grade + IDH_mutation_status +
                   MGMTp_methylation_status + PRS_type + Chemo_status + Radio_status,
                   data = data)

# Display the detailed results
summary(cox_model)
```

---

#### **Key Clinical Insights & Interpretation**

The `summary(cox_model)` output is dense but provides a wealth of information. Focus on this part of the table:

```
# Example Output Snippet
                          coef exp(coef) se(coef)      z Pr(>|z|)
Age                     0.0351    1.0357   0.0071   4.94  7.8e-07 ***
GenderMale             -0.1234    0.8839   0.1567  -0.79    0.431
IDH_mutation_statusMutant -1.2345    0.2910   0.1876  -6.58  4.7e-11 ***
```

*   **`exp(coef)` is the Hazard Ratio (HR):** This is the most important value.
    *   **HR > 1:** Indicates an *increased* risk (hazard) of the event (death) for each one-unit increase in the variable. For `Age`, an HR of 1.036 means that for each additional year of age, the hazard of death increases by about 3.6%, *holding all other variables constant*.
    *   **HR < 1:** Indicates a *decreased* risk. For `IDH_mutation_statusMutant`, an HR of 0.291 means that having an IDH mutation is associated with a ~71% reduction in the hazard of death compared to IDH-wildtype, *after adjusting for all other factors in the model*.
*   **`Pr(>|z|)` is the p-value:** This tells you if the effect of the variable is statistically significant. A p-value < 0.05 suggests that the variable is an independent predictor of survival.
*   **Confidence Intervals (not shown in snippet, but in full output):** The 95% confidence interval for the HR is crucial. If the interval does not include 1.0, the result is statistically significant. For example, a CI of [0.20, 0.45] for IDH status is significant, while a CI of [0.75, 1.15] for Gender is not.

---

#### **How to Run the Script**

To fit the Cox model and see the results, run this command:

```bash
Rscript R/Lesson6.R
```

**Next:** So far we've focused on survival. In Lesson 7, we'll shift back to exploring associations between categorical variables, this time with formal statistical tests like the Chi-squared test.



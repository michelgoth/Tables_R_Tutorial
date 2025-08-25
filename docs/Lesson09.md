### Lesson 9: Predicting Binary Outcomes with Logistic Regression

**Objective:** To learn how to use **logistic regression** to model a binary clinical outcome. This technique allows us to understand how various predictor variables are associated with the probability of an event, such as the presence of a mutation or a specific clinical feature.

---

#### **Why This Matters**

Not all outcomes in clinical research are survival times. Often, we want to predict a binary (Yes/No) state. For example:

*   What patient characteristics are associated with the presence of an `IDH` mutation?
*   Can we predict the likelihood of a patient having a specific histology based on their age and tumor grade?
*   What factors are associated with a patient receiving a particular treatment?

Logistic regression is the standard statistical method for answering these questions. Instead of the Hazard Ratio (from Cox regression), its key output is the **Odds Ratio (OR)**, which is a way of quantifying how strongly a predictor is associated with the outcome.

---

#### **What the R Script Does**

The `R/Lesson9.R` script performs the following:

1.  **Prepares the Data:** It filters the dataset to include only patients with a known `IDH_mutation_status` ("Mutant" or "Wildtype"), making it a clean binary outcome.
2.  **Fits a Logistic Regression Model:** It uses the `glm()` (generalized linear model) function with `family = "binomial"` to predict the `IDH_mutation_status` based on `Age`, `Gender`, `Grade`, and `MGMTp_methylation_status`.
3.  **Prints the Model Summary:** It displays the statistical summary of the model.
4.  **Visualizes Coefficients:** It creates a bar plot of the model's coefficients to show the direction and relative magnitude of each variable's effect.

---

#### **Step-by-Step Analysis in `R/Lesson9.R`**

**1. Fit the Logistic Regression Model**
*Clinical Question:* Which clinical factors are associated with the odds of having an IDH-wildtype tumor vs. an IDH-mutant tumor?
```r
# The glm() function with family="binomial" fits a logistic regression model.
# Note: R by default models the probability of the *second* factor level.
# If the levels are "Mutant", "Wildtype", this models the probability of "Wildtype".
model <- glm(IDH_mutation_status ~ Age + Gender + Grade + MGMTp_methylation_status,
             data = d2, family = "binomial")

summary(model)
```

---

#### **Key Clinical Insights & Interpretation**

The output of `summary(model)` provides coefficients, but for clinical interpretation, we often convert them to Odds Ratios.

```
# Example Output Snippet (Coefficients)
             Estimate Std. Error z value Pr(>|z|)
(Intercept)   -7.8540     1.5167  -5.178 2.24e-07 ***
Age            0.1235     0.0221   5.589 2.28e-08 ***
GradeIV        5.6789     1.0123   5.610 2.02e-08 ***
```

*   **Coefficients (`Estimate`):** These are on a "log-odds" scale and are less intuitive. The sign is what's important:
    *   **Positive coefficient:** The variable increases the odds of the outcome (e.g., older `Age` increases the odds of having an IDH-wildtype tumor).
    *   **Negative coefficient:** The variable decreases the odds of the outcome.
*   **Odds Ratios (OR):** To make this clinically meaningful, we exponentiate the coefficient: `exp(Estimate)`.
    *   For `Age`, the OR is `exp(0.1235) ≈ 1.13`. This means for each one-year increase in age, the odds of having an IDH-wildtype tumor increase by about 13%, holding other variables constant.
    *   An OR > 1 means increased odds.
    *   An OR < 1 means decreased odds.
    *   An OR of 1 means no association.
*   **p-value (`Pr(>|z|)`):** As before, a p-value < 0.05 indicates a statistically significant association between the predictor and the outcome.

---

#### **How to Run the Script**

To fit the logistic regression model and see the results, run this command:

```bash
Rscript R/Lesson9.R
```

**Next:** In Lesson 10, we will explore the relationships between multiple *continuous* variables using a correlation matrix.



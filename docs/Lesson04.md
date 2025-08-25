### Lesson 4: Introduction to Survival Analysis with Kaplan-Meier Curves

**Objective:** To introduce the fundamentals of survival analysis by creating and interpreting a Kaplan-Meier (KM) survival curve. This is one of the most common and important analyses in clinical research, used to visualize time-to-event data.

---

#### **Why This Matters**

Survival analysis is the cornerstone of oncology research and clinical trial interpretation. Understanding KM curves is not optional; it's essential for evidence-based practice. Specifically, it allows you to:

*   **Visualize Patient Outcomes:** See the probability of survival over time for a group of patients.
*   **Compare Groups:** Determine if different subgroups of patients (e.g., based on a mutation or treatment) have different survival outcomes. IDH mutation is a classic, powerful prognostic marker in neuro-oncology, and this analysis will demonstrate its impact.
*   **Estimate Median Survival:** Find the time at which 50% of the patient cohort is still alive, a key metric for prognosis.

---

#### **What the R Script Does**

The `R/Lesson4.R` script performs the following key steps:

1.  **Creates a Survival Object:** It combines the two critical pieces of information for survival analysis:
    *   `OS`: The follow-up time (Overall Survival in days).
    *   `Censor`: The event status (1 if the patient is deceased, 0 if they were still alive at last follow-up).
2.  **Fits the Kaplan-Meier Model:** It calculates the survival probabilities at different time points for patients, stratified by their `IDH_mutation_status`.
3.  **Generates and Saves the Plot:** It plots the KM curves for the different IDH groups and saves the output.

---

#### **Step-by-Step Analysis in `R/Lesson4.R`**

**1. Create a Survival Object**
*Clinical Question:* How do we format our data for a survival analysis?
```r
df <- subset(data, !is.na(OS) & !is.na(Censor) & !is.na(IDH_mutation_status))

# The 'Surv' function packages time and event data together
surv_obj <- Surv(time = as.numeric(df$OS), event = df$Censor)
```

**2. Fit Kaplan-Meier Model by IDH Status**
*Clinical Question:* Does overall survival differ between patients with and without an IDH mutation?
```r
# 'survfit' calculates the KM curves
# The formula '~ IDH_mutation_status' tells it to create separate curves for each IDH group
fit_idh <- survfit(surv_obj ~ IDH_mutation_status, data = df)
```

**3. Plot and Save the Curves**
*Clinical Question:* How can we visualize the difference in survival?
```r
# 'plot' generates the KM curve visualization
plot(fit_idh, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
     main = "Survival by IDH Mutation Status")
legend("topright", legend = levels(df$IDH_mutation_status), col = 1:3, lwd = 2)
# The script then saves this plot to the plots/ directory
```

---

#### **Key Clinical Insights & Interpretation**

*   **Curve Separation:** The plot will show two or more curves. If the curves separate and remain apart, it suggests a difference in survival between the groups. In gliomas, you should expect to see a dramatic separation, with the IDH-mutant curve far above the IDH-wildtype curve, indicating better survival.
*   **Steps in the Curve:** Each downward step in a curve represents one or more events (deaths).
*   **Censoring:** Small vertical ticks on the curves often represent censored patients—those who were alive at their last follow-up or were lost to follow-up.

---

#### **How to Run the Script**

To generate the KM plot, run this command from your terminal:

```bash
Rscript R/Lesson4.R
```

**Next:** In Lesson 5, we will learn how to formally test the visual difference observed in the Kaplan-Meier plot using the **log-rank test** to get a p-value.

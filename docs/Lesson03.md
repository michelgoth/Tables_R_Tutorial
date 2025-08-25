### Lesson 3: Visualizing Associations Between Categorical Variables

**Objective:** To learn how to visualize the relationship between two categorical clinical variables. This is a fundamental step for understanding the composition of a cohort and identifying potential associations that warrant further statistical testing.

---

#### **Why This Matters**

Visualizing how different patient or tumor characteristics co-occur is crucial for forming a complete picture of your cohort. It helps answer questions like:

*   **Are certain features linked?** For example, are higher-grade tumors more common in recurrent cases compared to primary presentations?
*   **Are there demographic associations?** Does the frequency of a key molecular marker like IDH mutation differ between male and female patients?
*   **Generating Hypotheses:** These plots can reveal patterns that form the basis of a formal hypothesis. An observed imbalance in these charts is often the first step towards a chi-squared test (which we'll cover in a later lesson).

---

#### **What the R Script Does**

The `R/Lesson3.R` script generates two grouped bar charts to explore potential associations:

1.  **Tumor Grade by Presentation Type:** It visualizes the count of each tumor grade, broken down by whether the tumor is a primary, recurrent, or secondary presentation (`PRS_type`).
2.  **IDH Mutation Status by Gender:** It plots the number of IDH-mutant vs. IDH-wildtype cases, separated by gender.

---

#### **Step-by-Step Analysis in `R/Lesson3.R`**

**1. Tumor Grade by Presentation Type (PRS)**
*Clinical Question:* Does the distribution of tumor grades differ across primary, recurrent, and secondary gliomas?
```r
df <- subset(data, !is.na(Grade) & !is.na(PRS_type))
p1 <- ggplot(df, aes(x = Grade, fill = PRS_type)) +
  geom_bar(position = "dodge") +
  labs(title = "Tumor Grade by Presentation Type", x = "WHO Tumor Grade", y = "Number of Patients") +
  theme_minimal()
save_plot_both(p1, "Lesson3_Grade_by_PRS")
```

**2. IDH Mutation Status by Gender**
*Clinical Question:* Is there a visual difference in the frequency of IDH mutations between male and female patients?
```r
df <- subset(data, !is.na(IDH_mutation_status) & !is.na(Gender))
p2 <- ggplot(df, aes(x = IDH_mutation_status, fill = Gender)) +
  geom_bar(position = "dodge") +
  labs(title = "IDH Mutation Status by Gender", x = "IDH Mutation Status", y = "Number of Patients") +
  theme_minimal()
save_plot_both(p2, "Lesson3_IDH_by_Gender")
```

---

#### **Key Clinical Insights & Interpretation**

*   **Case Mix Insights:** The first plot helps you understand your case mix. For example, you might observe that Grade IV tumors are predominantly from primary presentations, while lower-grade tumors might be more represented in secondary cases. This has implications for interpreting survival data later on.
*   **Exploring Molecular Marker Distributions:** The second plot provides a quick visual check for the distribution of a critical prognostic marker (IDH mutation) across genders. While this plot alone doesn't prove a statistical association, a large visual imbalance could suggest a demographic factor to consider in more complex models.

---

#### **How to Run the Script**

To generate the plots, run this command from your terminal:

```bash
Rscript R/Lesson3.R
```

**Next:** In Lesson 4, we will introduce one of the most important concepts in clinical research: **survival analysis**. We will create our first Kaplan-Meier survival curve.

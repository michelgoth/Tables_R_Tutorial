### Lesson 11: Comparing Continuous Variables Across Multiple Groups with ANOVA

**Objective:** To learn how to use **Analysis of Variance (ANOVA)** to compare the mean of a continuous variable across three or more groups. This lesson also introduces extensions like two-way ANOVA and MANOVA.

---

#### **Why This Matters**

In Lesson 8, we compared a continuous variable between *two* groups (e.g., MGMT methylated vs. unmethylated). But what if you have more than two groups? For example:

*   Does the mean age at diagnosis differ significantly across WHO Grades II, III, and IV?
*   Is there a difference in a quantitative biomarker score among different histological subtypes?

Running multiple t-tests between all possible pairs of groups is statistically incorrect because it inflates the chance of a false positive. **ANOVA** is the proper statistical test to use. It tests the overall hypothesis of whether there is a significant difference among the means of any of the groups.

This lesson also introduces:
*   **Post-Hoc Tests (e.g., Tukey's HSD):** If the ANOVA test is significant, these tests tell you *which specific groups* differ from each other (e.g., Grade IV vs. Grade II).
*   **Two-Way ANOVA:** Lets you test the effect of two categorical variables on a continuous outcome at the same time.
*   **MANOVA:** Lets you test the effect of a categorical variable on *multiple* continuous outcomes at once.

---

#### **What the R Script Does**

The comprehensive `R/Lesson11.R` script demonstrates several types of ANOVA:

1.  **One-Way ANOVA:** It tests if the mean `OS` (Overall Survival) differs across tumor `Grade`. It also generates a boxplot for visualization.
2.  **Two-Way ANOVA:** It examines the effect of both `Grade` and `Gender` (and their interaction) on `OS`.
3.  **Post-Hoc Analysis:** It runs a Tukey's HSD test to identify which specific grades have different mean `OS`.
4.  **MANOVA:** It tests whether `Grade` has a significant effect on `Age` and `OS` simultaneously.
5.  **Assumption Checking:** It performs tests (like Levene's test for homogeneity of variance) to check if the assumptions of ANOVA are met.

---

#### **Step-by-Step Analysis in `R/Lesson11.R`**

**1. One-Way ANOVA**
*Clinical Question:* Is there a statistically significant difference in mean Overall Survival among the different WHO Grades?
```r
# The aov() function performs the ANOVA test.
anova_result <- aov(OS ~ Grade, data = analysis_data)
summary(anova_result)

# If the ANOVA p-value is significant, perform a post-hoc test to see which groups differ.
tukey_result <- TukeyHSD(anova_result)
print(tukey_result)
```

**2. Visualizing the Comparison**
*Clinical Question:* What do the differences in survival across grades look like?
```r
ggplot(analysis_data, aes(x = Grade, y = OS, fill = Grade)) +
  geom_boxplot() +
  labs(title = "OS by Tumor Grade", x = "Grade", y = "Overall Survival (days)")
```

---

#### **Key Clinical Insights & Interpretation**

*   **ANOVA `p-value`:** The main ANOVA output gives you a single p-value. If p < 0.05, you can conclude that *at least one group* has a different mean from the others. It does *not* tell you which one.
*   **Post-Hoc Test `p-adj`:** The output of the Tukey's HSD test gives you adjusted p-values for each pairwise comparison (e.g., Grade IV vs. Grade II, Grade III vs. Grade II). A significant `p-adj` here tells you that those two specific groups have a statistically different mean `OS`. You should expect to find that higher grades have significantly shorter mean `OS`.
*   **Checking Assumptions:** ANOVA has assumptions (like the data within each group being normally distributed and having similar variances). The script runs tests for these. If assumptions are violated, you might need to use a non-parametric alternative (like the Kruskal-Wallis test), which is conceptually similar to the Wilcoxon test but for >2 groups.

---

#### **How to Run the Script**

To run the full suite of ANOVA tests, use this command:

```bash
Rscript R/Lesson11.R
```

**Next:** In Lesson 12, we will dive into a more comprehensive, clinically-focused survival analysis, including creating a baseline characteristics table ("Table 1") and checking the assumptions of the Cox model.



### Lesson 12: A Comprehensive Clinical Survival Analysis Workflow

**Objective:** To integrate several key analytical steps into a comprehensive workflow that mirrors a typical clinical research project. This lesson covers creating a baseline characteristics table, assessing data quality, screening variables, building a risk model, and checking model assumptions.

---

#### **Why This Matters**

This lesson is designed to be highly practical, automating five tasks that are central to almost any clinical survival analysis paper:

1.  **Baseline Characteristics ("Table 1"):** Every clinical paper starts with a table describing the cohort. This is the first step.
2.  **Missing Data Assessment:** Understanding how much and where data is missing is critical for interpreting your results and identifying data quality issues.
3.  **Univariable Screening:** Before building a multivariable model, it's common to screen variables individually to see their unadjusted relationship with survival. A **forest plot** is the standard way to visualize this.
4.  **Risk Stratification:** A powerful way to use a multivariable model is to create risk groups. By combining information from multiple predictors, you can stratify patients into low, medium, and high-risk categories and visualize their outcomes.
5.  **Assumption Checking:** Statistical models have assumptions. The Cox model's main assumption is **proportional hazards**. Checking this is a mark of a rigorous analysis.

---

#### **What the R Script Does**

The `R/Lesson12.R` script is broken into five sections, each producing a key output:

1.  **Baseline Table:** Prints counts for categorical variables and a summary for `Age` to the console.
2.  **Missingness Profile:** Generates a bar chart showing the number of missing values for each variable.
3.  **Univariable Cox Analysis:** Loops through a list of predictor variables, runs a separate Cox model for each one, and visualizes all the Hazard Ratios in a single forest plot.
4.  **Risk Stratification:** Builds a multivariable Cox model, calculates a risk score (the linear predictor) for each patient, divides patients into three risk groups (tertiles), and generates a Kaplan-Meier plot of these groups.
5.  **Proportional Hazards (PH) Assumption Check:** Runs a formal test (`cox.zph`) on the multivariable model to check the PH assumption and creates diagnostic plots.

---

#### **Key Clinical Insights & Interpretation**

*   **Forest Plot of Univariable HRs:**
    *   Each row represents a variable's effect on survival.
    *   The **dot** is the Hazard Ratio (HR).
    *   The **horizontal line** is the 95% confidence interval.
    *   A **vertical line at HR=1.0** represents no effect. If a variable's confidence interval does not cross this line, its effect is statistically significant in a univariable setting.

*   **Kaplan-Meier by Risk Group:**
    *   This plot is a key output for many prognostic studies. It should show a clear "stair-step" separation between the low, medium, and high-risk groups, demonstrating that your model can successfully stratify patient outcomes.

*   **Proportional Hazards (PH) Test:**
    *   The output shows a p-value for each variable in the model and a `GLOBAL` p-value.
    *   **If p > 0.05:** The assumption holds. The variable's effect on hazard is constant over time. This is the desired outcome.
    *   **If p < 0.05:** The assumption is violated. This means the variable's effect changes over time (e.g., a treatment has a strong early benefit that wanes). This is an important finding that may require more advanced modeling techniques.

---

#### **How to Run the Script**

To run the entire analysis pipeline and generate all the plots, use this command:

```bash
Rscript R/Lesson12.R
```

**Next:** In Lesson 13, we will touch on the basics of machine learning by exploring the concept of feature importance using a Random Forest model.



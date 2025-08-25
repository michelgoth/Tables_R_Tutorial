# Lesson 19: Advanced Model Diagnostics & Statistical Rigor

## Objective
This lesson completes our journey from basic data exploration to a robust, validated, and statistically sound prognostic model. We will now address the final layer of a rigorous analysis: **formally testing the core assumptions of our Cox model**.

A model that has been validated (Lesson 18) and has also passed these diagnostic checks is one that can be presented with a high degree of confidence.

## Assumption 1: Proportional Hazards

The Cox model is technically the Cox **Proportional Hazards** model. This name holds the key to its main assumption.

-   **What it Means:** It assumes that the effect (the Hazard Ratio) of a given variable is **constant over time**. For example, it assumes that the increased risk associated with having a Grade IV tumor (compared to Grade II) is the same at 1 month post-diagnosis as it is at 5 years post-diagnosis.
-   **Why it Matters:** If the assumption is violated, the model's conclusions can be wrong. For instance, a variable might be a major risk factor early on but have no effect later. A standard Cox model would miss this and average the effect over time, giving a misleading result.
-   **How We Test It:** We use the `cox.zph()` function. This function performs a test for each variable and a `GLOBAL` test for the model as a whole. The null hypothesis is that the assumption is met. Therefore, a **p-value > 0.05 is good**, indicating the assumption holds. A p-value < 0.05 is bad, indicating a violation.
-   **How We Visualize It:** The script now also generates the plot `Lesson19_PH_Assumption_Checks.pdf`. This plot shows the scaled residuals over time for each variable.
    -   **Good:** A randomly scattered pattern of points forming a roughly horizontal line.
    -   **Bad:** A clear slope or pattern in the points, which visually confirms that the variable's effect is changing over time.

## Assumption 2: Linearity of Continuous Variables

When we include a variable like `Age` in our model, we are making an assumption about its relationship with risk.

-   **What it Means:** The standard model assumes the relationship is **linear**. This means that for every single year older a patient is, their risk of mortality increases by the exact same fixed amount.
-   **Why it Matters:** This is often not true in biology. It might be that the risk from age is minimal for younger patients but accelerates rapidly after age 60. A simple linear model would fail to capture this nuance and could underestimate the risk for older patients.
-   **How We Test It:** We build a second, more flexible model that allows for a non-linear (curved) relationship for `Age` using a technique called **splines**. We then statistically compare this flexible model to our original linear model using an ANOVA test.
    -   A **p-value > 0.05** means the simple, linear model is sufficient.
    -   A **p-value < 0.05** tells us that the more complex, curved model is significantly better, meaning the linearity assumption was violated.
-   **How We Visualize It:** To make this clear, the script generates the plot `Lesson19_Age_Linearity_Check.pdf`. This plot shows the effect of Age on risk that the flexible spline model estimated.
    -   **Linear:** If the line is mostly straight, it confirms the ANOVA test result that a simple linear effect is adequate.
    -   **Non-Linear:** If the line is clearly curved, it provides visual proof that the relationship is more complex.

## The Final Verdict

By performing the validation in Lesson 18 and the assumption checks in Lesson 19, you have completed the workflow of a high-quality clinical research analysis. You can now:
1.  **Trust the model's performance** because it has been validated on unseen data.
2.  **Trust the model's structure** because you have confirmed that the underlying statistical assumptions are met.

This rigorous process is what separates a preliminary analysis from a publication-ready, scientifically defensible conclusion.

### Lesson 10: Exploring Relationships Between Numeric Variables with a Correlation Matrix

**Objective:** To learn how to calculate and visualize the correlation between multiple numeric variables simultaneously using a correlation matrix and a correlogram.

---

#### **Why This Matters**

Understanding how different continuous variables in your dataset relate to each other is an important part of data exploration. For instance:

*   Are two different clinical measurements highly correlated, suggesting they might be capturing similar information?
*   Is there a strong relationship between age and another biomarker?

This analysis is particularly important for building robust multivariable models (like the Cox model in Lesson 6). If two predictor variables are very highly correlated (a problem called **multicollinearity**), it can make the model unstable and the results unreliable. A correlation matrix is the standard tool to check for this.

---

#### **What the R Script Does**

The `R/Lesson10.R` script performs the following:

1.  **Selects Numeric Variables:** It identifies and selects a set of numeric columns from the dataset, such as `Age`, `OS` (Overall Survival), and `Censor`.
2.  **Calculates the Correlation Matrix:** It computes the pairwise correlation coefficient for every combination of the selected numeric variables.
3.  **Prints the Matrix:** It displays the raw correlation matrix, with values ranging from -1 to +1.
4.  **Visualizes the Matrix:** It creates a **correlogram**, a visual representation of the correlation matrix, making it easy to spot strong relationships at a glance.

---

#### **Step-by-Step Analysis in `R/Lesson10.R`**

**1. Calculate and Print the Correlation Matrix**
*Clinical Question:* What is the strength and direction of the linear relationship between key numeric variables in our cohort?
```r
# First, select only the numeric columns of interest
numeric_cols <- c("Age", "OS", "Censor", "Chemo_status", "Radio_status")
numeric_data <- data %>%
  dplyr::select(dplyr::all_of(available_cols)) %>%
  stats::na.omit()

# Then, compute the correlation matrix
corr_matrix <- stats::cor(numeric_data)
print(round(corr_matrix, 3))
```

**2. Visualize the Correlation Matrix**
*Clinical Question:* How can we quickly visualize these correlations to identify the strongest relationships?
```r
# corrplot() creates an intuitive visualization of the matrix
corrplot::corrplot(
  corr_matrix,
  method = "circle",
  type = "upper",
  tl.col = "black",
  tl.srt = 45
)
```

---

#### **Key Clinical Insights & Interpretation**

*   **Interpreting the Correlation Coefficient (and the Plot):**
    *   **Value close to +1 (Strong Positive Correlation):** As one variable increases, the other tends to increase. (Represented by large, dark blue circles in the plot).
    *   **Value close to -1 (Strong Negative Correlation):** As one variable increases, the other tends to decrease. (Represented by large, dark red circles).
    *   **Value close to 0 (Weak/No Correlation):** There is no linear relationship between the variables. (Represented by small, pale circles or empty spaces).
*   **Expected Findings:** You should expect to see a strong negative correlation between `OS` (Overall Survival) and `Censor` (the event status, where 1=deceased). This makes perfect clinical sense: patients with longer survival times are less likely to have had the event (death) recorded during the study period.
*   **Checking for Multicollinearity:** Before building a regression model, you would look for very high correlations (e.g., > 0.8 or < -0.8) between your *predictor* variables. If found, you might consider including only one of them in the model to avoid issues.

---

#### **How to Run the Script**

To generate the correlation matrix and plot, run this command:

```bash
Rscript R/Lesson10.R
```

**Next:** In Lesson 11, we will learn how to compare a continuous variable across *more than two* groups using ANOVA.



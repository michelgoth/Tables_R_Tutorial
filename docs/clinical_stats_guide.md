# 🧬 Clinical Statistics Guide

> **Essential statistical concepts for clinical data analysis** 📊

This guide explains the key statistical concepts you'll encounter in the Clinical Data Analysis tutorial series. Use it as a reference while working through the lessons.

---

## 📈 Descriptive Statistics

### Measures of Central Tendency
- **Mean**: Average value (sensitive to outliers)
- **Median**: Middle value (robust to outliers)
- **Mode**: Most frequent value

### Measures of Dispersion
- **Standard Deviation**: Average distance from mean
- **Variance**: Square of standard deviation
- **Range**: Difference between max and min values
- **Interquartile Range (IQR)**: Range of middle 50% of data

### When to Use Each
- **Mean**: Normally distributed data, no outliers
- **Median**: Skewed data, presence of outliers
- **Mode**: Categorical data, identifying most common category

---

## 🔬 Hypothesis Testing

### Null vs Alternative Hypothesis
- **H₀ (Null)**: No effect/difference exists
- **H₁ (Alternative)**: Effect/difference exists

### P-Values
- **Definition**: Probability of observing data as extreme as what we saw, assuming H₀ is true
- **Interpretation**: 
  - p < 0.05: Reject H₀ (statistically significant)
  - p ≥ 0.05: Fail to reject H₀ (not statistically significant)
- **Warning**: p < 0.05 doesn't mean H₁ is true!

### Type I vs Type II Errors
- **Type I Error**: Reject H₀ when it's true (false positive)
- **Type II Error**: Fail to reject H₀ when it's false (false negative)
- **Power**: Probability of correctly rejecting H₀ (1 - Type II error rate)

---

## 📊 Categorical Data Analysis

### Chi-Square Test
**Use when:** Comparing categorical variables
**Assumptions:**
- Independent observations
- Expected cell counts ≥ 5
- Random sampling

**Interpretation:**
- χ² statistic measures deviation from expected
- Larger χ² = stronger evidence against H₀
- p-value indicates statistical significance

### Fisher's Exact Test
**Use when:** Small sample sizes or expected counts < 5
**Advantage:** No minimum expected count requirement
**Disadvantage:** Computationally intensive for large tables

### Odds Ratio (OR)
**Definition:** Ratio of odds of event in exposed vs unexposed
**Interpretation:**
- OR = 1: No association
- OR > 1: Positive association
- OR < 1: Negative association

---

## 📈 Continuous Data Analysis

### T-Test
**Types:**
- **One-sample**: Compare mean to known value
- **Two-sample independent**: Compare means between groups
- **Paired**: Compare means within same subjects

**Assumptions:**
- Normally distributed data
- Equal variances (for independent t-test)
- Independent observations

### Wilcoxon Test (Non-parametric)
**Use when:** Data not normally distributed
**Types:**
- **Wilcoxon signed-rank**: Paired data
- **Wilcoxon rank-sum (Mann-Whitney U)**: Independent groups

**Advantages:**
- No normality assumption
- Robust to outliers
- Works with ordinal data

### Effect Size
**Cohen's d:**
- Small: 0.2
- Medium: 0.5
- Large: 0.8

**Interpretation:** Practical significance, not just statistical

---

## ⏰ Survival Analysis

### Censoring
**Types:**
- **Right-censored**: Event hasn't occurred by end of study
- **Left-censored**: Event occurred before study start
- **Interval-censored**: Event occurred between two time points

### Kaplan-Meier Method
**Purpose:** Estimate survival function
**Assumptions:**
- Independent censoring
- Same survival probability for censored and uncensored subjects

**Output:**
- Survival curve
- Median survival time
- Survival probabilities at specific times

### Log-Rank Test
**Purpose:** Compare survival curves between groups
**Assumptions:**
- Independent observations
- Proportional hazards (simplified)

**Interpretation:**
- p < 0.05: Survival curves differ significantly
- p ≥ 0.05: No significant difference

### Cox Proportional Hazards Model
**Purpose:** Multivariable survival analysis
**Key Assumption:** Proportional hazards (hazard ratio constant over time)

**Output:**
- Hazard ratios (HR)
- Confidence intervals
- p-values for each predictor

**Hazard Ratio Interpretation:**
- HR = 1: No effect
- HR > 1: Increased risk
- HR < 1: Decreased risk

---

## 🎯 Regression Analysis

### Linear Regression
**Purpose:** Predict continuous outcome from predictors
**Assumptions:**
- Linear relationship
- Independent residuals
- Normally distributed residuals
- Homoscedasticity (constant variance)

**Output:**
- Regression coefficients
- R² (proportion of variance explained)
- p-values for coefficients

### Logistic Regression
**Purpose:** Predict binary outcome from predictors
**Assumptions:**
- Independent observations
- Linear relationship with logit
- No multicollinearity

**Output:**
- Odds ratios
- Confidence intervals
- Model fit statistics (AIC, BIC)

### Model Diagnostics
**Linear Regression:**
- Residual plots
- Q-Q plots
- Cook's distance

**Logistic Regression:**
- Hosmer-Lemeshow test
- ROC curve
- Classification table

---

## 🔗 Correlation Analysis

### Pearson Correlation
**Use when:** Both variables are continuous and normally distributed
**Range:** -1 to +1
**Interpretation:**
- ±0.1: Weak correlation
- ±0.3: Moderate correlation
- ±0.5: Strong correlation

### Spearman Correlation
**Use when:** Variables are ordinal or not normally distributed
**Advantage:** Robust to outliers and non-linear relationships

### Correlation vs Causation
**Important:** Correlation ≠ Causation!
- Correlation shows association only
- Causation requires additional evidence
- Consider confounding variables

---

## 📋 Sample Size Considerations

### Power Analysis
**Factors affecting power:**
- Sample size
- Effect size
- Significance level (α)
- Statistical test used

**General guidelines:**
- Larger sample = higher power
- Larger effect = easier to detect
- Lower α = lower power

### Effect Size Guidelines
**Cohen's conventions:**
- Small: 0.1 (correlation), 0.2 (t-test), 0.1 (chi-square)
- Medium: 0.3, 0.5, 0.3
- Large: 0.5, 0.8, 0.5

---

## 🚨 Common Pitfalls

### Multiple Testing
**Problem:** Increased Type I error with multiple comparisons
**Solutions:**
- Bonferroni correction
- False Discovery Rate (FDR)
- Pre-specified hypotheses

### P-Hacking
**Problem:** Data dredging to find significant results
**Solutions:**
- Pre-register hypotheses
- Use appropriate α levels
- Report all analyses conducted

### Overfitting
**Problem:** Model fits training data too well
**Solutions:**
- Cross-validation
- Holdout sample
- Regularization methods

### Missing Data
**Types:**
- **MCAR**: Missing completely at random
- **MAR**: Missing at random
- **MNAR**: Missing not at random

**Handling:**
- Complete case analysis
- Multiple imputation
- Sensitivity analysis

---

## 📚 Further Reading

### Books
- "Medical Statistics: A Textbook for the Health Sciences" by Bland & Altman
- "Survival Analysis: A Self-Learning Text" by Kleinbaum & Klein
- "Applied Logistic Regression" by Hosmer, Lemeshow, & Sturdivant

### Online Resources
- [StatQuest YouTube Channel](https://www.youtube.com/c/joshstarmer)
- [R-bloggers](https://www.r-bloggers.com/)
- [CRAN Task Views](https://cran.r-project.org/web/views/)

### Journals
- Statistics in Medicine
- BMC Medical Research Methodology
- Journal of Clinical Epidemiology

---

## 🎓 Key Takeaways

1. **Always check assumptions** before applying statistical tests
2. **Consider effect size** in addition to p-values
3. **Understand your data** before choosing methods
4. **Report results clearly** with appropriate confidence intervals
5. **Be transparent** about methods and limitations
6. **Consult with statisticians** for complex analyses

---

*Remember: Statistics is a tool to help answer clinical questions, not an end in itself! 🧬📊* 
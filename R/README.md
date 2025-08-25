# R Scripts Documentation

> Complete guide to the Clinical Data Analysis lessons

This folder contains all the R scripts for the Clinical Data Analysis tutorial series. Each lesson builds upon the previous one, creating a comprehensive, clinician-focused path aligned strictly to the provided dataset.

---

## Lesson Overview (1–17)

### [Lesson 1: Setup & Data Import](Lesson1.R)
Skills: Environment setup, data loading, basic visualization

### [Lesson 2: Descriptive Statistics](Lesson2.R)
Skills: Statistical summaries, distribution analysis

### [Lesson 3: Clinical Visualization](Lesson3.R)
Skills: Categorical visualization with ggplot2

### [Lesson 4: Kaplan–Meier Analysis](Lesson4.R)
Skills: Survival analysis, time-to-event data

### [Lesson 5: Log-Rank Testing](Lesson5.R)
Skills: Survival comparison, statistical testing

### [Lesson 6: Cox Regression](Lesson6.R)
Skills: Multivariable modeling, hazard ratios

### [Lesson 7: Association Testing](Lesson7.R)
Skills: Chi-square, Fisher’s exact; contingency tables

### [Lesson 8: Group Comparisons](Lesson8.R)
Skills: Wilcoxon/t-test; boxplots

### [Lesson 9: Logistic Regression](Lesson9.R)
Skills: Binary outcome modeling, odds ratios

### [Lesson 10: Correlation Analysis](Lesson10.R)
Skills: Correlation matrices, multicollinearity awareness

### [Lesson 11: ANOVA/MANOVA](Lesson11.R)
Skills: ANOVA, MANOVA, post-hoc tests, assumptions

### [Lesson 12: Clinical Survival Extensions](Lesson12.R)
Skills: Baseline, missingness, univariable HRs, risk tertiles, PH checks

### [Lesson 13: ML Basics (Feature Importance)](Lesson13.R)
Skills: Random Forest, importance visualization

### [Lesson 14: Joint Risk Groups (IDH × MGMT)](Lesson14.R)
Skills: Stratified KM, adjusted HRs by joint molecular groups

### [Lesson 15: TMZ × MGMT Interaction](Lesson15.R)
Skills: Interaction modeling, stratified KM

### [Lesson 16: Radiotherapy Adjusted Analysis](Lesson16.R)
Skills: Adjusted Cox with treatment term

### [Lesson 17: Parsimonious Prognostic Score](Lesson17.R)
Skills: Point-based score from Cox, KM by risk strata

---

## Getting Started

1. Install packages
```r
source("R/setup.R")
```
2. Run lessons (plots saved to `plots/`)
```r
source("R/Lesson1.R")
```

## Dataset
- See [Data/README.md](../Data/README.md) for variable documentation.

## Troubleshooting
- See [docs/](../docs/) for lesson explanations and clinical interpretation tips.

**Last updated:** 2025
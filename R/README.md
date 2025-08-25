# R Scripts Documentation

> Complete guide to the Clinical Data Analysis lessons

This folder contains all the R scripts for the Clinical Data Analysis tutorial series. Each lesson builds upon the previous one, creating a comprehensive learning path from basic data exploration to advanced statistical modeling aligned with the provided dataset.

---

## Lesson Overview

### [Lesson 1: Setup & Data Import](Lesson1.R)
**Duration:** 45 minutes  
**Skills:** Environment setup, data loading, basic visualization  
**Key Concepts:**
- Using `setup.R` to install packages
- Excel data import with `readxl`
- Data structure exploration
- Basic ggplot2 visualizations
- Practice with histograms and bar plots

**Prerequisites:** Run `source("R/setup.R")`  
**Next:** Lesson 2

---

### [Lesson 2: Descriptive Statistics](Lesson2.R)
**Duration:** 60 minutes  
**Skills:** Statistical summaries, distribution analysis  
**Key Concepts:**
- Summary statistics (mean, median, sd)
- Frequency tables and proportions
- Distribution visualization
- Data exploration techniques
- Practice with descriptive analysis

**Prerequisites:** Lesson 1  
**Next:** Lesson 3

---

### [Lesson 3: Clinical Visualization](Lesson3.R)
**Duration:** 75 minutes  
**Skills:** Advanced plotting, categorical analysis  
**Key Concepts:**
- Advanced ggplot2 techniques
- Categorical variable visualization
- Color schemes and themes
- Publication-ready plots
- Multi-panel visualizations

**Prerequisites:** Lesson 2  
**Next:** Lesson 4

---

### [Lesson 4: Kaplan-Meier Analysis](Lesson4.R)
**Duration:** 90 minutes  
**Skills:** Survival analysis, time-to-event data  
**Key Concepts:**
- Survival data structure
- Kaplan-Meier estimation
- Survival curve plotting
- Censoring concepts
- Median survival calculation

**Prerequisites:** Lesson 3  
**Next:** Lesson 5

---

### [Lesson 5: Log-Rank Testing](Lesson5.R)
**Duration:** 60 minutes  
**Skills:** Survival comparison, statistical testing  
**Key Concepts:**
- Log-rank test for survival comparison
- Multiple survival curves
- Statistical significance testing
- Hazard ratio interpretation
- Survival analysis reporting

**Prerequisites:** Lesson 4  
**Next:** Lesson 6

---

### [Lesson 6: Cox Regression](Lesson6.R)
**Duration:** 90 minutes  
**Skills:** Multivariable modeling, hazard ratios  
**Key Concepts:**
- Cox proportional hazards model
- Multivariable survival analysis
- Hazard ratio interpretation
- Model diagnostics
- Variable selection strategies

**Prerequisites:** Lesson 5  
**Next:** Lesson 7

---

### [Lesson 7: Association Testing](Lesson7.R)
**Duration:** 75 minutes  
**Skills:** Categorical analysis, contingency tables  
**Key Concepts:**
- Chi-square test for independence
- Fisher's exact test
- Contingency table analysis
- Odds ratio calculation
- Association strength interpretation

**Prerequisites:** Lesson 6  
**Next:** Lesson 8

---

### [Lesson 8: Group Comparisons](Lesson8.R)
**Duration:** 60 minutes  
**Skills:** Continuous variable testing, effect sizes  
**Key Concepts:**
- T-tests for mean comparison
- Wilcoxon tests for non-parametric data
- Effect size calculation
- Normality testing
- Multiple comparison correction

**Prerequisites:** Lesson 7  
**Next:** Lesson 9

---

### [Lesson 9: Logistic Regression](Lesson9.R)
**Duration:** 90 minutes  
**Skills:** Binary outcome modeling, odds ratios  
**Key Concepts:**
- Logistic regression for binary outcomes
- Odds ratio interpretation
- Model fit assessment
- Variable selection
- Prediction and classification

**Prerequisites:** Lesson 8  
**Next:** Lesson 10

---

### [Lesson 10: Correlation Analysis](Lesson10.R)
**Duration:** 60 minutes  
**Skills:** Correlation matrices, multicollinearity  
**Key Concepts:**
- Pearson and Spearman correlation
- Correlation matrix visualization
- Multicollinearity detection
- Correlation vs causation
- Variable relationship exploration

**Prerequisites:** Lesson 9  
**Next:** Lesson 11

---

### [Lesson 11: Multivariate Analysis (ANOVA/MANOVA)](Lesson11.R)
**Duration:** 90 minutes  
**Skills:** ANOVA, MANOVA, post-hoc tests  
**Key Concepts:**
- One-way and two-way ANOVA
- MANOVA with multiple dependent variables
- Tukey/Bonferroni post-hoc comparisons
- Assumption checks (normality, homogeneity)

**Prerequisites:** Lesson 10

---

## Getting Started

### Prerequisites
1. R (version 4.0 or higher)
2. RStudio (recommended)
3. Required packages (install using `setup.R`)

### Setup Instructions
1. Run the setup script:
   ```r
   source("R/setup.R")
   ```

2. Start with Lesson 1:
   ```r
   # Open Lesson1.R in RStudio
   # Follow along with comments
   # Complete practice tasks
   ```

3. Track your progress:
   - Use [progress_tracker.md](../progress_tracker.md)
   - Complete exercises in [exercises/](../exercises/)
   - Take notes on key concepts

---

## Dataset Information

### ClinicalData.xlsx
- Source: CGGA Consortium
- Patients: Clinical glioma patients
- Variables: Demographics, clinical features, molecular markers, survival
- Use: Educational purposes only

### Variable Descriptions
See [Data/README.md](../Data/README.md) for complete variable documentation.

---

## Getting Help

### Common Issues
- Package installation: see [troubleshooting guide](../docs/troubleshooting.md)
- Data import: check file paths and format
- Plot errors: verify variable names and data types

### Resources
- R Documentation: `?function_name`
- Online Help: Stack Overflow, RStudio Community
- Statistical Concepts: [Clinical Statistics Guide](../docs/clinical_stats_guide.md)

---

## Progress Tracking
- Use [progress_tracker.md](../progress_tracker.md)
- Mark completed lessons
- Record time spent
- Note key insights
- Set learning goals

---

## Certification

### Completion Requirements
- Complete all 11 lessons
- Finish practice exercises
- Demonstrate understanding through application
- Reflect on learning journey

### Skills Acquired
- Clinical data analysis
- Statistical modeling
- R programming
- Research methodology
- Data visualization

---

## Contributing

### Suggest Improvements
- Report issues with lessons
- Propose new topics
- Share additional resources
- Provide feedback on clarity

### Community
- Join discussions
- Share your projects
- Help other learners
- Contribute to documentation

---

**Last updated:** 2025  
**Version:** 1.1  
**Maintainer:** Dr.-Ing. Kevin Joseph
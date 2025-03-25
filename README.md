# Clinical Data Analysis in R: A Guided Learning Series

Welcome to the **Clinical Data Analysis in R** repository!  
This curated collection of R scripts is designed to help you build strong foundations in clinical and biomedical data analysis using the R programming language. This series provides a complete, structured learning path from basic visualization to multivariable modeling.

---

## What You'll Learn

By the end of this tutorial series, you’ll be able to:

- Set up your R environment and import clinical data
- Clean and prepare real-world datasets
- Explore and visualize distributions and relationships
- Perform survival analysis using Kaplan-Meier and log-rank tests
- Build multivariable Cox regression models
- Test associations with Chi-square and Fisher's Exact tests
- Compare continuous outcomes with Wilcoxon and t-tests
- Model binary outcomes with logistic regression
- Interpret correlation matrices for numeric features

---

## Lessons Overview

| Lesson | Topic | Description |
|--------|-------|-------------|
| **Lesson 1** | Setup & Data Import | Install required packages, load data, and understand structure |
| **Lesson 2** | Descriptive Statistics | Summarize and explore clinical data distributions |
| **Lesson 3** | Clinical Feature Visualization | Visualize categorical variables using `ggplot2` |
| **Lesson 4** | Kaplan-Meier Survival Analysis | Estimate and plot survival curves |
| **Lesson 5** | Log-Rank Test | Compare survival curves statistically |
| **Lesson 6** | Cox Regression Model | Build a multivariable model for survival prediction |
| **Lesson 7** | Association Testing | Explore categorical relationships (Chi-square & Fisher's) |
| **Lesson 8** | Comparing Groups | Use Wilcoxon/t-tests for continuous variable comparison |
| **Lesson 9** | Logistic Regression | Model binary outcomes using predictors |
| **Lesson 10** | Correlation Matrix | Visualize and interpret numeric correlations |

---

## How to Use

1. Clone or download this repository
2. Open each `LessonXX.R` script in RStudio or your R environment
3. Run each section line by line while reading the comments and completing practice tasks
4. Modify the code and experiment with your own questions and visualizations

---

## 📌 Requirements

- R (v4.0 or higher recommended)
- R packages: `readxl`, `ggplot2`, `dplyr`, `survival`, `survminer`, `ggpubr`, `corrplot`, `rstatix`, `car`, `psych`, etc.

You can install all necessary packages with:

```r
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", 
                       "survival", "survminer", "ggpubr", "corrplot", 
                       "rstatix", "car", "psych")
install.packages(setdiff(required_packages, rownames(installed.packages())))
```

---

## Learning Format

Each lesson includes:
	•	Concept explanations
	•	Commented code
	•	Practice tasks to reinforce learning
	•	Suggestions for customization

Spend around 30–60 minutes per lesson to get the most value — that’s a full 8–10 hour self-paced course!

---

# 📚 R Scripts Documentation

> **Complete guide to the Clinical Data Analysis lessons** 🧬

This folder contains all the R scripts for the Clinical Data Analysis tutorial series. Each lesson builds upon the previous one, creating a comprehensive learning path from basic data exploration to advanced statistical modeling.

---

## 📋 Lesson Overview

### [Lesson 1: Setup & Data Import](Lesson1.R)
**Duration:** 45 minutes  
**Skills:** Environment setup, data loading, basic visualization  
**Key Concepts:**
- Package installation and loading
- Excel data import with `readxl`
- Data structure exploration
- Basic ggplot2 visualizations
- Practice with histograms and bar plots

**Prerequisites:** None  
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
**Next:** Complete series

---

## Getting Started

### Prerequisites
1. **R** (version 4.0 or higher)
2. **RStudio** (recommended)
3. **Required packages** (install using `setup.R`)

### Setup Instructions
1. **Run the setup script:**
   ```r
   source("R/setup.R")
   ```

2. **Start with Lesson 1:**
   ```r
   # Open Lesson1.R in RStudio
   # Follow along with comments
   # Complete practice tasks
   ```

3. **Track your progress:**
   - Use [progress_tracker.md](../progress_tracker.md)
   - Complete exercises in [exercises/](../exercises/)
   - Take notes on key concepts

---

## How to Use Each Lesson

### Lesson Structure
Each lesson follows this format:

1. **Header Section**
   - Learning objectives
   - Prerequisites
   - Estimated duration

2. **Concept Introduction**
   - Background information
   - Statistical theory
   - Clinical relevance

3. **Code Sections**
   - Step-by-step implementation
   - Detailed comments
   - Best practices

4. **Practice Tasks**
   - Hands-on exercises
   - Real-world applications
   - Extension activities

5. **Summary**
   - Key takeaways
   - Common pitfalls
   - Next steps

### Learning Tips
- **Read comments carefully** - they explain the "why" behind the code
- **Run code line by line** - understand each step before moving on
- **Experiment with parameters** - change values to see effects
- **Complete practice tasks** - reinforce learning through application
- **Take notes** - document insights and questions

---

## Learning Paths

### Beginner Path (Recommended)
1. Complete lessons 1-3 for basic skills
2. Focus on understanding data exploration
3. Practice with visualization techniques
4. Build confidence with R syntax

### Intermediate Path
1. Complete lessons 1-6 for survival analysis
2. Focus on clinical interpretation
3. Practice with real clinical questions
4. Develop statistical reasoning

### Advanced Path
1. Complete all 10 lessons
2. Focus on model building and validation
3. Practice with complex clinical scenarios
4. Develop research methodology skills

---

## Practice Exercises

### Available Exercises
- [Exercise 1: Basic Analysis](../exercises/exercise_1_basic_analysis.md)
- More exercises coming soon...

### Exercise Benefits
- **Reinforce learning** through hands-on practice
- **Apply concepts** to real scenarios
- **Build confidence** with R programming
- **Develop problem-solving** skills

---

## Dataset Information

### ClinicalData.xlsx
- **Source:** CGGA Consortium
- **Patients:** Clinical glioma patients
- **Variables:** Demographics, clinical features, molecular markers, survival
- **Use:** Educational purposes only

### Variable Descriptions
See [Data/README.md](../Data/README.md) for complete variable documentation.

---

## Getting Help

### Common Issues
- **Package installation:** See [troubleshooting guide](../docs/troubleshooting.md)
- **Data import:** Check file paths and format
- **Plot errors:** Verify variable names and data types

### Resources
- **R Documentation:** `?function_name`
- **Online Help:** Stack Overflow, RStudio Community
- **Statistical Concepts:** [Clinical Statistics Guide](../docs/clinical_stats_guide.md)

---

## Progress Tracking

### Track Your Learning
- Use [progress_tracker.md](../progress_tracker.md)
- Mark completed lessons
- Record time spent
- Note key insights
- Set learning goals

### Assessment
- Complete practice tasks
- Answer reflection questions
- Apply skills to new datasets
- Share insights with others

---

## Certification

### Completion Requirements
- Complete all 10 lessons
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

## Additional Resources

### Books
- "R for Data Science" by Wickham & Grolemund
- "Medical Statistics" by Bland & Altman
- "Survival Analysis" by Kleinbaum & Klein

### Online Courses
- DataCamp R courses
- Coursera statistics courses
- edX data science programs

### Communities
- RStudio Community
- Stack Overflow R tag
- Reddit r/rstats

---

## Support

### Questions?
- Check the [troubleshooting guide](../docs/troubleshooting.md)
- Review lesson comments carefully
- Search online for R documentation
- Ask in R communities

### Feedback?
- Share your experience
- Suggest improvements
- Report technical issues
- Contribute to the community

---

*Happy learning! Remember, every expert was once a beginner.*

---

**Last updated:** 2024  
**Version:** 1.0  
**Maintainer:** Dr.-Ing. Kevin Joseph
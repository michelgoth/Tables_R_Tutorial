### Lesson 2 — Descriptive Statistics and Distributions

We now summarize key variables and visualize distribution differences by a clinically meaningful factor (gender). Quantifying center and spread helps set expectations for later modeling and stratification.

Clinical rationale: age structure and categorical counts (grade, IDH) influence prognosis and treatment decisions. Understanding them avoids misinterpretation downstream.

Preparation
```r
source("R/utils.R"); load_required_packages(c("readxl","ggplot2","dplyr"))
data <- load_clinical_data()
```

1) Summaries and counts
```r
summary(data$Age)                # Min/Max, quartiles
if ("Gender" %in% names(data)) table(data$Gender)
if ("Grade" %in% names(data))  table(data$Grade)
if ("IDH_mutation_status" %in% names(data)) table(data$IDH_mutation_status)
```
Report medians and counts, not just means, given skew typical in clinical variables.

2) Age distribution by gender
```r
df <- subset(data, !is.na(Age) & !is.na(Gender))
p <- ggplot(df, aes(x = Age, fill = Gender)) +
  geom_histogram(binwidth = 5, alpha = 0.6, position = "identity") +
  theme_minimal() +
  labs(title = "Age Distribution by Gender", x = "Age", y = "Count")
save_plot_both(p, "Lesson2_Age_by_Gender")
```

Reading the figure
- Look for shifted peaks suggesting different age profiles by gender.
- Check tails and potential outliers; these affect hazard estimates later.

Reproduce
```r
Rscript R/Lesson2.R
```

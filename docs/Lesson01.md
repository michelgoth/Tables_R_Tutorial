### Lesson 1 — Setup, Import, and First Clinical Plots

This first lesson gets you ready to work with the dataset and shows how to turn raw tables into immediately useful clinical views. You will load the data, inspect its structure, and produce three plots that describe the cohort at a glance.

Why this matters clinically: before modeling or testing, clinicians need a concise picture of the case‑mix (age, grade, sex, presentation type). These plots also surface obvious data issues (outliers, wrong encodings, missingness) early.

Before you begin
- Run the environment setup once per machine:
```r
source("R/setup.R")
```

What the script does
- Loads `ClinicalData.xlsx` through `load_clinical_data()` which standardizes names/types and converts literal "NA"/"Unknown" to true missing.
- Drops rows with missing values only for the variables used in each plot, keeping visuals clean and interpretable.
- Generates and saves three figures to `plots/`.

Step‑by‑step (already implemented in `R/Lesson1.R`)
1) Load and inspect
```r
source("R/utils.R")
load_required_packages(c("ggplot2","dplyr","tidyr","ggpubr","rstatix","readxl"))
data <- load_clinical_data()
str(data); summary(data)
```
2) Age distribution (cohort profile)
```r
p1 <- ggplot(data[!is.na(data$Age),], aes(x = Age)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "white") +
  labs(title = "Age Distribution", x = "Age (years)", y = "Count") +
  theme_minimal()
save_plot_both(p1, "Lesson1_Age_Distribution")
```
3) Grade by gender (case‑mix by sex)
```r
df <- subset(data, !is.na(Grade) & !is.na(Gender))
p2 <- ggplot(df, aes(x = Grade, fill = Gender)) +
  geom_bar(position = "dodge") +
  labs(title = "Tumor Grade by Gender", x = "Grade", y = "Count") +
  theme_minimal()
save_plot_both(p2, "Lesson1_Grade_by_Gender")
```
4) Grade composition within PRS type (presentation context)
```r
df <- subset(data, !is.na(PRS_type) & !is.na(Grade))
p3 <- ggplot(df, aes(x = PRS_type, fill = Grade)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Proportion of Grades within PRS Types", x = "PRS Type", y = "Proportion") +
  theme_minimal()
save_plot_both(p3, "Lesson1_Grades_within_PRS")
```

What you should see
- A right‑skewed age distribution typical for glioma cohorts.
- Grade counts by gender without an explicit “NA” bar.
- Grade composition differences between Primary, Recurrent, and Secondary presentations.

Reproduce quickly
```r
Rscript R/Lesson1.R
```
Next: continue with Lesson 2 to quantify distributions and counts in a more formal way.

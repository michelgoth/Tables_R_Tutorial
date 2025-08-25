### Lesson 3 — Clinical Feature Visualization (Categorical)

We examine relationships between categorical variables to understand case‑mix. Clear bar charts reveal pattern shifts that matter for interpretation and planning.

Clinical angle: grade distribution by presentation type (PRS) and IDH distribution by gender can indicate systematic differences in the cohort.

Preparation
```r
source("R/utils.R"); load_required_packages(c("readxl","ggplot2","dplyr"))
data <- load_clinical_data()
```

1) Grade across PRS type
```r
df <- subset(data, !is.na(Grade) & !is.na(PRS_type))
p1 <- ggplot(df, aes(x = Grade, fill = PRS_type)) +
  geom_bar(position = "dodge") +
  labs(title = "Tumor Grade by PRS Type", x = "Tumor Grade", y = "Count") +
  theme_minimal()
save_plot_both(p1, "Lesson3_Grade_by_PRS")
```
What to look for: does recurrent/secondary disease show a different grade mix than primary cases?

2) IDH by gender
```r
df <- subset(data, !is.na(IDH_mutation_status) & !is.na(Gender))
p2 <- ggplot(df, aes(x = IDH_mutation_status, fill = Gender)) +
  geom_bar(position = "dodge") +
  labs(title = "IDH Status by Gender", x = "IDH Mutation Status", y = "Count") +
  theme_minimal()
save_plot_both(p2, "Lesson3_IDH_by_Gender")
```
Interpretation: a clear imbalance might suggest sampling differences; not inferential on its own.

Reproduce
```r
Rscript R/Lesson3.R
```

### Lesson 7 — Association Tests (Chi‑square and Fisher)

Objective: Test whether two categorical variables are associated. We apply a Chi‑square test for IDH×Grade and Fisher’s exact test for Gender×MGMT when counts are small.

Clinical relevance: detects non‑random distributions (e.g., IDH status varying by grade), informing stratification and reporting.

Preparation
```r
source("R/utils.R"); load_required_packages(c("readxl","ggplot2"))
data <- load_clinical_data()
```

1) IDH × Grade (Chi‑square)
```r
tab <- table(subset(data, !is.na(IDH_mutation_status) & !is.na(Grade))[,c("IDH_mutation_status","Grade")])
chisq.test(tab)
# Plot saved as Lesson7_IDH_by_Grade
```
2) Gender × MGMT (Fisher’s exact)
```r
fisher.test(table(subset(data, !is.na(Gender) & !is.na(MGMTp_methylation_status))[,c("Gender","MGMTp_methylation_status")]))
```

Interpretation
- Report test, statistic, p‑value (and odds ratio for Fisher).
- Practical significance depends on effect size and clinical context.

Reproduce
```r
Rscript R/Lesson7.R
```



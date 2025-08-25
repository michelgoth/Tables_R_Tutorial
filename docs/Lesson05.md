### Lesson 5 — Log‑rank Test for Group Differences (MGMT or IDH)

Objective: Quantify whether survival curves differ between groups. We use the log‑rank test on MGMT methylation status (primary) or IDH status (fallback), then present the corresponding KM plot.

Clinical note: MGMT methylation often predicts benefit from alkylating chemotherapy. A fast, non‑parametric test provides a first pass at group separation.

Setup
```r
source("R/utils.R"); load_required_packages(c("survival","ggplot2","readxl"))
data <- load_clinical_data()
```

Procedure (implemented in `R/Lesson5.R`)
1) Build a survival object
```r
surv_obj <- Surv(data$OS, data$Censor)
```
2) Prefer MGMT if available and non‑missing
```r
df_mgmt <- subset(data, !is.na(OS) & !is.na(Censor) & !is.na(MGMTp_methylation_status))
if (nrow(df_mgmt) > 0) {
  test <- survdiff(Surv(OS, Censor) ~ MGMTp_methylation_status, data = df_mgmt)
  print(test)
  fit_km <- survfit(Surv(OS, Censor) ~ MGMTp_methylation_status, data = df_mgmt)
  # Plot saved as Lesson5_KM_by_MGMT
} else {
  # Fallback to IDH
  df_idh <- subset(data, !is.na(OS) & !is.na(Censor) & !is.na(IDH_mutation_status))
  test <- survdiff(Surv(OS, Censor) ~ IDH_mutation_status, data = df_idh)
  print(test)
  fit_km <- survfit(Surv(OS, Censor) ~ IDH_mutation_status, data = df_idh)
  # Plot saved as Lesson5_KM_by_IDH
}
```

Interpreting the output
- The chi‑square statistic and p‑value indicate whether survival curves differ overall.
- Inspect the KM figure to understand which group has longer survival and by how much.
- This test is unadjusted; proceed to Lesson 6 for adjusted effects with Cox regression.

Reproduce
```r
Rscript R/Lesson5.R
```

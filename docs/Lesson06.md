### Lesson 6 — Multivariable Cox Proportional Hazards

Aim: Estimate adjusted effects of routine clinical predictors on overall survival, reporting hazard ratios with confidence intervals.

Clinical relevance: quantifies how each factor shifts risk when considered together (e.g., IDH, grade, treatment variables), moving beyond unadjusted comparisons.

Preparation
```r
source("R/utils.R"); load_required_packages(c("survival","readxl","dplyr","ggplot2"))
data <- load_clinical_data()
```

Steps
1) Fit the Cox model (complete cases per variables used)
```r
cox_model <- coxph(Surv(OS, Censor) ~ Age + Gender + Grade + IDH_mutation_status +
                   MGMTp_methylation_status + PRS_type + Chemo_status + Radio_status,
                   data = data)
summary(cox_model)
```
2) Overall KM for cohort context
```r
km_fit <- survfit(Surv(OS, Censor) ~ 1)
# Saved as Lesson6_KM_Overall
```

Interpretation
- HR > 1 increases hazard (worse prognosis); HR < 1 decreases hazard.
- Focus on magnitude, confidence intervals, and plausibility, not just p‑values.
- Treatment variables capture association, not causation.

Reproduce
```r
Rscript R/Lesson6.R
```



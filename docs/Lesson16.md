### Lesson 16: Radiotherapy — Adjusted Survival Analysis

- Purpose: Assess association of radiotherapy with survival, adjusting for confounders.
- Data used: OS, Censor; Radio_status; optional Age, Grade, IDH_mutation_status, MGMTp_methylation_status.
- Methods: KM (RT vs No RT) for description; adjusted Cox with Radio_status term. NA removed; levels dropped.

#### Walkthrough
- Fit KM for RT vs No RT; interpret descriptive separation.
- Fit Cox: Surv(OS, Censor) ~ Radio + (Age + Grade + IDH + MGMT as available); plot RT HR.

#### Plots generated
- plots/Lesson16_KM_Radiotherapy.(png|pdf)
- plots/Lesson16_Forest_Radiotherapy_Adjusted.(png|pdf)

#### Clinical interpretation tips
- Treatment selection bias is likely; interpret adjusted association cautiously.
- Consider propensity or trial data for causal inference.

#### Reproduce
```r
Rscript R/Lesson16.R
```



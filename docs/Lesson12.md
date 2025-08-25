### Lesson 12: Clinician Survival Extensions

- Purpose: Provide a compact clinical profile: baseline table, missingness, univariable hazard ratios, risk stratification, and PH checks.
- Data used: OS, Censor, Age, Grade, IDH_mutation_status, MGMTp_methylation_status (as available).
- Methods: Descriptives; bar plot of missingness; individual Cox models; multivariable Cox with linear predictor tertiles; cox.zph PH tests. NA filtered per step.

#### Walkthrough
- Baseline: Counts for Gender, Grade, IDH, MGMT; summary(Age).
- Missingness: Column-wise NA counts plot.
- Univariable Cox: Per-variable HRs with 95% CI forest.
- Risk groups: Multivariable Cox → linear predictor tertiles → KM by risk.
- PH checks: Schoenfeld residual tests and plots.

#### Plots generated
- plots/Lesson12_Missingness_Profile.(png|pdf)
- plots/Lesson12_UniCox_Forest.(png|pdf)
- plots/Lesson12_KM_by_Risk.(png|pdf)
- plots/Lesson12_Cox_PH_Checks.(png|pdf)

#### Clinical interpretation tips
- Triage variables by univariable HR strength and clinical plausibility.
- Risk groups illustrate graded prognosis; confirm PH assumption.

#### Reproduce
```r
Rscript R/Lesson12.R
```



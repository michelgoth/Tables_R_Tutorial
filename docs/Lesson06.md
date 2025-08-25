### Lesson 6: Multivariable Cox Proportional Hazards

- Purpose: Estimate adjusted effects of routine clinical predictors on overall survival.
- Data used: OS, Censor; predictors Age, Gender, Grade, IDH_mutation_status, MGMTp_methylation_status, PRS_type, Chemo_status, Radio_status (as available).
- Methods: Cox model (hazard ratios) and overall KM curve; NA rows removed per analysis.

#### Walkthrough
- Fit: coxph(Surv(OS, Censor) ~ Age + Gender + Grade + IDH_mutation_status + MGMTp_methylation_status + PRS_type + Chemo_status + Radio_status, data).
- Output: HR, 95% CI, p-values; interpret HR>1 as higher hazard.
- Overall survival: survfit(Surv(OS, Censor) ~ 1) to display the cohort’s baseline survival.

#### Plot generated
- plots/Lesson6_KM_Overall.(png|pdf)

#### Clinical interpretation tips
- Age HR>1: higher risk per unit year; check magnitude and CI.
- IDH Wildtype vs Mutant: typically higher hazard; confirm direction.
- Treatment covariates (Chemo/Radio): reflect associations, not causation.

#### Reproduce
```r
Rscript R/Lesson6.R
```



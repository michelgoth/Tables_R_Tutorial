### Lesson 17: Parsimonious Prognostic Score

- Purpose: Derive a simple point-based score from a multivariable Cox model for bedside risk stratification.
- Data used: OS, Censor; predictors Age, Grade, IDH_mutation_status, MGMTp_methylation_status.
- Methods: Fit Cox, scale coefficients to integer points, compute patient score, define tertiles, and plot KM by risk. NA removed; levels dropped.

#### Walkthrough
- Model: Surv(OS, Censor) ~ Age + Grade + IDH + MGMT on complete cases.
- Points: Scale beta coefficients to integers; present a scorecard figure.
- Risk strata: Tertiles of total score → KM curves for Low/Medium/High risk.

#### Plots generated
- plots/Lesson17_Scorecard_Table.(png|pdf)
- plots/Lesson17_Score_KM_by_Tertile.(png|pdf)

#### Clinical interpretation tips
- Score is an interpretable summary of model risk; validate before clinical use.
- Check calibration and discrimination externally.

#### Reproduce
```r
Rscript R/Lesson17.R
```



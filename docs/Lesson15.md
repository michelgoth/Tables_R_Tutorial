### Lesson 15: Temozolomide (TMZ) Benefit and MGMT Interaction

- Purpose: Evaluate association between TMZ and survival, and whether MGMT modifies this effect.
- Data used: OS, Censor; Chemo_status (TMZ vs No TMZ), MGMTp_methylation_status; optional Age, Grade.
- Methods: KM within MGMT strata (TMZ vs No TMZ); Cox with Chemo × MGMT interaction adjusted for key covariates. NA removed; levels dropped.

#### Walkthrough
- Stratify by MGMT; for each stratum, fit KM comparing TMZ vs No TMZ.
- Fit Cox: Surv(OS, Censor) ~ Chemo × MGMT (+ Age + Grade if available); plot main and interaction HRs.

#### Plots generated
- plots/Lesson15_KM_Treatment_by_MGMT_<level>.(png|pdf)
- plots/Lesson15_Forest_Treatment_Interaction.(png|pdf)

#### Clinical interpretation tips
- Expect greater TMZ association in methylated MGMT; interaction quantifies effect modification.
- Observational association; not causal without randomization.

#### Reproduce
```r
Rscript R/Lesson15.R
```



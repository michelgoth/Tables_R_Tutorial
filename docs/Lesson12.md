### Lesson 12 — Clinical Survival Extensions (Table, Missingness, HRs, Risk, PH)

This lesson packages a compact clinical profile into five parts: baseline characteristics, missingness profile, univariable hazard ratios, risk stratification from a multivariable Cox model, and proportional hazards checks.

Why this matters: teams often need a one‑pager that summarizes cohort mix, data quality, key univariable signals, an adjusted risk view, and whether model assumptions are acceptable.

Steps (implemented in `R/Lesson12.R`)
1) Baseline table
- Counts for Gender, Grade, IDH, MGMT; summary(Age). This provides case‑mix context for all downstream results.

2) Missingness profile
```r
miss_df <- data.frame(Variable = names(data), Missing = sapply(data, function(x) sum(is.na(x))))
# Bar plot saved as Lesson12_Missingness_Profile
```
Use this to justify complete‑case counts in models and to guide imputation strategies if needed.

3) Univariable Cox HRs
- For each candidate variable, fit `coxph(Surv(OS,Censor) ~ variable)` on non‑missing rows and collect HRs with 95% CIs.
- Forest plot saved as `Lesson12_UniCox_Forest`.

4) Risk stratification from multivariable Cox
```r
vars <- c("Age","Grade","IDH_mutation_status","MGMTp_methylation_status")
cc <- complete.cases(data[,vars]) & !is.na(data$OS) & !is.na(data$Censor)
mv_df <- droplevels(data[cc, vars])
fit <- coxph(Surv(OS,Censor) ~ Age + Grade + IDH_mutation_status + MGMTp_methylation_status, data = data[cc,])
lp <- as.numeric(predict(fit, type = "lp"))
# Tertiles of linear predictor → KM by Low/Medium/High risk (Lesson12_KM_by_Risk)
```
This provides an interpretable, graded risk picture based on jointly modeled variables.

5) PH assumption checks
```r
zph <- cox.zph(fit)
# Plots saved as Lesson12_Cox_PH_Checks
```
Review global and per‑term p‑values; strong deviations suggest time‑varying effects or need for stratification.

Reproduce
```r
Rscript R/Lesson12.R
```



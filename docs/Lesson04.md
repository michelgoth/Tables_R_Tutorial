### Lesson 4 — Kaplan–Meier Survival by IDH

Goal: Visualize and compare overall survival between IDH mutation groups using Kaplan–Meier curves. This answers a fundamental clinical question: do IDH mutant and wildtype tumors show different survival profiles in this cohort?

Clinical note: IDH mutation is a strong prognostic marker in glioma. Clean, stratified KM curves help clinicians assess magnitude and direction of separation.

Preparation
```r
source("R/utils.R"); load_required_packages(c("survival","ggplot2","readxl"))
data <- load_clinical_data()
```

Steps implemented in `R/Lesson4.R`
1) Build a survival object with clean data
```r
df <- subset(data, !is.na(OS) & !is.na(Censor) & !is.na(IDH_mutation_status))
surv_obj <- Surv(time = as.numeric(df$OS), event = df$Censor)
```
2) Fit KM by IDH status
```r
fit_idh <- survfit(surv_obj ~ IDH_mutation_status, data = df)
```
3) Plot and save
```r
ensure_plots_dir()
png(file.path("plots","Lesson4_KM_by_IDH.png"), width = 1200, height = 900, res = 150)
plot(fit_idh, xlab = "Time (days)", ylab = "Survival Probability", col = 1:3, lwd = 2,
     main = "Survival by IDH Mutation Status")
legend("topright", legend = levels(df$IDH_mutation_status), col = 1:3, lwd = 2)
dev.off()
```
(An identical PDF is saved.)

Reading the figure
- Curves that separate and stay apart suggest different hazards between groups.
- Median survival (where S(t)=0.5) gives a concrete reference point if visible.
- Small strata may produce unstable curves with wide implied uncertainty.

Reproduce
```r
Rscript R/Lesson4.R
```
Next: Lesson 5 formally tests the difference using a log‑rank test.

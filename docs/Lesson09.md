### Lesson 9 — Logistic Regression (Binary Outcome)

Purpose: Model the probability of a binary outcome (here, IDH Wildtype vs Mutant) using routine predictors, and visualize coefficient directions.

Clinical use: Odds ratios quantify how age, grade, and MGMT relate to IDH status. While not causal, this helps understand co‑occurrence patterns.

Preparation
```r
source("R/utils.R"); load_required_packages(c("readxl","ggplot2"))
data <- load_clinical_data()
```

1) Define a clean binary outcome
```r
d2 <- subset(data, !is.na(IDH_mutation_status) & IDH_mutation_status %in% c("Mutant","Wildtype"))
d2$IDH_mutation_status <- droplevels(d2$IDH_mutation_status)
```
2) Fit the logistic model
```r
model <- glm(IDH_mutation_status ~ Age + Gender + Grade + MGMTp_methylation_status,
             data = d2, family = "binomial")
summary(model)
```
3) Coefficient plot
```r
coefs <- coef(summary(model))
coefs_df <- data.frame(Term = rownames(coefs), Estimate = coefs[,"Estimate"]) 
coefs_df <- subset(coefs_df, Term != "(Intercept)")
p <- ggplot(coefs_df, aes(x = reorder(Term, Estimate), y = Estimate)) +
  geom_col(fill = "steelblue") + coord_flip() +
  labs(title = "Logistic Regression Coefficients", x = "Term", y = "Estimate (log-odds)") +
  clinical_theme()
save_plot_both(p, "Lesson9_Logistic_Coefficients")
```

Interpretation
- Positive coefficients increase log‑odds of the reference outcome. Check factor coding before directional claims.
- Focus on sign, size, and uncertainty; relate to clinical plausibility.

Reproduce
```r
Rscript R/Lesson9.R
```



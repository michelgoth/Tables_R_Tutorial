### Lesson 8: Comparing Continuous Variables Across Groups

- Purpose: Compare central tendency across clinical groups using non-parametric tests.
- Data used: Age with IDH_mutation_status; OS with MGMTp_methylation_status; fallback Age by Grade.
- Methods: Wilcoxon rank-sum (or t-test if appropriate). NA rows removed; factor levels dropped.

#### Walkthrough
- Age ~ IDH: wilcox.test() if IDH has two levels.
- OS ~ MGMT: wilcox.test() if MGMT has two levels.
- Plots: Boxplots of OS by MGMT, or Age by Grade if MGMT view not available.

#### Plots generated
- plots/Lesson8_OS_by_MGMT.(png|pdf) or plots/Lesson8_Age_by_Grade.(png|pdf)

#### Clinical interpretation tips
- Median differences matter clinically; report IQRs.
- Non-parametric tests are robust with skewed clinical data.

#### Reproduce
```r
Rscript R/Lesson8.R
```



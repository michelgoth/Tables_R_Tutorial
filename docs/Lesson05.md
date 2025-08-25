### Lesson 5: Log-rank Test (MGMT or IDH)

- Purpose: Formally test survival differences between groups.
- Data used: OS, Censor with either MGMTp_methylation_status or IDH_mutation_status.
- Methods: survdiff log-rank; KM plot for the tested factor; NA dropped per analysis.

#### Walkthrough
- Primary: Test OS~MGMTp_methylation_status; print chi-square and p-value.
- Fallback: If MGMT unavailable, test OS~IDH_mutation_status.
- Save the corresponding KM plot.

#### Plots generated
- plots/Lesson5_KM_by_MGMT.(png|pdf) or plots/Lesson5_KM_by_IDH.(png|pdf)

#### Clinical interpretation tips
- p<0.05 suggests survival distributions differ; inspect KM curves to understand direction and magnitude.
- Ensure groups are clinically meaningful and of adequate size.

#### Reproduce
```r
Rscript R/Lesson5.R
```

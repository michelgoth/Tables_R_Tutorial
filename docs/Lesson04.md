### Lesson 4: Kaplan–Meier Survival by IDH Status

- Purpose: Compare overall survival between IDH mutation groups.
- Data used: OS (days), Censor (0=alive,1=dead), IDH_mutation_status.
- Methods: survfit Kaplan–Meier by IDH; NA rows removed for OS/Censor/IDH.

#### Walkthrough
- Create Surv(OS, Censor) and fit KM curves stratified by IDH_mutation_status.
- Save plots using base R to avoid extra dependencies.

#### Plot generated
- plots/Lesson4_KM_by_IDH.(png|pdf)

#### Clinical interpretation tips
- Curves separated imply survival differences by IDH; formal testing comes in Lesson 5.
- Watch for small strata; wide CIs and unstable estimates can occur.

#### Reproduce
```r
Rscript R/Lesson4.R
```

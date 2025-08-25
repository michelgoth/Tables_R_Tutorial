### Lesson 14: Joint Risk Groups — IDH × MGMT

- Purpose: Assess prognosis across combined molecular groups.
- Data used: OS, Censor; IDH_mutation_status; MGMTp_methylation_status.
- Methods: Joint groups from IDH (Mutant/Wildtype) and MGMT (methylated/un-methylated); KM by joint group; adjusted Cox with group as factor. NA removed; levels dropped.

#### Walkthrough
- Create four joint groups and fit KM curves to visualize separation.
- Fit an adjusted Cox model (optionally adjusting for Age, Grade) and plot HRs for groups.

#### Plots generated
- plots/Lesson14_KM_by_IDH_MGMT.(png|pdf)
- plots/Lesson14_Forest_IDH_MGMT.(png|pdf)

#### Clinical interpretation tips
- IDH Mutant + MGMT methylated often has best prognosis; contrast with Wildtype + un-methylated.
- Report adjusted HRs alongside KM visuals.

#### Reproduce
```r
Rscript R/Lesson14.R
```



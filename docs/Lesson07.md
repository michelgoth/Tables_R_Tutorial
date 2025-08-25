### Lesson 7: Association Tests (Chi-square and Fisher)

- Purpose: Test association between two categorical clinical variables.
- Data used: IDH_mutation_status, Grade; Gender, MGMTp_methylation_status.
- Methods: Chi-square test for IDH×Grade; Fisher’s exact for Gender×MGMT. NA rows removed and levels dropped.

#### Walkthrough
- Table IDH×Grade and apply chisq.test(); report X², df, p-value.
- Table Gender×MGMT and apply fisher.test(); report odds ratio and CI.
- Bar plot: IDH by Grade to visualize group counts.

#### Plot generated
- plots/Lesson7_IDH_by_Grade.(png|pdf)

#### Clinical interpretation tips
- Significant association suggests non-random distribution across categories (e.g., IDH distribution differs by grade).
- Fisher’s exact is preferred when expected counts are small.

#### Reproduce
```r
Rscript R/Lesson7.R
```



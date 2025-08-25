### Lesson 11: ANOVA/MANOVA for Group Comparisons

- Purpose: Test mean differences across groups and multiple outcomes.
- Data used: OS (and Age) by Grade; optional Gender for two-way ANOVA.
- Methods: One-way ANOVA (OS ~ Grade), two-way ANOVA (OS ~ Grade*Gender), MANOVA for (Age, OS) ~ Grade. NA rows removed; levels dropped.

#### Walkthrough
- One-way ANOVA: report F and p for grade effect; save OS-by-Grade boxplot.
- Two-way ANOVA: test interaction Grade×Gender and interpret.
- MANOVA: assess multivariate differences, then per-outcome ANOVAs.

#### Plot generated
- plots/Lesson11_OS_by_Grade.(png|pdf)

#### Clinical interpretation tips
- Highly significant grade effects on OS are expected; check effect sizes and assumptions.
- Interaction absence suggests additive effects of Grade and Gender.

#### Reproduce
```r
Rscript R/Lesson11.R
```



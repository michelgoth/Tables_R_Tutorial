### Lesson 9: Logistic Regression (Binary Outcome)

- Purpose: Model probability of a binary outcome (e.g., IDH Wildtype vs Mutant) using common predictors.
- Data used: IDH_mutation_status (binary after filtering), Age, Gender, Grade, MGMTp_methylation_status.
- Methods: GLM with binomial family; NA rows removed and outcome made binary; coefficient bar plot.

#### Walkthrough
- Filter to IDH ∈ {Mutant, Wildtype}; fit glm(IDH ~ Age + Gender + Grade + MGMT, family='binomial').
- Inspect coefficients (log-odds) and p-values; generate coefficient plot.

#### Plot generated
- plots/Lesson9_Logistic_Coefficients.(png|pdf)

#### Clinical interpretation tips
- Positive coefficient increases odds of Wildtype (if coded as reference); interpret after checking coding.
- Consider clinical plausibility and potential confounding.

#### Reproduce
```r
Rscript R/Lesson9.R
```



### Lesson 10: Correlation Among Numeric Clinical Variables

- Purpose: Identify linear relationships among core numeric variables.
- Data used: Age, OS, Censor, Chemo_status, Radio_status (numeric encoding).
- Methods: Correlation matrix with corrplot; NA rows removed across selected columns.

#### Walkthrough
- Select available numeric columns; compute cor() and display rounded matrix.
- Visualize upper triangle with corrplot (circles), saved to files.

#### Plot generated
- plots/Lesson10_Correlation_Matrix.(png|pdf)

#### Clinical interpretation tips
- Moderate/strong correlations inform multicollinearity in models and clinical co-occurrence.
- Censor is an event indicator; negative correlation with OS is expected.

#### Reproduce
```r
Rscript R/Lesson10.R
```



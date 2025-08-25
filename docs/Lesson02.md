### Lesson 2: Descriptive Statistics and Distributions

- Purpose: Summarize key variables and visualize distribution differences by a clinically relevant factor.
- Data used: Age, Gender plus categorical counts (Grade, IDH_mutation_status).
- Methods: Summary statistics and an age histogram stratified by gender; NA rows dropped per variable.

#### Walkthrough
- Load via load_clinical_data(); inspect summary(Age) and count tables for Gender, Grade, IDH_mutation_status.
- Plot (Age by Gender): Overlaid histograms (binwidth 5 years) with transparency to compare age distributions.

#### Plot generated
- plots/Lesson2_Age_by_Gender.(png|pdf)

#### Clinical interpretation tips
- Overlapping distributions: Look for age shifts between genders that might influence downstream survival or treatment choices.
- Counts for grade and IDH: Establish baseline prevalence for later comparative analyses.

#### Reproduce
```r
Rscript R/Lesson2.R
```

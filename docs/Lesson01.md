### Lesson 1: Setup, Import, and First Clinical Plots

- Purpose: Ensure the environment is ready, load the dataset, and produce first descriptive plots that clinicians can read quickly.
- Data used: Age, Grade, Gender, PRS_type from Data/ClinicalData.xlsx (standardized via R/utils.R).
- Methods: Simple summaries plus three plots using ggplot2 with NA rows removed for the variables in each figure.

#### Walkthrough
- Setup: source('R/utils.R'); load_required_packages(c('ggplot2','dplyr','tidyr','ggpubr','rstatix','readxl')).
- Load: data <- load_clinical_data(); this standardizes names, types, and converts literal "NA"/"Unknown" to true missing values.
- Inspect: str(data), summary(data) to understand columns and ranges.
- Plot 1 (Age distribution): Histogram of Age to understand the patient age spectrum.
- Plot 2 (Grade by Gender): Grouped bar plot to see grade mix across genders.
- Plot 3 (Proportion of Grades within PRS type): Stacked proportional bars to visualize grade composition by primary/recurrent/secondary.

#### Plots generated
- plots/Lesson1_Age_Distribution.(png|pdf)
- plots/Lesson1_Grade_by_Gender.(png|pdf)
- plots/Lesson1_Grades_within_PRS.(png|pdf)

#### Clinical interpretation tips
- Age: Skew, medians, and tails indicate typical referral population; flag extreme ages.
- Grade by Gender: Checks for obvious imbalances; not inferential here, just context.
- Grade mix by PRS type: Recurrent tumors often show different grade composition than primary; this provides quick situational awareness.

#### Reproduce
```r
Rscript R/Lesson1.R
```

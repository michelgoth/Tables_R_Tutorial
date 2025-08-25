### Lesson 13: Machine Learning Basics for Clinical Prediction

- Purpose: Demonstrate simple predictive workflows and feature importance using internal data.
- Data used: Derived 1-year survival outcome from OS/Censor; features Age, Gender, Grade, IDH_mutation_status, MGMTp_methylation_status, PRS_type.
- Methods: Random Forest with importance plot; optional SVM/Decision Tree and cross-validation (see script). NA handled per model step.

#### Walkthrough
- Create binary outcome for 1-year survival (approximation from OS and Censor).
- Fit Random Forest; report feature importance; show importance bar plot.
- (Optional) Train/test split and CV to compare algorithms.

#### Plot generated
- plots/Lesson13_RF_Feature_Importance.(png|pdf)

#### Clinical interpretation tips
- Importance highlights influential variables; treat as hypothesis-generating.
- Do not over-interpret single-cohort ML metrics; external validation is needed.

#### Reproduce
```r
Rscript R/Lesson13.R
```



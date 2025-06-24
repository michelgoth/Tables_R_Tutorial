# Advanced Clinical Data Analysis Exercises

## Table of Contents
1. [Multivariate Analysis Exercises](#multivariate-analysis-exercises)
2. [Competing Risks Exercises](#competing-risks-exercises)
3. [Machine Learning Exercises](#machine-learning-exercises)
4. [Longitudinal Analysis Exercises](#longitudinal-analysis-exercises)
5. [Meta-Analysis Exercises](#meta-analysis-exercises)
6. [Integration Projects](#integration-projects)

## Multivariate Analysis Exercises

### Exercise 1: ANOVA and Post-Hoc Analysis
**Objective**: Perform one-way and two-way ANOVA with appropriate post-hoc tests.

**Dataset**: Use the clinical data with survival time (OS) and tumor grade.

**Tasks**:
1. Perform one-way ANOVA comparing survival time across tumor grades
2. Calculate and interpret effect size (eta-squared)
3. Conduct Tukey's HSD post-hoc test
4. Perform two-way ANOVA with Grade × Gender interaction
5. Create publication-ready plots with error bars

**Expected Output**:
- ANOVA table with F-statistics and p-values
- Effect size interpretation
- Post-hoc comparison results
- Interaction plot

**Code Template**:
```r
# One-way ANOVA
anova_result <- aov(OS ~ Grade, data = clinical_data)
summary(anova_result)

# Effect size calculation
ss_total <- sum((clinical_data$OS - mean(clinical_data$OS, na.rm = TRUE))^2, na.rm = TRUE)
ss_between <- sum(anova_result$effects[2:length(anova_result$effects)]^2)
eta_squared <- ss_between / ss_total

# Post-hoc analysis
tukey_result <- TukeyHSD(anova_result)
```

### Exercise 2: MANOVA Analysis
**Objective**: Analyze multiple outcomes simultaneously using MANOVA.

**Dataset**: Use Age and OS as dependent variables, Grade as independent variable.

**Tasks**:
1. Perform MANOVA with Age and OS as dependent variables
2. Test MANOVA assumptions (multivariate normality, homogeneity of covariance)
3. Conduct follow-up univariate ANOVAs
4. Create profile plots for the outcomes
5. Interpret results in clinical context

**Expected Output**:
- MANOVA results (Wilks' lambda, Pillai's trace)
- Assumption test results
- Univariate ANOVA results
- Profile plot

## Competing Risks Exercises

### Exercise 3: Cumulative Incidence Function
**Objective**: Calculate and interpret cumulative incidence functions for competing events.

**Dataset**: Create competing risks scenario with disease progression and death from other causes.

**Tasks**:
1. Create competing risks dataset with two event types
2. Calculate cumulative incidence functions for each event type
3. Compare CIF with traditional Kaplan-Meier estimates
4. Perform Fine-Gray regression for one event type
5. Create stacked cumulative incidence plot

**Expected Output**:
- CIF estimates at key time points
- Comparison table (CIF vs. KM)
- Fine-Gray regression results
- Stacked plot

**Code Template**:
```r
# Create competing risks data
library(cmprsk)
cif_result <- crr(ftime = time, fstatus = event_type)

# Fine-Gray regression
fg_model <- crr(ftime = time, fstatus = event_type, cov1 = covariates)
```

### Exercise 4: Multi-State Models
**Objective**: Analyze transitions between different clinical states.

**Dataset**: Create multi-state data with states: Alive → Progression → Death.

**Tasks**:
1. Set up multi-state model structure
2. Calculate transition probabilities
3. Analyze covariates affecting transitions
4. Create transition diagram
5. Compare with competing risks approach

**Expected Output**:
- Transition probability matrix
- Covariate effects on transitions
- Multi-state plot
- Model comparison

## Machine Learning Exercises

### Exercise 5: Random Forest for Survival Prediction
**Objective**: Build and evaluate Random Forest model for survival prediction.

**Dataset**: Use clinical data with survival outcome and multiple predictors.

**Tasks**:
1. Prepare data for machine learning (handle missing values, encode categorical variables)
2. Split data into training and testing sets
3. Train Random Forest model for survival prediction
4. Evaluate model performance (C-index, time-dependent AUC)
5. Analyze feature importance
6. Create survival prediction plots

**Expected Output**:
- Model performance metrics
- Feature importance plot
- Survival prediction curves
- Cross-validation results

**Code Template**:
```r
library(randomForest)
library(survival)

# Prepare data
ml_data <- prepare_ml_data(clinical_data)

# Train model
rf_model <- randomForest(Surv(time, status) ~ ., data = training_data, ntree = 500)

# Evaluate performance
predictions <- predict(rf_model, test_data)
c_index <- survcomp::concordance.index(predictions, test_data$time, test_data$status)
```

### Exercise 6: Ensemble Methods
**Objective**: Compare multiple machine learning algorithms and create ensemble predictions.

**Dataset**: Use the same survival prediction dataset.

**Tasks**:
1. Train multiple models (Random Forest, SVM, Neural Network, Cox Regression)
2. Perform cross-validation for each model
3. Create ensemble predictions (voting, stacking)
4. Compare individual vs. ensemble performance
5. Analyze model agreement and disagreement

**Expected Output**:
- Performance comparison table
- Ensemble prediction results
- Model agreement analysis
- Ensemble vs. individual model plots

### Exercise 7: Feature Selection and Dimensionality Reduction
**Objective**: Apply feature selection methods to identify important predictors.

**Tasks**:
1. Perform univariate feature selection
2. Apply recursive feature elimination
3. Use LASSO regression for feature selection
4. Compare selected features across methods
5. Build models with selected features only

**Expected Output**:
- Feature selection results
- Comparison of selection methods
- Model performance with selected features
- Feature importance rankings

## Longitudinal Analysis Exercises

### Exercise 8: Linear Mixed-Effects Models
**Objective**: Analyze repeated measures data using mixed-effects models.

**Dataset**: Create longitudinal dataset with repeated quality of life measurements.

**Tasks**:
1. Set up longitudinal data structure
2. Fit linear mixed-effects model with random intercepts and slopes
3. Test different correlation structures
4. Analyze treatment effects over time
5. Create individual and population prediction plots

**Expected Output**:
- Mixed-effects model results
- Correlation structure comparison
- Treatment effect estimates
- Individual trajectory plots

**Code Template**:
```r
library(lme4)
library(lmerTest)

# Fit mixed-effects model
lmm_model <- lmer(qol_score ~ time * treatment + (1 + time | patient_id), data = long_data)

# Model diagnostics
plot(lmm_model)
qqnorm(resid(lmm_model))
```

### Exercise 9: Missing Data Analysis
**Objective**: Handle missing data in longitudinal studies.

**Tasks**:
1. Analyze missing data patterns
2. Implement multiple imputation
3. Compare complete case vs. imputed analyses
4. Perform sensitivity analysis
5. Report missing data handling

**Expected Output**:
- Missing data summary
- Imputation diagnostics
- Comparison of analysis methods
- Sensitivity analysis results

### Exercise 10: Growth Curve Analysis
**Objective**: Model individual growth trajectories and identify trajectory groups.

**Tasks**:
1. Fit growth curve models
2. Identify trajectory groups using latent class analysis
3. Analyze predictors of trajectory membership
4. Create trajectory plots
5. Compare outcomes across trajectory groups

**Expected Output**:
- Growth curve model results
- Trajectory group assignments
- Predictor analysis results
- Trajectory visualization

## Meta-Analysis Exercises

### Exercise 11: Fixed and Random Effects Meta-Analysis
**Objective**: Perform comprehensive meta-analysis of clinical studies.

**Dataset**: Create simulated dataset of multiple clinical trials.

**Tasks**:
1. Perform fixed effects meta-analysis
2. Assess heterogeneity (Q statistic, I-squared)
3. Perform random effects meta-analysis
4. Compare fixed vs. random effects results
5. Create forest plot

**Expected Output**:
- Meta-analysis results table
- Heterogeneity statistics
- Forest plot
- Fixed vs. random effects comparison

**Code Template**:
```r
library(meta)

# Fixed effects meta-analysis
fixed_ma <- metacont(n.e, mean.e, sd.e, n.c, mean.c, sd.c, data = studies)

# Random effects meta-analysis
random_ma <- metacont(n.e, mean.e, sd.e, n.c, mean.c, sd.c, data = studies, method = "DL")

# Forest plot
forest(random_ma)
```

### Exercise 12: Publication Bias Assessment
**Objective**: Assess and handle publication bias in meta-analysis.

**Tasks**:
1. Create funnel plot
2. Perform Egger's test for publication bias
3. Apply trim and fill method
4. Compare original vs. adjusted results
5. Perform sensitivity analysis

**Expected Output**:
- Funnel plot
- Publication bias test results
- Trim and fill analysis
- Sensitivity analysis results

### Exercise 13: Subgroup and Meta-Regression Analysis
**Objective**: Explore sources of heterogeneity through subgroup analysis.

**Tasks**:
1. Perform subgroup analysis by study characteristics
2. Conduct meta-regression analysis
3. Test for subgroup differences
4. Create subgroup forest plots
5. Interpret clinical implications

**Expected Output**:
- Subgroup analysis results
- Meta-regression coefficients
- Subgroup difference tests
- Subgroup forest plots

## Integration Projects

### Project 1: Comprehensive Clinical Prediction Model
**Objective**: Build an end-to-end clinical prediction system.

**Tasks**:
1. **Data Preparation**: Clean, validate, and prepare clinical data
2. **Exploratory Analysis**: Comprehensive data exploration and visualization
3. **Feature Engineering**: Create new variables and select features
4. **Model Development**: Train multiple prediction models
5. **Model Validation**: Internal and external validation
6. **Clinical Implementation**: Create clinical decision support tool
7. **Documentation**: Comprehensive report and code documentation

**Deliverables**:
- Clean, documented dataset
- Exploratory analysis report
- Trained prediction models
- Validation results
- Interactive prediction tool
- Comprehensive documentation

### Project 2: Systematic Review and Meta-Analysis
**Objective**: Conduct a complete systematic review with meta-analysis.

**Tasks**:
1. **Protocol Development**: Define research question and methods
2. **Literature Search**: Comprehensive database searches
3. **Study Selection**: Apply inclusion/exclusion criteria
4. **Data Extraction**: Extract relevant data from studies
5. **Quality Assessment**: Assess risk of bias
6. **Meta-Analysis**: Perform statistical synthesis
7. **Reporting**: Write systematic review report

**Deliverables**:
- Systematic review protocol
- Literature search strategy
- Study selection flowchart
- Data extraction forms
- Quality assessment results
- Meta-analysis results
- Systematic review report

### Project 3: Longitudinal Clinical Study Analysis
**Objective**: Analyze a complete longitudinal clinical study.

**Tasks**:
1. **Study Design**: Design longitudinal study protocol
2. **Data Collection**: Simulate longitudinal data collection
3. **Data Management**: Handle missing data and data quality issues
4. **Statistical Analysis**: Apply appropriate longitudinal methods
5. **Visualization**: Create comprehensive visualizations
6. **Interpretation**: Clinical interpretation of results
7. **Reporting**: Write clinical study report

**Deliverables**:
- Study protocol
- Longitudinal dataset
- Statistical analysis results
- Comprehensive visualizations
- Clinical interpretation
- Study report

## Assessment Criteria

### Technical Skills (40%)
- Correct application of statistical methods
- Appropriate handling of data and assumptions
- Quality of code and documentation
- Interpretation of results

### Clinical Relevance (30%)
- Clinical interpretation of findings
- Practical implications
- Patient-centered perspective
- Clinical decision-making relevance

### Communication (20%)
- Clear presentation of results
- Appropriate use of visualizations
- Professional writing style
- Audience-appropriate communication

### Innovation (10%)
- Creative approach to analysis
- Novel applications of methods
- Integration of multiple techniques
- Original insights

## Submission Guidelines

### Code Submission
- Well-documented R scripts
- Reproducible analysis pipeline
- Clear variable names and comments
- Error handling and validation

### Report Submission
- Executive summary
- Methods section
- Results with appropriate tables and figures
- Discussion and clinical implications
- Limitations and future directions

### Presentation
- 10-15 minute presentation
- Clear slides with key findings
- Clinical interpretation
- Q&A session

## Resources

### R Packages
- **Multivariate**: `car`, `MASS`, `broom`
- **Competing Risks**: `cmprsk`, `mstate`
- **Machine Learning**: `randomForest`, `e1071`, `caret`, `pROC`
- **Longitudinal**: `lme4`, `lmerTest`, `nlme`, `geepack`
- **Meta-Analysis**: `meta`, `metafor`, `dmetar`
- **Visualization**: `ggplot2`, `plotly`, `DT`

### Documentation
- Package vignettes and help files
- Statistical textbooks and references
- Clinical research guidelines
- Reporting standards (CONSORT, STROBE, PRISMA)

### Support
- Online forums and communities
- Statistical consulting services
- Clinical research mentors
- Peer review and feedback

## Conclusion

These advanced exercises provide comprehensive training in clinical data analysis techniques. Focus on:

1. **Understanding the methods** and their assumptions
2. **Applying techniques appropriately** to clinical questions
3. **Interpreting results** in clinical context
4. **Communicating findings** effectively
5. **Considering clinical implementation** and patient benefit

Remember that statistical sophistication should serve clinical understanding and patient care. Always prioritize clinical relevance and practical impact in your analyses. 
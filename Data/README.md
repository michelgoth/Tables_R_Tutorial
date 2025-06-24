# 📊 Clinical Dataset Documentation

> **Complete guide to the CGGA clinical dataset** 🧬

This document provides comprehensive information about the clinical dataset used throughout the tutorial series. Understanding your data is the first step in any analysis!

---

## 🎯 Dataset Overview

### Basic Information
- **Dataset Name:** CGGA Clinical Data
- **Source:** Chinese Glioma Genome Atlas (CGGA) Consortium
- **Type:** Clinical and molecular data from glioma patients
- **Format:** Excel (.xlsx)
- **Purpose:** Educational use for clinical data analysis tutorials
- **License:** Educational use only

### Study Context
Gliomas are the most common primary brain tumors in adults. This dataset contains clinical, pathological, and molecular information from patients diagnosed with gliomas, providing a rich resource for learning clinical data analysis techniques.

---

## 📋 Variable Descriptions

### Patient Identification
| Variable | Type | Description | Values |
|----------|------|-------------|---------|
| `CGGA_ID` | Character | Unique patient identifier | Unique alphanumeric codes |

### Demographics
| Variable | Type | Description | Values |
|----------|------|-------------|---------|
| `Age` | Numeric | Age at diagnosis (years) | 18-85+ |
| `Age_Bin` | Numeric | Binned age categories | 40.0 (≤40), 60.0 (41-60), 80.0 (>60) |
| `Gender` | Factor | Patient gender | Male, Female |

### Clinical Characteristics
| Variable | Type | Description | Values |
|----------|------|-------------|---------|
| `PRS_type` | Factor | Tumor type | Primary, Recurrent |
| `Histology` | Factor | Tumor histology | AA (Anaplastic Astrocytoma), A (Astrocytoma), O (Oligodendroglioma), etc. |
| `Grade` | Factor | WHO Grade | II, III, IV |

### Treatment Information
| Variable | Type | Description | Values |
|----------|------|-------------|---------|
| `Radio_status` | Numeric | Radiotherapy treatment | 0 = Untreated, 1 = Treated |
| `Chemo_status` | Numeric | Chemotherapy (TMZ) treatment | 0 = Untreated, 1 = Treated |

### Molecular Markers
| Variable | Type | Description | Values |
|----------|------|-------------|---------|
| `IDH_mutation_status` | Factor | IDH mutation status | Mutant, Wildtype |
| `1p19q_codeletion_status` | Factor | 1p19q codeletion status | Codel, Non-codel |
| `MGMTp_methylation_status` | Factor | MGMT promoter methylation | Methylated, Un-methylated |

### Survival Data
| Variable | Type | Description | Values |
|----------|------|-------------|---------|
| `OS` | Numeric | Overall survival (days) | 0-5000+ |
| `Censor` | Numeric | Survival event status | 0 = Alive, 1 = Dead |

---

## 🔍 Data Quality Information

### Missing Data
Some variables may contain missing values (NA). Always check for missing data before analysis:

```r
# Check missing values
sapply(data, function(x) sum(is.na(x)))
```

### Data Types
- **Numeric:** Age, OS, Censor, Radio_status, Chemo_status
- **Factor:** Gender, PRS_type, Histology, Grade, IDH_mutation_status, 1p19q_codeletion_status, MGMTp_methylation_status
- **Character:** CGGA_ID

### Data Cleaning Notes
- Age values are in years
- Survival times are in days
- Treatment status is binary (0/1)
- Categorical variables should be converted to factors for analysis

---

## 📊 Clinical Context

### Glioma Classification
Gliomas are classified by:
1. **Cell type:** Astrocytoma, Oligodendroglioma, Mixed
2. **Grade:** I-IV (increasing malignancy)
3. **Molecular markers:** IDH, 1p19q, MGMT

### Key Clinical Variables

#### WHO Grade
- **Grade II:** Low-grade, slow-growing
- **Grade III:** Anaplastic, more aggressive
- **Grade IV:** Glioblastoma, most aggressive

#### Molecular Markers
- **IDH Mutation:** Better prognosis, younger patients
- **1p19q Codeletion:** Oligodendroglioma marker, better response to treatment
- **MGMT Methylation:** Predicts response to temozolomide chemotherapy

#### Treatment Variables
- **Radiotherapy:** Standard treatment for high-grade gliomas
- **Chemotherapy:** Temozolomide (TMZ) is standard chemotherapy

---

## 🎯 Analysis Examples

### Descriptive Analysis
```r
# Age distribution by grade
ggplot(data, aes(x = Grade, y = Age)) +
  geom_boxplot() +
  labs(title = "Age Distribution by Tumor Grade")

# Survival by IDH status
ggplot(data, aes(x = IDH_mutation_status, y = OS)) +
  geom_boxplot() +
  labs(title = "Survival by IDH Mutation Status")
```

### Survival Analysis
```r
# Kaplan-Meier survival curves
library(survival)
fit <- survfit(Surv(OS, Censor) ~ Grade, data = data)
plot(fit, main = "Survival by Tumor Grade")
```

### Association Testing
```r
# Chi-square test for grade vs IDH status
chisq.test(table(data$Grade, data$IDH_mutation_status))
```

---

## ⚠️ Important Notes

### Data Limitations
1. **Educational Purpose:** This dataset is for learning only
2. **Sample Size:** Limited compared to large clinical trials
3. **Missing Data:** Some variables have missing values
4. **Single Center:** Data from one institution

### Ethical Considerations
- **Patient Privacy:** All data is de-identified
- **Educational Use:** Not for clinical decision-making
- **Proper Attribution:** Credit CGGA Consortium

### Best Practices
1. **Always check data quality** before analysis
2. **Handle missing data** appropriately
3. **Use appropriate statistical tests** for your data type
4. **Interpret results** in clinical context
5. **Report limitations** of your analysis

---

## 🔧 Data Preparation Tips

### Converting Variables
```r
# Convert to factors for categorical analysis
data$Grade <- factor(data$Grade, levels = c("II", "III", "IV"))
data$Gender <- factor(data$Gender)

# Ensure numeric variables are properly typed
data$Age <- as.numeric(data$Age)
data$OS <- as.numeric(data$OS)
```

### Creating Derived Variables
```r
# Age groups
data$Age_Group <- cut(data$Age, 
                     breaks = c(0, 40, 60, 100), 
                     labels = c("Young", "Middle", "Elderly"))

# Treatment combination
data$Treatment_Group <- ifelse(data$Radio_status == 1 & data$Chemo_status == 1, 
                              "Both", 
                              ifelse(data$Radio_status == 1, "RT Only",
                                     ifelse(data$Chemo_status == 1, "CT Only", "None")))
```

### Data Subsetting
```r
# High-grade gliomas only
high_grade <- data[data$Grade %in% c("III", "IV"), ]

# Complete cases only
complete_cases <- data[complete.cases(data), ]
```

---

## 📚 References

### Clinical Background
- Louis DN, et al. The 2016 World Health Organization Classification of Tumors of the Central Nervous System. Acta Neuropathol. 2016.
- Weller M, et al. Glioma. Nat Rev Dis Primers. 2015.

### Statistical Methods
- Kleinbaum DG, Klein M. Survival Analysis: A Self-Learning Text. Springer, 2012.
- Hosmer DW, Lemeshow S. Applied Logistic Regression. Wiley, 2013.

### CGGA Consortium
- Liu X, et al. The Chinese Glioma Genome Atlas (CGGA): A comprehensive resource with functional genomic data from Chinese glioma patients. Genomics Proteomics Bioinformatics. 2021.

---

## 🆘 Troubleshooting

### Common Issues
1. **File not found:** Check working directory and file path
2. **Encoding issues:** Ensure proper character encoding
3. **Variable names:** Check for typos in column names
4. **Data types:** Convert variables to appropriate types

### Data Validation
```r
# Check data structure
str(data)

# Summary statistics
summary(data)

# Check for unexpected values
table(data$Grade, useNA = "ifany")
```

---

## 📞 Support

### Questions About Data?
- Review variable descriptions above
- Check clinical context section
- Consult statistical references
- Ask in tutorial discussions

### Technical Issues?
- See [troubleshooting guide](../docs/troubleshooting.md)
- Check R documentation
- Search online resources

---

*Understanding your data is the foundation of good analysis! 🧬📊*

---

**Last updated:** 2024  
**Dataset version:** 1.0  
**Maintainer:** Clinical Data Analysis Tutorial Team 
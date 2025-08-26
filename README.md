# Clinical Data Analysis Learning Platform
[![R Version](https://img.shields.io/badge/R-4.0%2B-blue.svg)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://www.r-project.org/)

> **An integrated, code-first learning resource for clinical and transcriptomic data analysis.**

---

## Target Audience

This curriculum is designed for those new to bioinformatics and R programming. The goal is to provide a practical, clinically-relevant introduction to data analysis, starting with clinical variables and progressing to advanced transcriptomic analysis.

---

## Overview

This repository provides a structured, hands-on curriculum for integrated clinical and genomic data analysis in R. It uses a real-world glioma dataset to guide users from basic statistics to advanced, publication-ready bioinformatics analyses, including building a validated, integrated prognostic model.

---

## Key Features

### Curriculum (Lessons 1–25)
- **Part 1: Clinical Data Analysis (Lessons 1–18)**
    - Lessons 1–11: Foundational statistics (EDA, survival, regression, group comparisons).
    - Lessons 12–18: Advanced clinical modeling (risk scores, interactions, validation).
- **Part 2: Transcriptomic Data Analysis (Lessons 19–25)**
    - Lesson 19: Exploratory analysis with Principal Component Analysis (PCA).
    - Lesson 20: Discovery of novel prognostic genes (DE and Survival Analysis).
    - Lesson 21: Building an integrated clinical-genomic model with Machine Learning (LASSO).
    - Lesson 22: Uncovering biological pathways with Gene Set Enrichment Analysis (GSEA).
    - Lesson 23: Discovery of novel predictive biomarkers of treatment response.
    - Lesson 24: Comprehensive transcriptomic subtype discovery with differential expression and pathway analysis.
    - Lesson 25: **Critical quality control** - detecting contamination and technical artifacts in molecular subtypes.

### Visualization
- Publication-ready plots saved to `plots/` for all analyses.
- Consistent utilities via `R/utils.R`

### Quality Control & Validation
- **Lesson 25**: Comprehensive framework for detecting contamination and technical artifacts in molecular data.
- Teaches critical evaluation of molecular subtypes before biological interpretation.
- Essential for preventing false discoveries in rare subtype analysis.

### Sequential Learning
- Each lesson builds upon previous concepts, designed for step-by-step progression.
- Students should complete lessons in order for optimal learning outcomes.

---

## Quick Start

### Prerequisites
- R 4.0 or higher
- RStudio (recommended)

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/kevinj24fr/Tables_R_Tutorial.git
   cd Tables_R_Tutorial
   ```

2. Run the setup script to install all required packages:
   ```r
   source("R/setup.R")
   ```

3. Run a single lesson (e.g., Lesson 1) to generate its specific plots:
   ```r
   source("R/Lesson1.R")
   ```
   We recommend reading the corresponding lesson explanation in [`docs/Lesson01.md`](docs/Lesson01.md) as you run the script.

4. Continue with subsequent lessons in order:
   ```r
   source("R/Lesson2.R")  # And so on...
   ```

---

## Learning Path (Clinical and Dataset-Focused)
- Lesson 1: Setup, data import, first clinical plots
- Lesson 2: Descriptive statistics and distributions
- Lesson 3: Clinical feature visualization (categorical)
- Lesson 4: Kaplan–Meier survival by IDH
- Lesson 5: Log-rank test (MGMT or IDH)
- Lesson 6: Multivariable Cox regression
- Lesson 7: Association tests (Chi-square, Fisher)
- Lesson 8: Group comparisons for continuous variables (Wilcoxon/t-test)
- Lesson 9: Logistic regression (binary outcome)
- Lesson 10: Correlation matrix for numeric variables
- Lesson 11: ANOVA/MANOVA (group comparisons, post-hoc, assumptions)
- Lesson 12: Baseline table, missingness, univariable HRs, risk stratification, PH checks
- Lesson 13: Machine learning basics (feature importance)
- Lesson 14: Joint risk groups (IDH × MGMT)
- Lesson 15: Temozolomide benefit and MGMT interaction
- Lesson 16: Radiotherapy adjusted analysis
- Lesson 17: Parsimonious prognostic score (point-based)
- Lesson 18: Model validation with train-test split
- **Lesson 19: PCA of transcriptomic data**
- **Lesson 20: Volcano plot and KM plot for novel gene**
- **Lesson 21: Validated survival of integrated model**
- **Lesson 22: GSEA pathway enrichment plots**
- **Lesson 23: Discovery of novel predictive biomarkers of treatment response**
- **Lesson 24: Comprehensive transcriptomic subtype discovery with differential expression and pathway analysis**
- **Lesson 25: Biological validation of rare molecular subtypes - contamination detection and quality control**

---

## Repository Structure

```
Tables_R_Tutorial/
├── R/                          # R scripts
│   ├── setup.R                 # Package installation and verification
│   ├── utils.R                 # Helper functions
│   ├── Lesson1.R … Lesson25.R  # All lessons
│   └── README.md               # Script documentation
├── Data/
│   ├── ClinicalData.xlsx       # Main clinical dataset
│   ├── CGGA.mRNAseq_...txt     # RNA-seq expression data
│   └── README.md               # Data documentation
├── docs/                       # Lesson-specific explanations (1–25)
│   ├── Lesson01.md … Lesson25.md
├── plots/                      # Auto-saved plots from all lessons
├── LICENSE
└── README.md                   # This file
```

---

## Dataset Information

### Clinical Data (325 Patients)
- Demographics: Age, Gender
- Clinical Variables: Tumor Grade, Histology, IDH status, MGMT status
- Transcriptomic Data: RNA-seq gene expression (RSEM) for ~20,000 genes
- Treatment: Radiotherapy, Temozolomide status
- Outcomes: Overall Survival (days), Censor (0=alive, 1=dead)

See `Data/README.md` for full variable documentation.

---

## Documentation
- Lesson-specific write-ups are available in `docs/` (one per lesson, covering all 25 lessons), with purpose, methods, plots, and clinical interpretation tips.
- **Special focus on Lesson 25**: A comprehensive contamination detection framework essential for quality control in molecular subtyping.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

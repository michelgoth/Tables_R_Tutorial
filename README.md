# Clinical Data Analysis Learning Platform
[![R Version](https://img.shields.io/badge/R-4.0%2B-blue.svg)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://www.r-project.org/)

> **A clinical, code-first learning resource using a single provided dataset.**

---

## Overview

This repository provides a structured, hands-on curriculum for clinical data analysis in R. It uses the provided clinical dataset exclusively and focuses on reproducible scripts, clear explanations, and automatically generated plots saved to `plots/`.

---

## Key Features

### Curriculum (Lessons 1–17)
- Lessons 1–3: Import, descriptive statistics, categorical visualization
- Lessons 4–6: Kaplan–Meier, log-rank test, multivariable Cox
- Lessons 7–11: Association tests, group comparisons, logistic regression, correlation, ANOVA/MANOVA
- Lessons 12–17: Clinician extensions (baseline/missingness/PH checks), ML basics, IDH×MGMT joint groups, TMZ×MGMT interaction, radiotherapy adjusted analysis, parsimonious risk score

### Visualization
- Publication-ready plots saved to `plots/` (PDF and PNG)
- Consistent utilities via `R/utils.R`

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

2. Run the setup script
   ```r
   source("R/setup.R")
   ```

3. Run a lesson (plots are saved under `plots/`)
   ```r
   source("R/Lesson1.R")
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

---

## Repository Structure

```
Tables_R_Tutorial/
├── R/                          # R scripts
│   ├── setup.R                 # Package installation and verification
│   ├── utils.R                 # Data loading, NA handling, plot saving
│   ├── Lesson1.R … Lesson17.R  # Lessons aligned to the provided dataset
│   └── README.md               # Script documentation
├── Data/
│   ├── ClinicalData.xlsx       # Main dataset (325 patients)
│   └── README.md               # Data documentation
├── docs/                       # Lesson-specific explanations (1–17)
│   ├── Lesson01.md … Lesson17.md
├── plots/                      # Auto-saved plots from all lessons
├── progress_tracker.md         # Optional progress notes
├── LICENSE
└── README.md                   # This file
```

---

## Dataset Information

### Clinical Data (325 Patients)
- Demographics: Age, Gender
- Clinical Variables: Tumor Grade, Histology, IDH status, MGMT status
- Treatment: Radiotherapy, Temozolomide status
- Outcomes: Overall Survival (days), Censor (0=alive, 1=dead)

See `Data/README.md` for full variable documentation.

---

## Documentation
- Lesson-specific write-ups are available in `docs/` (one per lesson), with purpose, methods, plots, and clinical interpretation tips.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

# Clinical Data Analysis Learning Platform

**New to R or Coding? [Start Here!](NEUROSURGEON_GUIDE.md)**

> Run this in RStudio: `source('R/Neurosurgeon_QuickStart.R')`

[![R Version](https://img.shields.io/badge/R-4.0%2B-blue.svg)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://www.r-project.org/)

> **A comprehensive learning resource for clinical data analysis using R**

---

## Overview

This repository provides a structured, hands-on curriculum for clinical data analysis in R. It uses a real clinical dataset and focuses on reproducible scripts, clear explanations, and practice exercises.

---

## Key Features

### **Curriculum (Lessons 1–11)**
- **Lessons 1–10**: Core statistical methods and survival analysis
- **Lesson 11**: Multivariate analysis (ANOVA/MANOVA) on the provided dataset

### **Visualization**
- **Publication-ready plots**: High-quality figures saved to `plots/`
- **Clear code-first workflow**: Emphasis on learn-by-doing

---

## Quick Start

### Prerequisites
- R 4.0 or higher
- RStudio (recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/kevinj24fr/clinical-data-analysis.git
   cd clinical-data-analysis
   ```

2. **Run the setup script**
   ```r
   source("R/setup.R")
   ```

3. **Start with Lesson 1**
   ```r
   source("R/Lesson1.R")
   ```

4. **Practice with exercises**
   - Open files in `exercises/` (e.g., `exercises/exercise_1_basic_analysis.md`)

---

## Learning Path

### **Beginner Level (Lessons 1–5)**
- Lesson 1: Data Import and Basic Statistics
- Lesson 2: Descriptive Statistics and Visualization
- Lesson 3: Correlation Analysis
- Lesson 4: T-tests and Non-parametric Tests
- Lesson 5: Chi-square Tests and Association Analysis

### **Intermediate Level (Lessons 6–10)**
- Lesson 6: Survival Analysis and Cox Regression
- Lesson 7: Categorical Data Analysis
- Lesson 8: Non-parametric Methods
- Lesson 9: Logistic Regression
- Lesson 10: Multiple Regression and Model Building

### **Advanced (Lesson 11)**
- Lesson 11: Multivariate Analysis (ANOVA, MANOVA)

---

## Repository Structure

```
clinical-data-analysis/
├── 📁 R/                          # R Scripts
│   ├── 📄 setup.R                 # Package installation
│   ├── 📄 utils.R                 # Data loading and helpers
│   ├── 📄 Lesson1.R - Lesson11.R  # Curriculum aligned to dataset
│   └── 📄 README.md               # Script documentation
├── 📁 Data/                       # Clinical datasets
│   ├── 📄 ClinicalData.xlsx       # Main dataset (325 patients)
│   └── 📄 README.md               # Data documentation
├── 📁 docs/                       # Comprehensive documentation
│   ├── 📄 clinical_stats_guide.md # Statistical methods guide
│   ├── 📄 troubleshooting.md      # Common issues and solutions
│   └── 📄 advanced_techniques.md  # Advanced methods documentation
├── 📁 exercises/                  # Practice exercises
│   ├── 📄 exercise_1_basic_analysis.md
│   └── 📄 advanced_exercises.md   # Advanced practice problems
├── 📄 progress_tracker.md         # Student progress monitoring
├── 📄 LICENSE                     # MIT License
└── 📄 README.md                   # This file
```

---

## Dataset Information

### **Clinical Data (325 Patients)**
- Demographics: Age, Gender
- Clinical Variables: Tumor Grade, Histology, IDH status, MGMT status
- Treatment Data: Radiation, Chemotherapy status
- Outcomes: Overall Survival (OS in days), Censoring status (0/1)
- Molecular Markers: Various genetic and epigenetic markers

See `Data/README.md` for full variable documentation and best practices.

---

## Additional Resources

- [Clinical Statistics Guide](docs/clinical_stats_guide.md)
- [Troubleshooting Guide](docs/troubleshooting.md)
- [Advanced Techniques](docs/advanced_techniques.md)
- Exercises in `exercises/`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

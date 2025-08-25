# Clinical Dataset Documentation

This document describes the clinical dataset used across all lessons. Variables and types are standardized by `R/utils.R` when loading via `load_clinical_data()`.

---

## Dataset
- Name: CGGA clinical dataset (educational use)
- Format: Excel (`ClinicalData.xlsx`)
- Rows: Patients; columns: clinical, treatment, molecular, and survival fields

## Core Variables (standardized names)
- Identification
  - `CGGA_ID` (character): Unique patient identifier
- Demographics
  - `Age` (numeric, years)
  - `Gender` (factor: Female, Male)
- Clinical
  - `PRS_type` (factor: Primary, Recurrent, Secondary)
  - `Histology` (factor)
  - `Grade` (factor: WHO II, WHO III, WHO IV)
- Treatment
  - `Radio_status` (numeric: 0 untreated, 1 treated)
  - `Chemo_status` (numeric: 0 untreated, 1 treated; TMZ)
- Molecular
  - `IDH_mutation_status` (factor: Mutant, Wildtype): A key prognostic and diagnostic marker in gliomas.
  - `1p19q_codeletion_status` (factor: Codel, Non-codel): A defining marker for oligodendroglioma with prognostic significance.
  - `MGMTp_methylation_status` (factor: methylated, un-methylated): A predictive marker for response to temozolomide (TMZ) chemotherapy.
- Survival
  - `OS` (numeric, days)
  - `Censor` (numeric: 0 alive, 1 dead)

Notes
- Legacy verbose column names are normalized (e.g., chemotherapy/radiotherapy labels). See `R/utils.R` for the rename map.
- Literal strings such as "NA"/"Unknown" in categorical fields are converted to true missing values.

## Types and Missingness
- Numeric: `Age`, `OS`, `Censor`, `Radio_status`, `Chemo_status`
- Factor: `Gender`, `PRS_type`, `Histology`, `Grade`, `IDH_mutation_status`, `1p19q_codeletion_status`, `MGMTp_methylation_status`
- Missing values are present in some fields. Lessons drop rows with missing values for the variables used in each plot/model, and unused factor levels are removed.

## Usage
Recommended loading pathway (ensures consistent names/types and NA handling):
```r
source("R/utils.R")
load_required_packages(c("readxl"))
data <- load_clinical_data("Data/ClinicalData.xlsx")
```

## Scope and Limitations
- Educational dataset; not for clinical decision-making
- Single-cohort sample; treat inferences cautiously
- Always report sample size after filtering

For variable-specific use and clinical interpretation, see lesson write-ups in `docs/` and the corresponding scripts in `R/`. 
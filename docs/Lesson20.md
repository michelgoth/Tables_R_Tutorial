# Lesson 21: Discovering Novel Prognostic Genes

## Objective
Having explored the high-level structure of our transcriptomic data in Lesson 20, we now dive deeper to perform active gene discovery. This lesson will pinpoint specific, individual genes that are biologically and clinically relevant to our glioma cohort using two powerful techniques.

## Technique 1: Differential Expression Analysis

-   **The Question:** "Which genes have significantly different expression levels when we compare two groups of patients?"
-   **Our Application:** We compare the gene expression of **IDH-wildtype** tumors versus **IDH-mutant** tumors. This is a primary molecular division in glioma, and we expect to find major transcriptomic differences.
-   **The Method:** We use the `DESeq2` package, a bioinformatics standard, which performs sophisticated statistical testing to find genes that are not just different, but are *significantly* different after correcting for multiple comparisons.
-   **The Output (Volcano Plot):** The result is visualized in `Lesson21_Volcano_Plot_IDH.pdf`.
    -   The **x-axis** is the `log2FoldChange`, which measures the magnitude of the difference (how strongly the gene is up- or down-regulated).
    -   The **y-axis** is the `-log10(pvalue)`, which measures the statistical significance of that difference.
    -   **What to look for:** Genes in the **top-left** (highly significant, down-regulated in wildtype) and **top-right** (highly significant, up-regulated in wildtype) corners are the most interesting candidates.

## Technique 2: Genome-Wide Survival Analysis

-   **The Question:** "Which genes, out of all ~20,000, have expression levels that are most strongly associated with patient survival?"
-   **Our Application:** This is an unbiased, brute-force approach to discovering novel prognostic biomarkers. We are not pre-selecting genes; we are testing every single one.
-   **The Method:** The script creates a loop that iterates through every gene in our dataset. In each iteration, it fits a **univariable Cox proportional hazards model** (`Surv(OS, Censor) ~ GeneExpression`). This gives us a hazard ratio and a p-value for the association between that single gene's expression and patient survival.
-   **The Output (Kaplan-Meier Plot):** After testing all genes, the script identifies the **single most significant gene** (the one with the lowest p-value). It then generates a Kaplan-Meier plot for this gene (`Lesson21_KM_Plot_[GeneName].pdf`). To do this, it splits all patients into a "High Expression" group and a "Low Expression" group (based on the median) and shows their survival curves.

## The Power of this Approach

These two analyses are the cornerstone of discovery-based bioinformatics. Differential expression tells us about the **underlying biology** of different tumor subtypes, while the genome-wide survival analysis provides a direct, unbiased path to finding **new, clinically relevant prognostic markers** that might have been completely unknown before. The top gene from this analysis is a prime candidate for further investigation and for inclusion in a more advanced prognostic model.

### Lesson 3: Clinical Feature Visualization

- Purpose: Visualize relationships between categorical clinical variables.
- Data used: Grade, PRS_type, IDH_mutation_status, Gender.
- Methods: Grouped bar charts; NA rows removed and unused factor levels dropped.

#### Walkthrough
- Grade × PRS type: Counts of tumor grade within each PRS group (Primary/Recurrent/Secondary) using grouped bars.
- IDH × Gender: Counts of IDH mutation status by gender.

#### Plots generated
- plots/Lesson3_Grade_by_PRS.(png|pdf)
- plots/Lesson3_IDH_by_Gender.(png|pdf)

#### Clinical interpretation tips
- Grade by PRS: Recurrent and secondary cases may carry different grade patterns vs primary; this informs case-mix.
- IDH by Gender: Quick check for imbalances; no inference is made here.

#### Reproduce
```r
Rscript R/Lesson3.R
```

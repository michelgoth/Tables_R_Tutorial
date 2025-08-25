#' ---
#' title: "Lesson 23: Discovering Predictive Biomarkers of Treatment Response"
#' author: "T.J. Gibson"
#' date: "11/15/2023"
#' ---
#'
#' ### Introduction to Predictive Biomarkers
#'
#' So far, we have focused on **prognostic** biomarkers, which predict a patient's
#' outcome (e.g., survival time) regardless of what treatment they receive.
#' Now, we turn to a more clinically actionable question: can we find **predictive**
#' biomarkers?
#'
#' A predictive biomarker identifies which patients are most likely to benefit
#' from a specific treatment. This is a cornerstone of personalized medicine.
#'
#' In our dataset, the main treatment variable is chemotherapy with Temozolomide (TMZ).
#' We want to find a gene whose expression level predicts whether a patient will
#' respond well or poorly to TMZ.
#'
#' To do this, we look for a statistical **interaction**. We are no longer asking,
#' "Does this gene's expression relate to survival?" Instead, we ask, "Is the
#' relationship between this gene's expression and survival *different* for
#' patients who got TMZ compared to those who didn't?"
#'
#' ### Lesson Goals
#'
#' 1.  Integrate the clinical and transcriptomic datasets.
#' 2.  Perform a genome-wide screen for biomarkers that predict response to chemotherapy.
#' 3.  Identify the top predictive biomarker after correcting for multiple testing.
#' 4.  Visualize the interaction effect using stratified Kaplan-Meier plots.
#'
#' ### Loading Libraries & Data
#'
#' First, we load our standard libraries and helper functions.
source(file.path("R", "utils.R"))
source(file.path("R", "setup.R"))
load_required_packages(
  c("survival", "survminer", "DESeq2", "progress", "dplyr")
)

# Set a seed for reproducibility
set.seed(123)

# Load and prepare data
raw_clinical_data <- load_clinical_data(file.path("Data", "ClinicalData.xlsx"))
clinical_data <- impute_clinical_data(raw_clinical_data)
rnaseq_data <- load_rnaseq_data(file.path("Data", "CGGA.mRNAseq_325.RSEM.20200506.txt"))
combined_data <- integrate_data(clinical_data, rnaseq_data)

# Extract imputed clinical data and VST-transformed counts for analysis
clinical_df <- combined_data$clinical
vst_counts <- combined_data$vst_counts

# Ensure Chemo_status is a factor for modeling
clinical_df$Chemo_status <- factor(clinical_df$Chemo_status,
                                   levels = c(0, 1),
                                   labels = c("No", "TMZ"))

message("--- LESSON 23: Discovering Predictive Biomarkers ---")
message("--- Clinical and RNA-seq data successfully integrated. ---")

#' =================================================================
#' SECTION 1: GENOME-WIDE SCREEN FOR INTERACTION EFFECTS
#' =================================================================
#'
#' To find genes that predict response to chemotherapy, we will fit a Cox
#' Proportional Hazards model for every single gene.
#'
#' The crucial part of this model is the interaction term: `Chemo_status * gene`.
#' This term mathematically tests if the gene's effect on survival depends on
#' the chemotherapy status.
#'
#' We also include `Age` and `Grade` as covariates to adjust for their strong
#' prognostic effects. This helps ensure that our findings are independent of
#' these known clinical factors.
#'
#' Model for each gene:
#' `Surv(OS, Censor) ~ Chemo_status * Gene + Age + Grade`
#'
message("--- Performing genome-wide screen for predictive biomarkers... (This may take a few minutes) ---")

# Setup progress bar
pb <- progress_bar$new(
  format = "[:bar] :percent eta: :eta",
  total = nrow(vst_counts)
)

# Function to run Cox model and extract interaction p-value
run_interaction_cox <- function(gene_name, vst_counts, clinical_df) {
  pb$tick() # Increment progress bar
  
  # Combine data for the model
  model_data <- cbind(clinical_df, Gene = vst_counts[gene_name, ])
  
  # Fit the Cox model with the interaction term
  # Use tryCatch to handle cases where the model fails to converge
  res <- tryCatch({
    cox_model <- coxph(
      Surv(OS, Censor) ~ Chemo_status * Gene + Age + Grade,
      data = model_data
    )
    summary(cox_model)$coefficients["Chemo_statusTMZ:Gene", "Pr(>|z|)"]
  }, error = function(e) {
    NA # Return NA if the model fails
  })
  
  return(res)
}

# Run the analysis for all genes
interaction_p_values <- sapply(
  rownames(vst_counts),
  run_interaction_cox,
  vst_counts = vst_counts,
  clinical_df = clinical_df
)

# Create a results data frame
interaction_results <- data.frame(
  gene = names(interaction_p_values),
  p_value = interaction_p_values,
  row.names = NULL
)

# Remove genes where the model failed
interaction_results <- na.omit(interaction_results)

# Adjust for multiple testing using Benjamini-Hochberg (FDR)
interaction_results$p_adj <- p.adjust(interaction_results$p_value, method = "BH")

# Find the top predictive gene
top_gene <- interaction_results[which.min(interaction_results$p_adj), "gene"]

message(paste("--- Top predictive biomarker identified (after FDR correction):", top_gene, "---"))

#' =================================================================
#' SECTION 2: VISUALIZING THE PREDICTIVE EFFECT
#' =================================================================
#'
#' Now we will visualize the effect of our top gene, `r top_gene`.
#' If it is truly a predictive biomarker, its association with survival should be
#' strong in one treatment group but weak or non-existent in the other.
#'
#' We will create two KM plots:
#' 1. For patients who did NOT receive chemotherapy.
#' 2. For patients who received chemotherapy (TMZ).
#'
#' For each plot, we will stratify patients into "High" and "Low" expression
#' groups based on the median expression of the top gene.

# Prepare data for plotting
plot_data <- as.data.frame(cbind(clinical_df, t(vst_counts[top_gene, , drop = FALSE])))

# Create high/low expression groups based on the median
median_expr <- median(plot_data[[top_gene]])
plot_data$Expression_Group <- ifelse(plot_data[[top_gene]] >= median_expr, "High", "Low")
plot_data$Expression_Group <- factor(plot_data$Expression_Group, levels = c("Low", "High"))

# Create a list to hold the two plots
km_plots <- list()

# Loop through each chemotherapy status
for (chemo_group in c("No", "TMZ")) {
  
  # Subset the data for the current chemo group
  subset_data <- filter(plot_data, Chemo_status == chemo_group)
  
  # Check if there are at least two expression groups to compare
  if (length(unique(subset_data$Expression_Group)) < 2) {
    message(paste("Skipping plot for", chemo_group, "group: only one expression group present."))
    next # Skip to the next iteration
  }
  
  # Create the survival fit object
  fit <- survfit(Surv(OS, Censor) ~ Expression_Group, data = subset_data)
  
  # Create the KM plot
  p <- ggsurvplot(
    fit,
    data = subset_data,
    pval = TRUE,
    conf.int = TRUE,
    risk.table = TRUE,
    legend.labs = c("Low Expression", "High Expression"),
    legend.title = paste("Expression of", top_gene),
    palette = c("#0073C2FF", "#EFC000FF"),
    title = paste("Survival in Patients with No Chemotherapy"),
    subtitle = paste("Stratified by", top_gene, "Expression"),
    ggtheme = theme_light(),
    risk.table.y.text.col = TRUE,
    risk.table.y.text = FALSE
  )
  
  # Modify the title for the TMZ group
  if (chemo_group == "TMZ") {
    p$plot <- p$plot + labs(title = "Survival in Patients Treated with Chemotherapy (TMZ)")
  }
  
  km_plots[[chemo_group]] <- p
}

# Arrange and save the plots to a single file
# Note: If both groups were skipped, this will save an empty plot.
if (length(km_plots) > 0) {
  final_plot <- arrange_ggsurvplots(km_plots, print = FALSE, ncol = length(km_plots), nrow = 1)
  save_plot_both("Lesson23_Predictive_Biomarker_Analysis.pdf", final_plot, width = 18, height = 9)
}

message("--- Predictive biomarker analysis complete. Plots saved to 'plots' directory. ---")

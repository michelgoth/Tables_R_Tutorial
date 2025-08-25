# ===============================================================
# LESSON 22 (v2): BUILDING AN INTEGRATED CLINICAL-GENOMIC MODEL
# ===============================================================
#
# OBJECTIVE:
# To build a superior prognostic model by integrating clinical predictors
# with a novel gene expression signature. This revised lesson uses a more
# robust workflow by pre-filtering genes before applying LASSO-Cox
# regression to ensure a stable and powerful signature.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
load_required_packages(c("dplyr", "ggplot2", "readxl", "DESeq2", "survival", "glmnet", "pheatmap", "survminer"))
cat("--- LESSON 22 (v2): Building an Integrated Prognostic Model ---\n")

# ===============================================================
# SECTION 1: LOAD, PREPARE, AND SPLIT DATA ----------------------
# ===============================================================
clinical_data <- load_clinical_data("Data/ClinicalData.xlsx")
rna_data <- data.table::fread("Data/CGGA.mRNAseq_325.RSEM.20200506.txt")
rna_df <- as.data.frame(rna_data); rownames(rna_df) <- rna_df$Gene_Name; rna_df$Gene_Name <- NULL
rna_counts <- round(rna_df)
common_samples <- intersect(clinical_data$CGGA_ID, colnames(rna_counts))
clinical_data <- clinical_data[clinical_data$CGGA_ID %in% common_samples, ]
rna_counts <- rna_counts[, common_samples]
clinical_data <- clinical_data[match(colnames(rna_counts), clinical_data$CGGA_ID), ]
stopifnot(all(colnames(rna_counts) == clinical_data$CGGA_ID))
rownames(clinical_data) <- clinical_data$CGGA_ID

# Filter for complete survival data to prevent errors.
complete_cases_idx <- which(!is.na(clinical_data$OS) & !is.na(clinical_data$Censor))
clinical_data <- clinical_data[complete_cases_idx, ]
rna_counts <- rna_counts[, clinical_data$CGGA_ID]
stopifnot(all(colnames(rna_counts) == clinical_data$CGGA_ID))

# Use variance-stabilized expression data.
dds <- DESeqDataSetFromMatrix(countData = rna_counts, colData = clinical_data, design = ~ 1)
vsd <- vst(dds, blind=TRUE)
vsd_matrix <- assay(vsd)

# Train-Test Split using the same seed for reproducibility.
set.seed(42)
train_indices <- sample(1:ncol(vsd_matrix), size = 0.7 * ncol(vsd_matrix))
train_expr <- vsd_matrix[, train_indices]
test_expr <- vsd_matrix[, -train_indices]
train_clinical <- clinical_data[train_indices, ]
test_clinical <- clinical_data[-train_indices, ]
cat("--- Data successfully split into 70% training and 30% testing sets. ---\n")

# ===============================================================
# SECTION 2: FEATURE SELECTION (PRE-FILTERING) ------------------
# Running LASSO on ~20,000 genes is noisy. We first pre-filter to
# find the top 500 genes most associated with survival in the TRAINING set.
# ===============================================================
cat("--- Pre-filtering for the top 500 prognostic genes in the training set... ---\n")
surv_obj_train <- Surv(train_clinical$OS, train_clinical$Censor)
p_values <- apply(train_expr, 1, function(gene_expression) {
  fit <- tryCatch(coxph(surv_obj_train ~ gene_expression), error = function(e) NULL)
  if (is.null(fit)) return(NA)
  summary(fit)$waldtest["pvalue"]
})
top_genes <- names(sort(p_values, decreasing = FALSE)[1:500])
train_expr_filtered <- train_expr[top_genes, ]
test_expr_filtered <- test_expr[top_genes, ]

# ===============================================================
# SECTION 3: BUILD GENE SIGNATURE WITH LASSO-COX REGRESSION -----
# ===============================================================
cat("--- Building gene signature using LASSO-Cox on pre-filtered genes... ---\n")
x_train <- t(train_expr_filtered)
cv_fit <- cv.glmnet(x_train, surv_obj_train, family = "cox", alpha = 1)
best_lambda <- cv_fit$lambda.min
lasso_coefs <- coef(cv_fit, s = best_lambda)
selected_genes_indices <- which(lasso_coefs != 0)
gene_signature <- rownames(lasso_coefs)[selected_genes_indices]
gene_signature <- gene_signature[gene_signature != "(Intercept)"]
cat(paste("--- LASSO selected", length(gene_signature), "genes for the final signature. ---\n"))
print(gene_signature)

# ===============================================================
# SECTION 4: BUILD AND VALIDATE THE INTEGRATED MODEL ------------
# ===============================================================
# Calculate the gene signature risk score for each patient.
train_sig_score <- predict(cv_fit, newx = x_train, s = best_lambda, type = "link")
test_sig_score <- predict(cv_fit, newx = t(test_expr_filtered), s = best_lambda, type = "link")
train_clinical$Gene_Score <- as.numeric(train_sig_score)
test_clinical$Gene_Score <- as.numeric(test_sig_score)

# Build the final integrated model on the training data.
# Filter training data for any remaining NAs in clinical variables.
train_clinical_complete <- train_clinical[complete.cases(train_clinical[, c("Age", "Grade", "IDH_mutation_status")]), ]
cat("--- Building final integrated model on training data... ---\n")
final_model <- coxph(
  Surv(OS, Censor) ~ Age + Grade + IDH_mutation_status + Gene_Score,
  data = train_clinical_complete
)
print(summary(final_model))

# Validate the integrated model on the test set.
cat("--- Validating integrated model on the test set... ---\n")
test_clinical$Final_Risk_Score <- predict(final_model, newdata = test_clinical, type = "risk")
risk_groups <- cut(test_clinical$Final_Risk_Score,
                   breaks = quantile(test_clinical$Final_Risk_Score, probs = c(0, 1/3, 2/3, 1), na.rm=TRUE),
                   labels = c("Low", "Medium", "High"), include.lowest = TRUE)

# Final Kaplan-Meier Plot
fit_km_integrated <- survfit(Surv(OS, Censor) ~ risk_groups, data = test_clinical)
p_km_final <- ggsurvplot(fit_km_integrated, data = test_clinical, pval = TRUE,
                         title = "Validated Survival of Integrated Model (Test Set)",
                         legend.labs = c("Low Risk", "Medium Risk", "High Risk"), risk.table = TRUE)
print(p_km_final)
pdf(file.path("plots", "Lesson22_KM_Plot_Integrated_Model.pdf"), width = 8, height = 7)
print(p_km_final, newpage = FALSE)
dev.off()
cat("--- Final validated KM plot saved to 'plots' directory. ---\n")

# Bonus: Heatmap of the Gene Signature
if (length(gene_signature) > 1) {
  sig_heatmap_data <- train_expr[gene_signature, order(train_clinical_complete$Gene_Score)]
  pheatmap(sig_heatmap_data, scale = "row", show_colnames = FALSE,
           main = "Heatmap of LASSO Gene Signature Expression (Training Set)")
  # Saving code for heatmap omitted for brevity
}

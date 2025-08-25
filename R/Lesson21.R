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
# Load and prepare data
raw_clinical_data <- load_clinical_data(file.path("Data", "ClinicalData.xlsx"))
clinical_data <- impute_clinical_data(raw_clinical_data) # Use imputed data
rnaseq_data <- load_rnaseq_data(file.path("Data", "CGGA.mRNAseq_325.RSEM.20200506.txt"))
combined_data <- integrate_data(clinical_data, rnaseq_data)

# Extract the aligned clinical data and VST counts for analysis
clinical_df <- combined_data$clinical
vst_counts <- combined_data$vst_counts

cat("--- Clinical and RNA-seq data successfully integrated. ---\n")

# ===============================================================
# SECTION 2: TRAIN-TEST SPLIT -----------------------------------
# ===============================================================
set.seed(123) # for reproducibility
train_indices <- sample(1:ncol(vst_counts), size = 0.7 * ncol(vst_counts))
train_expr <- vst_counts[, train_indices]
test_expr <- vst_counts[, -train_indices]
train_clinical <- clinical_df[train_indices, ]
test_clinical <- clinical_df[-train_indices, ]
cat("--- Data successfully split into 70% training and 30% testing sets. ---\n")

# ===============================================================
# SECTION 3: FEATURE SELECTION (PRE-FILTERING) ------------------
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
# SECTION 4: BUILD GENE SIGNATURE WITH LASSO-COX REGRESSION -----
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
# SECTION 5: BUILD AND VALIDATE THE INTEGRATED MODEL ------------
# ===============================================================
# Calculate the gene signature risk score for each patient.
train_sig_score <- predict(cv_fit, newx = x_train, s = best_lambda, type = "link")
test_sig_score <- predict(cv_fit, newx = t(test_expr_filtered), s = best_lambda, type = "link")
train_clinical$Gene_Score <- as.numeric(train_sig_score)
test_clinical$Gene_Score <- as.numeric(test_sig_score)

# Build the final integrated model on the training data.
# NOTE: Because we are using the imputed dataset, we no longer need to
# filter the training data for complete cases before model fitting.
cat("--- Building final integrated model on training data... ---\n")
final_model <- coxph(
  Surv(OS, Censor) ~ Age + Grade + IDH_mutation_status + Gene_Score,
  data = train_clinical
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
pdf(file.path("plots", "Lesson21_KM_Plot_Integrated_Model.pdf"), width = 8, height = 7)
print(p_km_final, newpage = FALSE)
dev.off()
cat("--- Final validated KM plot saved to 'plots' directory. ---\n")

# Bonus: Heatmap of the Gene Signature
if (length(gene_signature) > 1) {
  sig_heatmap_data <- train_expr[gene_signature, order(train_clinical$Gene_Score)]
  pheatmap(sig_heatmap_data, scale = "row", show_colnames = FALSE,
           main = "Heatmap of LASSO Gene Signature Expression (Training Set)")
  # Saving code for heatmap omitted for brevity
}

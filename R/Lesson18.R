# ===============================================================
# LESSON 18: MODEL VALIDATION WITH A TRAIN-TEST SPLIT
# ===============================================================
#
# OBJECTIVE:
# To correctly evaluate a prognostic model by splitting the data into a
# training set and a testing set. This is a fundamental step in machine
# learning and robust statistical modeling to get an unbiased estimate
# of the model's performance on new, unseen data.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
load_required_packages(c("dplyr", "ggplot2", "survival"))
data <- load_clinical_data("Data/ClinicalData.xlsx")
cat("--- LESSON 18: Model Validation with Train-Test Split ---\n")

# ===============================================================
# SECTION 1: PREPARE DATA AND CREATE THE SPLIT ------------------
# We will use the same predictors as our scorecard in Lesson 17,
# and we must start by using only the complete cases for this model.
# ===============================================================
predictors <- intersect(c("Age", "Grade", "IDH_mutation_status", "MGMTp_methylation_status"), names(data))
if (length(predictors) < 2) {
  stop("Not enough predictors available for the model.")
}

# Create a clean data frame with no missing values for our key variables.
df_complete <- data[complete.cases(data[, c("OS", "Censor", predictors)]), ]

# --- The 70/30 Split ---
# We set a "seed" to make sure the random split is the same every
# time we run the script. This ensures reproducibility.
set.seed(42)

# Create a list of row indices that will be in our training set.
train_indices <- sample(1:nrow(df_complete), size = 0.7 * nrow(df_complete))

# Create the training and testing data frames.
train_data <- df_complete[train_indices, ]
test_data  <- df_complete[-train_indices, ]

cat("Data successfully split:\n")
cat("Training set size:", nrow(train_data), "patients\n")
cat("Testing set size:", nrow(test_data), "patients\n")

# ===============================================================
# SECTION 2: TRAIN THE MODEL *ONLY* ON THE TRAINING DATA --------
# This is the most critical step. The model must never see the
# test data during the training or fitting process.
# ===============================================================
surv_obj_train <- Surv(time = train_data$OS, event = train_data$Censor)
fml <- as.formula(paste("surv_obj_train ~", paste(predictors, collapse = " + ")))

cat("\n--- Training the Cox model on the training data... ---\n")
model_trained <- tryCatch(coxph(fml, data = train_data), error = function(e) NULL)
if (is.null(model_trained)) {
  stop("Cox model failed to fit on the training data. Cannot proceed.")
}
print(summary(model_trained))

# ===============================================================
# SECTION 3: EVALUATE THE MODEL ON THE UNSEEN TEST DATA ---------
# We now take the model trained in Section 2 and use it to make
# predictions on the test set.
# ===============================================================
cat("\n--- Evaluating the model on the test data... ---\n")
# Use the trained model to calculate the risk score (linear predictor)
# for each patient in the test set.
test_data$Score <- predict(model_trained, newdata = test_data, type = "lp")

# Stratify the *test* patients into risk groups based on their scores.
# The quantile breaks should be derived from the test set scores.
test_data$RiskStratum <- cut(test_data$Score,
                             breaks = quantile(test_data$Score, probs = c(0, 1/3, 2/3, 1), na.rm = TRUE),
                             labels = c("Low Risk", "Medium Risk", "High Risk"),
                             include.lowest = TRUE)

cat("Test set patients stratified into risk groups:\n")
print(table(test_data$RiskStratum))

# ===============================================================
# SECTION 4: VISUALIZE THE VALIDATED PERFORMANCE ----------------
# This Kaplan-Meier plot shows the model's performance on data it
# has never seen before. The separation of these curves is an
# unbiased and more realistic measure of the model's prognostic power.
# ===============================================================
fit_km_test <- survfit(Surv(OS, Censor) ~ RiskStratum, data = test_data)

# Generate and save the validated KM plot.
ensure_plots_dir()
png(file.path("plots", "Lesson18_KM_by_Risk_Test_Set.png"), width = 1200, height = 900, res = 150)
plot(fit_km_test, col = c("forestgreen", "goldenrod", "firebrick"), lwd = 2,
     xlab = "Time (days)", ylab = "Survival Probability",
     main = "Validated Survival by Risk Group (Test Set)")
legend("topright", legend = levels(test_data$RiskStratum), col = c("forestgreen", "goldenrod", "firebrick"), lwd = 2)
dev.off()

pdf(file.path("plots", "Lesson18_KM_by_Risk_Test_Set.pdf"), width = 9, height = 7)
plot(fit_km_test, col = c("forestgreen", "goldenrod", "firebrick"), lwd = 2,
     xlab = "Time (days)", ylab = "Survival Probability",
     main = "Validated Survival by Risk Group (Test Set)")
legend("topright", legend = levels(test_data$RiskStratum), col = c("forestgreen", "goldenrod", "firebrick"), lwd = 2)
dev.off()

cat("\n--- Generated plot 'Lesson18_KM_by_Risk_Test_Set.pdf/.png' ---\n")
cat("Compare this plot to the one from Lesson 17. The separation of curves may be less pronounced, but it is a much more honest assessment of the model's performance.\n")

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================
# 1. Look at the Kaplan-Meier plot generated. Does the model still
#    successfully stratify patients? How does the separation compare
#    to the plot from Lesson 17, which was overfit?
#
# 2. Try changing the `set.seed()` number to see how a different
#    random split affects the results in the test set. Does the
#    model remain stable?
#
# 3. Repeat this entire process for the Random Forest model from
#    Lesson 13. Train the model on the training set, then calculate
#    the accuracy and confusion matrix on the test set. Is the
#    accuracy similar to what was reported before?

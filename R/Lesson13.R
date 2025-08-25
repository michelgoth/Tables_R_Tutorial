# ===============================================================
# LESSON 13: AN INTRODUCTION TO MACHINE LEARNING FOR CLINICAL PREDICTION
# ===============================================================
#
# OBJECTIVE:
# To introduce the basic concepts of Machine Learning (ML), using a
# Random Forest model to identify which clinical features are most
# important for predicting a clinical outcome.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
# 'randomForest' is a popular and powerful machine learning package.
load_required_packages(c("readxl", "ggplot2", "randomForest"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# ===============================================================
# SECTION 1: DATA PREPARATION FOR MACHINE LEARNING ------------
# This section covers the essential steps to get your data ready
# for a machine learning model.
# ===============================================================
cat("\n--- SECTION 1: DATA PREPARATION ---\n")

ml_data <- data

# --- 1A: Feature Engineering: Creating a Binary Outcome ---
# ML models for classification need a categorical outcome to predict.
# Here, we "engineer" a new feature: survival at 1 year.
if (all(c("OS", "Censor") %in% names(ml_data))) {
  ml_data$survival_1year <- factor(
    ifelse(ml_data$OS >= 365, "Alive", # If OS > 365 days, they were alive at 1 year.
           ifelse(ml_data$OS < 365 & ml_data$Censor == 1, "Deceased", NA)) # If event before 365, they were not.
  )
  cat("Created binary outcome 'survival_1year':\n")
  print(table(ml_data$survival_1year))
}

# --- 1B: Define Features and Prepare Data ---
# "Features" is the ML term for predictor variables.
feature_cols <- c("Age", "Gender", "Grade", "IDH_mutation_status", "MGMTp_methylation_status", "PRS_type")
available_features <- intersect(feature_cols, names(ml_data))

# For the model, we need a data frame with only the outcome and the features.
# We must also use 'complete.cases()' to remove any rows with missing data
# in either the outcome or any of the features.
rf_data <- ml_data[, c(available_features, "survival_1year")]
rf_data <- rf_data[complete.cases(rf_data), ]
rf_data$survival_1year <- droplevels(rf_data$survival_1year)


# ===============================================================
# SECTION 2: RANDOM FOREST MODEL ------------------------------
# A Random Forest is an "ensemble" model, meaning it builds hundreds
# of individual decision trees and combines their predictions. It is
# powerful and handles complex relationships in the data well.
# ===============================================================
cat("\n--- SECTION 2: RANDOM FOREST MODEL ---\n")
if (nrow(rf_data) > 0 && nlevels(rf_data$survival_1year) == 2) {
  # --- 2A: Train/Test Split ---
  # To evaluate a model, we train it on a portion of the data (e.g., 70%)
  # and test its performance on data it has never seen (the other 30%).
  set.seed(123) # for reproducibility
  train_indices <- sample(1:nrow(rf_data), size = 0.7 * nrow(rf_data))
  train_data <- rf_data[train_indices, ]
  test_data  <- rf_data[-train_indices, ]

  # --- 2B: Model Training ---
  rf_formula <- as.formula(paste("survival_1year ~", paste(available_features, collapse = " + ")))
  rf_model <- randomForest(rf_formula, data = train_data, ntree = 500, importance = TRUE)

  # --- 2C: Feature Importance ---
  # A key output of Random Forest is feature importance, which tells us
  # which variables were most useful in making accurate predictions.
  imp <- importance(rf_model)
  imp_df <- data.frame(Feature = rownames(imp), MeanDecreaseGini = imp[, "MeanDecreaseGini"])
  # "MeanDecreaseGini" is a measure of how much a feature improves the purity
  # of the model's classifications. Higher is better.
  p <- ggplot(imp_df, aes(x = reorder(Feature, MeanDecreaseGini), y = MeanDecreaseGini)) +
    geom_col(fill = "steelblue") + coord_flip() + theme_minimal() +
    labs(title = "Random Forest Feature Importance", x = "Feature", y = "Importance (Mean Decrease Gini)")
  print(p)
  save_plot_both(p, base_filename = "Lesson13_RF_Feature_Importance")

  # --- 2D: Model Evaluation ---
  # We use the trained model to make predictions on the 'test_data'.
  predictions <- predict(rf_model, test_data)
  # A confusion matrix compares the model's predictions to the actual outcomes.
  confusion_matrix <- table(Actual = test_data$survival_1year, Predicted = predictions)
  cat("\nConfusion Matrix:\n")
  print(confusion_matrix)
  accuracy <- sum(diag(confusion_matrix)) / sum(confusion_matrix)
  cat("\nModel Accuracy on Test Set:", round(accuracy, 3), "\n")
}
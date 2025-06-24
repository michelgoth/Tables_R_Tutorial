# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")[["CRAN"]])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# List of required packages
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", 
                       "corrplot", "car", "psych", "ggpubr", "rstatix", 
                       "randomForest", "e1071", "caret", "pROC", "rpart", "rpart.plot")

# Install missing packages
installed <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!(pkg %in% installed)) {
    tryCatch({
      install.packages(pkg, dependencies = TRUE)
    }, error = function(e) {
      cat(sprintf("Failed to install %s: %s\n", pkg, e$message))
    })
  }
}

# Load libraries
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    cat(sprintf("Failed to load package: %s\n", pkg))
  }
}

# Data file path
DATA_PATH <- "Data/ClinicalData.xlsx"
if (!file.exists(DATA_PATH)) {
  stop(paste0("ERROR: Data file not found at ", DATA_PATH, ". Please ensure the file exists."))
}

# Load the data
suppressWarnings({
  data <- tryCatch({
    readxl::read_excel(DATA_PATH)
  }, error = function(e) {
    stop(paste0("ERROR: Could not read data file: ", e$message))
  })
})

# Convert key columns to appropriate types (if present)
if ("Grade" %in% names(data)) data$Grade <- as.factor(data$Grade)
if ("Gender" %in% names(data)) data$Gender <- as.factor(data$Gender)
if ("PRS_type" %in% names(data)) data$PRS_type <- as.factor(data$PRS_type)
if ("IDH_mutation_status" %in% names(data)) data$IDH_mutation_status <- as.factor(data$IDH_mutation_status)
if ("MGMTp_methylation_status" %in% names(data)) data$MGMTp_methylation_status <- as.factor(data$MGMTp_methylation_status)
if ("Histology" %in% names(data)) data$Histology <- as.factor(data$Histology)
if ("Age" %in% names(data)) data$Age <- as.numeric(data$Age)
if ("OS" %in% names(data)) data$OS <- as.numeric(data$OS)
if ("Censor (alive=0; dead=1)" %in% names(data)) data$`Censor (alive=0; dead=1)` <- as.numeric(data$`Censor (alive=0; dead=1)`)

# ===============================================================
# LESSON 13: MACHINE LEARNING BASICS FOR CLINICAL PREDICTION
# ===============================================================

# LEARNING OBJECTIVES:
# - Build Random Forest models for clinical prediction
# - Implement Support Vector Machines (SVM)
# - Perform cross-validation and model evaluation
# - Interpret feature importance and model performance
# - Apply machine learning to clinical decision-making

# WHAT YOU'LL LEARN:
# Machine learning provides powerful tools for clinical prediction,
# risk stratification, and personalized medicine. This lesson covers
# essential algorithms and evaluation methods.

cat("=== LESSON 13: MACHINE LEARNING BASICS ===\n")
cat("Sample size:", nrow(data), "patients\n")
cat("Available variables:", paste(names(data), collapse = ", "), "\n\n")

# SECTION 1: DATA PREPARATION FOR MACHINE LEARNING ------------

cat("SECTION 1: DATA PREPARATION\n")
cat("Preparing clinical data for machine learning...\n\n")

# Create a clean dataset for ML
ml_data <- data

# Handle missing values
missing_summary <- sapply(ml_data, function(x) sum(is.na(x)))
cat("Missing values summary:\n")
print(missing_summary[missing_summary > 0])

# Remove rows with too many missing values
threshold <- 0.5  # Remove if >50% missing
missing_prop <- rowSums(is.na(ml_data)) / ncol(ml_data)
ml_data <- ml_data[missing_prop <= threshold, ]

cat("\nAfter removing rows with >50% missing values:", nrow(ml_data), "patients\n")

# Create binary outcome for survival (1-year survival)
if (all(c("OS", "Censor (alive=0; dead=1)") %in% names(ml_data))) {
  ml_data$survival_1year <- ifelse(ml_data$OS >= 12 & ml_data$`Censor (alive=0; dead=1)` == 0, 1,
                                  ifelse(ml_data$OS < 12 & ml_data$`Censor (alive=0; dead=1)` == 1, 0, NA))
  ml_data$survival_1year <- as.factor(ml_data$survival_1year)
  
  # Summary of outcome
  outcome_summary <- table(ml_data$survival_1year, useNA = "ifany")
  cat("1-year survival outcome:\n")
  cat("Alive (1):", outcome_summary["1"], "\n")
  cat("Dead (0):", outcome_summary["0"], "\n")
  cat("Missing:", sum(is.na(ml_data$survival_1year)), "\n\n")
}

# Select features for modeling
feature_cols <- c("Age", "Gender", "Grade", "IDH_mutation_status", 
                  "MGMTp_methylation_status", "PRS_type")
available_features <- feature_cols[feature_cols %in% names(ml_data)]

cat("Available features for modeling:", paste(available_features, collapse = ", "), "\n")

# SECTION 2: RANDOM FOREST MODEL ------------------------------

cat("\nSECTION 2: RANDOM FOREST MODEL\n")
cat("Building Random Forest for survival prediction...\n\n")

if (length(available_features) > 0 && "survival_1year" %in% names(ml_data)) {
  # Prepare data for Random Forest
  rf_data <- ml_data[, c(available_features, "survival_1year")]
  rf_data <- rf_data[complete.cases(rf_data), ]
  
  if (nrow(rf_data) > 0) {
    tryCatch({
      # Split data into training and testing sets
      set.seed(123)
      train_indices <- sample(1:nrow(rf_data), size = 0.7 * nrow(rf_data))
      train_data <- rf_data[train_indices, ]
      test_data <- rf_data[-train_indices, ]
      
      cat("Training set size:", nrow(train_data), "\n")
      cat("Testing set size:", nrow(test_data), "\n")
      
      # Build Random Forest model
      rf_formula <- as.formula(paste("survival_1year ~", paste(available_features, collapse = " + ")))
      
      rf_model <- randomForest(rf_formula, 
                              data = train_data,
                              ntree = 500,
                              importance = TRUE)
      
      cat("\nRandom Forest Model Summary:\n")
      print(rf_model)
      
      # Feature importance
      cat("\nFeature Importance:\n")
      importance_df <- data.frame(
        Feature = rownames(importance(rf_model)),
        MeanDecreaseAccuracy = importance(rf_model)[, "MeanDecreaseAccuracy"],
        MeanDecreaseGini = importance(rf_model)[, "MeanDecreaseGini"]
      )
      print(importance_df[order(-importance_df$MeanDecreaseAccuracy), ])
      
      # Predictions on test set
      rf_predictions <- predict(rf_model, test_data, type = "prob")
      rf_pred_class <- predict(rf_model, test_data)
      
      # Model performance
      confusion_matrix <- table(Actual = test_data$survival_1year, 
                               Predicted = rf_pred_class)
      
      cat("\nConfusion Matrix (Random Forest):\n")
      print(confusion_matrix)
      
      # Calculate metrics
      accuracy <- sum(diag(confusion_matrix)) / sum(confusion_matrix)
      sensitivity <- confusion_matrix[2, 2] / sum(confusion_matrix[2, ])
      specificity <- confusion_matrix[1, 1] / sum(confusion_matrix[1, ])
      
      cat("\nPerformance Metrics (Random Forest):\n")
      cat("Accuracy:", round(accuracy, 3), "\n")
      cat("Sensitivity:", round(sensitivity, 3), "\n")
      cat("Specificity:", round(specificity, 3), "\n")
      
    }, error = function(e) {
      cat("Error in Random Forest modeling:", e$message, "\n")
    })
  } else {
    cat("Insufficient complete data for Random Forest modeling.\n")
  }
} else {
  cat("Required features or outcome not available for Random Forest.\n")
}

# SECTION 3: SUPPORT VECTOR MACHINE (SVM) --------------------

cat("\nSECTION 3: SUPPORT VECTOR MACHINE\n")
cat("Building SVM model for survival prediction...\n\n")

if (length(available_features) > 0 && "survival_1year" %in% names(ml_data)) {
  # Prepare data for SVM
  svm_data <- ml_data[, c(available_features, "survival_1year")]
  svm_data <- svm_data[complete.cases(svm_data), ]
  
  if (nrow(svm_data) > 0) {
    tryCatch({
      # Split data
      set.seed(123)
      train_indices <- sample(1:nrow(svm_data), size = 0.7 * nrow(svm_data))
      train_data <- svm_data[train_indices, ]
      test_data <- svm_data[-train_indices, ]
      
      # Build SVM model
      svm_formula <- as.formula(paste("survival_1year ~", paste(available_features, collapse = " + ")))
      
      svm_model <- svm(svm_formula,
                      data = train_data,
                      kernel = "radial",
                      probability = TRUE)
      
      cat("SVM Model Summary:\n")
      print(svm_model)
      
      # Predictions
      svm_predictions <- predict(svm_model, test_data, probability = TRUE)
      svm_pred_class <- predict(svm_model, test_data)
      
      # Performance evaluation
      svm_confusion <- table(Actual = test_data$survival_1year, 
                            Predicted = svm_pred_class)
      
      cat("\nConfusion Matrix (SVM):\n")
      print(svm_confusion)
      
      # Calculate metrics
      svm_accuracy <- sum(diag(svm_confusion)) / sum(svm_confusion)
      svm_sensitivity <- svm_confusion[2, 2] / sum(svm_confusion[2, ])
      svm_specificity <- svm_confusion[1, 1] / sum(svm_confusion[1, ])
      
      cat("\nPerformance Metrics (SVM):\n")
      cat("Accuracy:", round(svm_accuracy, 3), "\n")
      cat("Sensitivity:", round(svm_sensitivity, 3), "\n")
      cat("Specificity:", round(svm_specificity, 3), "\n")
      
    }, error = function(e) {
      cat("Error in SVM modeling:", e$message, "\n")
    })
  } else {
    cat("Insufficient complete data for SVM modeling.\n")
  }
} else {
  cat("Required features or outcome not available for SVM.\n")
}

# SECTION 4: DECISION TREE MODEL ------------------------------

cat("\nSECTION 4: DECISION TREE MODEL\n")
cat("Building interpretable decision tree...\n\n")

if (length(available_features) > 0 && "survival_1year" %in% names(ml_data)) {
  # Prepare data
  tree_data <- ml_data[, c(available_features, "survival_1year")]
  tree_data <- tree_data[complete.cases(tree_data), ]
  
  if (nrow(tree_data) > 0) {
    tryCatch({
      # Split data
      set.seed(123)
      train_indices <- sample(1:nrow(tree_data), size = 0.7 * nrow(tree_data))
      train_data <- tree_data[train_indices, ]
      test_data <- tree_data[-train_indices, ]
      
      # Build decision tree
      tree_formula <- as.formula(paste("survival_1year ~", paste(available_features, collapse = " + ")))
      
      tree_model <- rpart(tree_formula,
                         data = train_data,
                         method = "class",
                         cp = 0.01)
      
      cat("Decision Tree Model Summary:\n")
      print(tree_model)
      
      # Tree complexity
      cat("\nTree Complexity:\n")
      cat("Number of splits:", length(tree_model$splits), "\n")
      cat("Number of terminal nodes:", length(tree_model$frame$var == "<leaf>"), "\n")
      
      # Variable importance
      cat("\nVariable Importance (Decision Tree):\n")
      print(tree_model$variable.importance)
      
      # Predictions
      tree_predictions <- predict(tree_model, test_data, type = "class")
      
      # Performance
      tree_confusion <- table(Actual = test_data$survival_1year, 
                             Predicted = tree_predictions)
      
      cat("\nConfusion Matrix (Decision Tree):\n")
      print(tree_confusion)
      
      tree_accuracy <- sum(diag(tree_confusion)) / sum(tree_confusion)
      cat("Accuracy:", round(tree_accuracy, 3), "\n")
      
    }, error = function(e) {
      cat("Error in decision tree modeling:", e$message, "\n")
    })
  } else {
    cat("Insufficient complete data for decision tree modeling.\n")
  }
} else {
  cat("Required features or outcome not available for decision tree.\n")
}

# SECTION 5: CROSS-VALIDATION AND MODEL COMPARISON -----------

cat("\nSECTION 5: CROSS-VALIDATION AND MODEL COMPARISON\n")
cat("Evaluating model performance with cross-validation...\n\n")

if (length(available_features) > 0 && "survival_1year" %in% names(ml_data)) {
  # Prepare data
  cv_data <- ml_data[, c(available_features, "survival_1year")]
  cv_data <- cv_data[complete.cases(cv_data), ]
  
  if (nrow(cv_data) > 0) {
    tryCatch({
      # Set up cross-validation
      set.seed(123)
      folds <- createFolds(cv_data$survival_1year, k = 5)
      
      # Initialize results storage
      rf_cv_accuracy <- numeric(5)
      svm_cv_accuracy <- numeric(5)
      tree_cv_accuracy <- numeric(5)
      
      cat("5-Fold Cross-Validation Results:\n")
      
      for (i in 1:5) {
        # Split data
        train_data <- cv_data[-folds[[i]], ]
        test_data <- cv_data[folds[[i]], ]
        
        # Random Forest
        rf_formula <- as.formula(paste("survival_1year ~", paste(available_features, collapse = " + ")))
        rf_model <- randomForest(rf_formula, data = train_data, ntree = 100)
        rf_pred <- predict(rf_model, test_data)
        rf_cv_accuracy[i] <- mean(rf_pred == test_data$survival_1year)
        
        # SVM
        svm_model <- svm(rf_formula, data = train_data, kernel = "radial")
        svm_pred <- predict(svm_model, test_data)
        svm_cv_accuracy[i] <- mean(svm_pred == test_data$survival_1year)
        
        # Decision Tree
        tree_model <- rpart(rf_formula, data = train_data, method = "class")
        tree_pred <- predict(tree_model, test_data, type = "class")
        tree_cv_accuracy[i] <- mean(tree_pred == test_data$survival_1year)
        
        cat("Fold", i, "- RF:", round(rf_cv_accuracy[i], 3), 
            "SVM:", round(svm_cv_accuracy[i], 3), 
            "Tree:", round(tree_cv_accuracy[i], 3), "\n")
      }
      
      # Summary statistics
      cat("\nCross-Validation Summary:\n")
      cat("Random Forest - Mean Accuracy:", round(mean(rf_cv_accuracy), 3), 
          "(SD:", round(sd(rf_cv_accuracy), 3), ")\n")
      cat("SVM - Mean Accuracy:", round(mean(svm_cv_accuracy), 3), 
          "(SD:", round(sd(svm_cv_accuracy), 3), ")\n")
      cat("Decision Tree - Mean Accuracy:", round(mean(tree_cv_accuracy), 3), 
          "(SD:", round(sd(tree_cv_accuracy), 3), ")\n")
      
      # Best model
      best_model <- which.max(c(mean(rf_cv_accuracy), mean(svm_cv_accuracy), mean(tree_cv_accuracy)))
      model_names <- c("Random Forest", "SVM", "Decision Tree")
      cat("\nBest performing model:", model_names[best_model], "\n")
      
    }, error = function(e) {
      cat("Error in cross-validation:", e$message, "\n")
    })
  } else {
    cat("Insufficient complete data for cross-validation.\n")
  }
} else {
  cat("Required features or outcome not available for cross-validation.\n")
}

# SECTION 6: CLINICAL INTERPRETATION -------------------------

cat("\nSECTION 6: CLINICAL INTERPRETATION\n")
cat("Translating machine learning results to clinical practice...\n\n")

cat("Clinical Applications of Machine Learning:\n")
cat("1. Risk Stratification: Identify high-risk patients\n")
cat("2. Treatment Selection: Personalized therapy decisions\n")
cat("3. Prognostic Modeling: Predict survival outcomes\n")
cat("4. Biomarker Discovery: Find important clinical factors\n")
cat("5. Clinical Decision Support: Aid physician decision-making\n\n")

cat("Model Selection Criteria:\n")
cat("- Accuracy: Overall prediction performance\n")
cat("- Interpretability: Clinical understanding of predictions\n")
cat("- Robustness: Performance across different datasets\n")
cat("- Clinical Utility: Impact on patient care\n")
cat("- Regulatory Compliance: FDA approval requirements\n\n")

cat("Best Practices for Clinical ML:\n")
cat("- Use cross-validation to avoid overfitting\n")
cat("- Validate models on independent datasets\n")
cat("- Consider clinical interpretability\n")
cat("- Report confidence intervals and uncertainty\n")
cat("- Integrate with clinical workflow\n")

# PRACTICE TASKS ----------------------------------------------

cat("\n=== PRACTICE TASKS ===\n")
cat("1. Build Random Forest model for IDH mutation prediction\n")
cat("2. Compare SVM vs. Random Forest for survival prediction\n")
cat("3. Perform feature selection using importance measures\n")
cat("4. Create ensemble model combining multiple algorithms\n")
cat("5. Develop clinical risk score from ML predictions\n\n")

cat("=== CLINICAL INTERPRETATION TIPS ===\n")
cat("- Focus on clinically meaningful outcomes\n")
cat("- Validate models on external datasets\n")
cat("- Consider model interpretability for clinical adoption\n")
cat("- Report performance metrics relevant to clinical practice\n")
cat("- Integrate ML predictions with clinical expertise\n") 
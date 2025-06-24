# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")[["CRAN"]])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# List of required packages
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", 
                       "corrplot", "car", "psych", "ggpubr", "rstatix", 
                       "survival", "survminer", "cmprsk", "mstate")

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
# LESSON 12: TIME-TO-EVENT ANALYSIS WITH COMPETING RISKS
# ===============================================================

# LEARNING OBJECTIVES:
# - Understand competing risks in clinical data
# - Perform competing risks analysis
# - Calculate cumulative incidence functions
# - Apply Fine-Gray regression for competing risks
# - Interpret results in clinical context

# WHAT YOU'LL LEARN:
# In clinical research, patients may experience different types of events
# (e.g., disease progression vs. death). Competing risks analysis accounts
# for these multiple event types and provides more accurate estimates.

cat("=== LESSON 12: COMPETING RISKS ANALYSIS ===\n")
cat("Sample size:", nrow(data), "patients\n")
cat("Available variables:", paste(names(data), collapse = ", "), "\n\n")

# SECTION 1: UNDERSTANDING COMPETING RISKS --------------------

cat("SECTION 1: UNDERSTANDING COMPETING RISKS\n")
cat("Analyzing event types and their relationships...\n\n")

if (all(c("OS", "Censor (alive=0; dead=1)") %in% names(data))) {
  # Create competing risks dataset
  analysis_data <- data[!is.na(data$OS) & !is.na(data$`Censor (alive=0; dead=1)`), ]
  
  if (nrow(analysis_data) > 0) {
    # Create event type variable (for demonstration)
    # In real data, you might have specific event types
    analysis_data$event_type <- ifelse(analysis_data$`Censor (alive=0; dead=1)` == 1, 1, 0)
    
    # Summary of events
    event_summary <- table(analysis_data$event_type)
    cat("Event Summary:\n")
    cat("Censored (alive):", event_summary["0"], "\n")
    cat("Events (death):", event_summary["1"], "\n")
    cat("Total events:", sum(event_summary), "\n\n")
    
    # Create survival object
    surv_obj <- Surv(analysis_data$OS, analysis_data$event_type)
    
    # Basic survival analysis
    km_fit <- survfit(surv_obj ~ 1)
    print(summary(km_fit))
    
  } else {
    cat("Insufficient data for competing risks analysis.\n")
  }
} else {
  cat("Required columns not found for competing risks analysis.\n")
}

# SECTION 2: CUMULATIVE INCIDENCE FUNCTION -------------------

cat("\nSECTION 2: CUMULATIVE INCIDENCE FUNCTION\n")
cat("Calculating event-specific cumulative incidence...\n\n")

if (all(c("OS", "Censor (alive=0; dead=1)") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$`Censor (alive=0; dead=1)`), ]
  
  if (nrow(analysis_data) > 0) {
    tryCatch({
      # Create competing risks object
      # For demonstration, we'll treat death as the event of interest
      # and other causes as competing events
      analysis_data$event_type <- ifelse(analysis_data$`Censor (alive=0; dead=1)` == 1, 1, 0)
      
      # Calculate cumulative incidence function
      cif_result <- cmprsk::crr(ftime = analysis_data$OS, 
                               fstatus = analysis_data$event_type)
      
      cat("Cumulative Incidence Function Results:\n")
      print(summary(cif_result))
      
      # Extract cumulative incidence estimates
      time_points <- cif_result$time
      cif_estimates <- cif_result$est
      
      cat("\nCumulative Incidence at key time points:\n")
      key_times <- c(6, 12, 24, 36, 48, 60)  # months
      for (t in key_times) {
        if (t <= max(time_points)) {
          idx <- which(time_points >= t)[1]
          if (!is.na(idx)) {
            cat(t, "months:", round(cif_estimates[idx] * 100, 1), "%\n")
          }
        }
      }
      
    }, error = function(e) {
      cat("Error in cumulative incidence calculation:", e$message, "\n")
    })
  } else {
    cat("Insufficient data for cumulative incidence analysis.\n")
  }
} else {
  cat("Required columns not found for cumulative incidence analysis.\n")
}

# SECTION 3: COMPETING RISKS BY STRATA -----------------------

cat("\nSECTION 3: COMPETING RISKS BY STRATA\n")
cat("Analyzing competing risks across different groups...\n\n")

if (all(c("OS", "Censor (alive=0; dead=1)", "Grade") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$`Censor (alive=0; dead=1)`) & !is.na(data$Grade), ]
  
  if (nrow(analysis_data) > 0) {
    tryCatch({
      # Create event type variable
      analysis_data$event_type <- ifelse(analysis_data$`Censor (alive=0; dead=1)` == 1, 1, 0)
      
      # Analyze by grade
      grades <- unique(analysis_data$Grade)
      cat("Competing Risks Analysis by Tumor Grade:\n")
      
      for (grade in grades) {
        grade_data <- analysis_data[analysis_data$Grade == grade, ]
        
        if (nrow(grade_data) > 0) {
          cat("\nGrade:", grade, "(n =", nrow(grade_data), ")\n")
          
          # Calculate CIF for this grade
          cif_grade <- cmprsk::crr(ftime = grade_data$OS, 
                                  fstatus = grade_data$event_type)
          
          # Summary statistics
          events <- sum(grade_data$event_type)
          censored <- sum(grade_data$event_type == 0)
          cat("Events:", events, "| Censored:", censored, "\n")
          
          # Median time to event
          if (events > 0) {
            median_time <- median(grade_data$OS[grade_data$event_type == 1])
            cat("Median time to event:", round(median_time, 1), "months\n")
          }
        }
      }
      
    }, error = function(e) {
      cat("Error in stratified competing risks analysis:", e$message, "\n")
    })
  } else {
    cat("Insufficient data for stratified analysis.\n")
  }
} else {
  cat("Required columns not found for stratified competing risks analysis.\n")
}

# SECTION 4: FINE-GRAY REGRESSION FOR COMPETING RISKS --------

cat("\nSECTION 4: FINE-GRAY REGRESSION\n")
cat("Modeling competing risks with covariates...\n\n")

if (all(c("OS", "Censor (alive=0; dead=1)", "Age", "Gender") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$`Censor (alive=0; dead=1)`) & 
                       !is.na(data$Age) & !is.na(data$Gender), ]
  
  if (nrow(analysis_data) > 0) {
    tryCatch({
      # Create event type variable
      analysis_data$event_type <- ifelse(analysis_data$`Censor (alive=0; dead=1)` == 1, 1, 0)
      
      # Create covariate matrix
      cov_matrix <- model.matrix(~ Age + Gender, data = analysis_data)[, -1]
      
      # Fine-Gray regression
      fg_result <- cmprsk::crr(ftime = analysis_data$OS, 
                              fstatus = analysis_data$event_type,
                              cov1 = cov_matrix)
      
      cat("Fine-Gray Regression Results:\n")
      print(summary(fg_result))
      
      # Interpret coefficients
      cat("\nInterpretation of Fine-Gray Coefficients:\n")
      coef_table <- summary(fg_result)$coef
      
      for (i in 1:nrow(coef_table)) {
        var_name <- rownames(coef_table)[i]
        coef_val <- coef_table[i, "coef"]
        hr <- exp(coef_val)
        p_val <- coef_table[i, "Pr(>|z|)"]
        
        cat(var_name, ":\n")
        cat("  Coefficient:", round(coef_val, 3), "\n")
        cat("  Hazard Ratio:", round(hr, 3), "\n")
        cat("  p-value:", round(p_val, 4), "\n")
        
        if (p_val < 0.05) {
          cat("  Interpretation: Significant predictor\n")
        } else {
          cat("  Interpretation: Not significant\n")
        }
        cat("\n")
      }
      
    }, error = function(e) {
      cat("Error in Fine-Gray regression:", e$message, "\n")
    })
  } else {
    cat("Insufficient data for Fine-Gray regression.\n")
  }
} else {
  cat("Required columns not found for Fine-Gray regression.\n")
}

# SECTION 5: MULTI-STATE MODELS ------------------------------

cat("\nSECTION 5: MULTI-STATE MODELS\n")
cat("Analyzing transitions between different states...\n\n")

if (all(c("OS", "Censor (alive=0; dead=1)", "Grade") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$`Censor (alive=0; dead=1)`) & !is.na(data$Grade), ]
  
  if (nrow(analysis_data) > 0) {
    tryCatch({
      # Create multi-state dataset
      # States: 1 = Alive, 2 = Dead
      analysis_data$state <- ifelse(analysis_data$`Censor (alive=0; dead=1)` == 1, 2, 1)
      
      # Create mstate object
      ms_data <- mstate::msprep(time = c(NA, "OS"), 
                               status = c(NA, "state"), 
                               data = analysis_data, 
                               trans = matrix(c(NA, 1, NA, NA), ncol = 2))
      
      cat("Multi-State Model Setup:\n")
      cat("Number of transitions:", nrow(ms_data), "\n")
      cat("Number of patients:", length(unique(ms_data$id)), "\n")
      
      # Fit multi-state model
      ms_fit <- mstate::msfit(ms_data, trans = 1)
      
      cat("\nMulti-State Model Results:\n")
      print(summary(ms_fit))
      
    }, error = function(e) {
      cat("Error in multi-state modeling:", e$message, "\n")
    })
  } else {
    cat("Insufficient data for multi-state modeling.\n")
  }
} else {
  cat("Required columns not found for multi-state modeling.\n")
}

# SECTION 6: COMPARISON WITH TRADITIONAL SURVIVAL ------------

cat("\nSECTION 6: COMPARISON WITH TRADITIONAL SURVIVAL\n")
cat("Comparing competing risks vs. traditional survival analysis...\n\n")

if (all(c("OS", "Censor (alive=0; dead=1)") %in% names(data))) {
  analysis_data <- data[!is.na(data$OS) & !is.na(data$`Censor (alive=0; dead=1)`), ]
  
  if (nrow(analysis_data) > 0) {
    tryCatch({
      # Traditional Kaplan-Meier
      surv_obj <- Surv(analysis_data$OS, analysis_data$`Censor (alive=0; dead=1)`)
      km_fit <- survfit(surv_obj ~ 1)
      
      # Competing risks
      analysis_data$event_type <- ifelse(analysis_data$`Censor (alive=0; dead=1)` == 1, 1, 0)
      cif_result <- cmprsk::crr(ftime = analysis_data$OS, 
                               fstatus = analysis_data$event_type)
      
      cat("Comparison of Methods:\n")
      cat("Traditional KM - Median survival:", round(median(km_fit)$median, 1), "months\n")
      cat("Competing Risks - CIF at median time:", 
          round(cif_result$est[which.min(abs(cif_result$time - median(km_fit)$median))] * 100, 1), "%\n")
      
      cat("\nKey Differences:\n")
      cat("- KM assumes no competing events\n")
      cat("- CIF accounts for competing risks\n")
      cat("- CIF provides more accurate estimates\n")
      
    }, error = function(e) {
      cat("Error in method comparison:", e$message, "\n")
    })
  } else {
    cat("Insufficient data for method comparison.\n")
  }
} else {
  cat("Required columns not found for method comparison.\n")
}

# PRACTICE TASKS ----------------------------------------------

cat("\n=== PRACTICE TASKS ===\n")
cat("1. Calculate CIF for different tumor grades\n")
cat("2. Perform Fine-Gray regression with Age and Gender\n")
cat("3. Compare CIF vs. KM estimates\n")
cat("4. Create multi-state model for disease progression\n")
cat("5. Interpret competing risks results clinically\n\n")

cat("=== CLINICAL INTERPRETATION TIPS ===\n")
cat("- CIF provides event-specific probabilities\n")
cat("- Fine-Gray models account for competing events\n")
cat("- Multi-state models capture complex transitions\n")
cat("- Consider clinical context when interpreting results\n")
cat("- Report both statistical and clinical significance\n") 
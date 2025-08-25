# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# Load packages and data via utilities
source("R/utils.R")
load_required_packages(c("readxl", "dplyr", "corrplot"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# ===============================================================
# LESSON 10: CORRELATION ANALYSIS BETWEEN NUMERIC VARIABLES
# ===============================================================

# LEARNING OBJECTIVES:
# - Identify relationships between numeric variables
# - Use correlation matrices and plots
# - Interpret positive and negative correlations

# WHAT YOU'LL LEARN:
# Correlation helps you measure the strength and direction of relationships
# between continuous variables — such as Age, Survival Time, or Treatment Use.

# SECTION 1: SELECT NUMERIC DATA --------------------------------

# Check for required numeric columns (standardized names)
numeric_cols <- c("Age", "OS", "Censor", "Chemo_status", "Radio_status")

available_cols <- numeric_cols[numeric_cols %in% names(data)]

if (length(available_cols) < 2) {
  cat("Warning: Need at least 2 numeric columns for correlation analysis.\n")
  cat("Available numeric columns:", paste(available_cols, collapse = ", "), "\n")
} else {
  # Filter only the numeric columns (remove NA rows)
  numeric_data <- data %>%
    dplyr::select(dplyr::all_of(available_cols)) %>%
    stats::na.omit()
  
  cat("Using", ncol(numeric_data), "numeric columns for correlation analysis.\n")
  cat("Sample size after removing NA values:", nrow(numeric_data), "\n")
  
  # SECTION 2: COMPUTE CORRELATION MATRIX --------------------------
  tryCatch({
    corr_matrix <- stats::cor(numeric_data)
    print("Correlation Matrix:")
    print(round(corr_matrix, 3))
    
    # SECTION 3: VISUALIZE WITH CORRPLOT -----------------------------
    cat("\nGenerating correlation plot...\n")
    # Save corrplot to files by opening devices manually
    ensure_plots_dir()
    png(file.path("plots", "Lesson10_Correlation_Matrix.png"), width = 1200, height = 900, res = 150)
    corrplot::corrplot(
      corr_matrix,
      method = "circle",
      type = "upper",
      tl.col = "black",
      tl.srt = 45
    )
    dev.off()
    pdf(file.path("plots", "Lesson10_Correlation_Matrix.pdf"), width = 9, height = 7)
    corrplot::corrplot(
      corr_matrix,
      method = "circle",
      type = "upper",
      tl.col = "black",
      tl.srt = 45
    )
    dev.off()
  }, error = function(e) {
    cat("Error computing correlation matrix:", e$message, "\n")
    cat("This may be due to insufficient data or non-numeric values.\n")
  })
}

# Interpretation Tips:
# - Correlation ranges from -1 (perfect negative) to +1 (perfect positive)
# - 0 means no linear relationship
# - Always check sample size before interpreting!

# PRACTICE TASKS ------------------------------------------------
# 1. Which variables are most positively correlated? Most negatively?
# 2. Do any variables show a surprisingly weak or strong relationship?
# 3. Add a new numeric variable (if available) and re-run the matrix
# 4. Optional: Use cor.test() to test significance of individual correlations
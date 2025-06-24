# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")[["CRAN"]])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# List of required packages
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr", 
                       "corrplot", "car", "psych", "ggpubr", "rstatix")

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
if ("Age" %in% names(data)) data$Age <- as.numeric(data$Age)
if ("OS" %in% names(data)) data$OS <- as.numeric(data$OS)
if ("Censor (alive=0; dead=1)" %in% names(data)) data$`Censor (alive=0; dead=1)` <- as.numeric(data$`Censor (alive=0; dead=1)`)
if ("Chemo_status (TMZ treated=1;un-treated=0)" %in% names(data)) data$`Chemo_status (TMZ treated=1;un-treated=0)` <- as.numeric(data$`Chemo_status (TMZ treated=1;un-treated=0)`)
if ("Radio_status (treated=1;un-treated=0)" %in% names(data)) data$`Radio_status (treated=1;un-treated=0)` <- as.numeric(data$`Radio_status (treated=1;un-treated=0)`)

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

# Check for required numeric columns
numeric_cols <- c("Age", "OS", "Censor (alive=0; dead=1)", 
                  "Chemo_status (TMZ treated=1;un-treated=0)", 
                  "Radio_status (treated=1;un-treated=0)")

available_cols <- numeric_cols[numeric_cols %in% names(data)]

if (length(available_cols) < 2) {
  cat("Warning: Need at least 2 numeric columns for correlation analysis.\n")
  cat("Available numeric columns:", paste(available_cols, collapse = ", "), "\n")
} else {
  # Filter only the numeric columns (adjust if needed)
  numeric_data <- data %>%
    select(all_of(available_cols)) %>%
    na.omit()
  
  cat("Using", ncol(numeric_data), "numeric columns for correlation analysis.\n")
  cat("Sample size after removing NA values:", nrow(numeric_data), "\n")
  
  # SECTION 2: COMPUTE CORRELATION MATRIX --------------------------
  
  # Create a correlation matrix
  tryCatch({
    corr_matrix <- cor(numeric_data)
    print("Correlation Matrix:")
    print(round(corr_matrix, 3))
    
    # SECTION 3: VISUALIZE WITH CORRPLOT -----------------------------
    
    # Visualize the correlation matrix
    cat("\nGenerating correlation plot...\n")
    corrplot(
      corr_matrix,
      method = "circle",
      type = "upper",
      tl.col = "black",
      tl.srt = 45
    )
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

# 4. Optional: Use `cor.test()` to test significance of individual correlations
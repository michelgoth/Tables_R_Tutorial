# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

# ===============================================================
# LESSON 10: EXPLORING RELATIONSHIPS BETWEEN NUMERIC VARIABLES
# ===============================================================
#
# OBJECTIVE:
# To calculate and visualize the correlation between multiple numeric
# variables simultaneously using a correlation matrix and a correlogram.
# This is a key step for understanding potential multicollinearity in models.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
source("R/utils.R")
# 'corrplot' is a specialized package for visualizing correlation matrices.
load_required_packages(c("readxl", "dplyr", "corrplot"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# ===============================================================
# SECTION 1: DATA PREPARATION FOR CORRELATION ANALYSIS --------
# ===============================================================

# Define the set of numeric/binary columns we want to analyze.
# Note: Correlation is typically for continuous variables, but it can be
# calculated for binary (0/1) variables as well.
numeric_cols <- c("Age", "OS", "Censor", "Chemo_status", "Radio_status")
available_cols <- numeric_cols[numeric_cols %in% names(data)]

if (length(available_cols) < 2) {
  cat("Warning: Need at least 2 numeric columns for correlation analysis.\n")
} else {
  # 1. Select only the numeric columns from the main data frame.
  # 2. Remove any rows that have missing values ('NA') in ANY of the selected columns.
  #    Correlation can only be calculated on complete pairs of data.
  numeric_data <- data %>%
    dplyr::select(dplyr::all_of(available_cols)) %>%
    stats::na.omit()

  cat("Sample size after removing NA values:", nrow(numeric_data), "patients\n")

  # ===============================================================
  # SECTION 2: COMPUTE AND VISUALIZE THE CORRELATION MATRIX ------
  #
  # The correlation coefficient ranges from -1 to +1:
  # +1: Perfect positive correlation (as one variable goes up, the other goes up).
  # -1: Perfect negative correlation (as one variable goes up, the other goes down).
  #  0: No linear correlation.
  # ===============================================================
  tryCatch({
    # The 'cor()' function calculates the pairwise correlation for all columns.
    corr_matrix <- stats::cor(numeric_data)
    print("Correlation Matrix:")
    print(round(corr_matrix, 3)) # Rounding for easier reading.

    # --- Visualize with corrplot ---
    # A visual plot is much easier to interpret than a table of numbers.
    cat("\nGenerating correlation plot...\n")
    ensure_plots_dir()
    png(file.path("plots", "Lesson10_Correlation_Matrix.png"), width = 1200, height = 900, res = 150)
    corrplot::corrplot(
      corr_matrix,
      method = "circle", # The size of the circle represents the strength of the correlation.
      type = "upper",    # Only show the upper triangle of the matrix to avoid redundancy.
      tl.col = "black",  # Text label color.
      tl.srt = 45        # Rotate text labels for better readability.
    )
    dev.off() # Close the PNG device.

    pdf(file.path("plots", "Lesson10_Correlation_Matrix.pdf"), width = 9, height = 7)
    corrplot::corrplot(corr_matrix, method = "circle", type = "upper", tl.col = "black", tl.srt = 45)
    dev.off() # Close the PDF device.

  }, error = function(e) {
    cat("Error computing correlation matrix:", e$message, "\n")
  })
}

# ===============================================================
# PRACTICE TASKS ------------------------------------------------
# ===============================================================

# 1. Look at the plot. Which two variables have the strongest positive correlation?
#    Which two have the strongest negative correlation?

# 2. Why is there a perfect diagonal line of dark blue circles?

# 3. Add a new numeric variable to the 'numeric_cols' list (if one exists in the
#    dataset that you find interesting) and re-run the script.

# 4. To get a p-value for a single correlation, you can use `cor.test()`.
#    Try it: `cor.test(numeric_data$Age, numeric_data$OS)`
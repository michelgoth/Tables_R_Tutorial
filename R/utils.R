# ===============================================================
# UTILITY FUNCTIONS FOR CLINICAL DATA ANALYSIS TUTORIALS
#
# This script contains helper functions that are used across multiple
# lessons. Sourcing this file (`source("R/utils.R")`) makes these
# functions available in your R session, which helps keep the main
# lesson scripts cleaner and more focused on the analysis itself.
# ===============================================================

#' @title Load Required R Packages
#' @description Checks if a vector of packages are installed and loads them.
#'   Stops with an error if a package is missing.
#' @param packages A character vector of package names.
load_required_packages <- function(packages) {
  for (pkg in packages) {
    # 'require' is used inside functions to load packages.
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      stop(paste0("Package not available: ", pkg, ". Please run source('R/setup.R') first."))
    }
  }
}

#' @title Load and Preprocess Clinical Data
#' @description Reads the clinical dataset from an Excel file, standardizes
#'   column names, converts columns to the correct data types (numeric/factor),
#'   and performs basic data validation.
#' @param path The file path to the clinical data Excel file.
#' @return A preprocessed data frame.
load_clinical_data <- function(path = "Data/ClinicalData.xlsx") {
  if (!file.exists(path)) {
    stop(paste0("ERROR: Data file not found at", path))
  }
  df <- readxl::read_excel(path)

  # --- Standardize Column Names ---
  # Renames verbose columns to shorter, more script-friendly names.
  rename_map <- c(
    "Censor (alive=0; dead=1)" = "Censor",
    "Chemo_status (TMZ treated=1;un-treated=0)" = "Chemo_status",
    "Radio_status (treated=1;un-treated=0)" = "Radio_status"
  )
  names(df) <- dplyr::recode(names(df), !!!rename_map)

  # --- Set Correct Data Types ---
  # Ensure numeric columns are stored as numbers and categorical as factors.
  numeric_cols <- c("Age", "OS", "Censor", "Chemo_status", "Radio_status")
  for (col in numeric_cols) {
    if (col %in% names(df)) df[[col]] <- as.numeric(df[[col]])
  }
  factor_cols <- c("Grade", "Gender", "PRS_type", "IDH_mutation_status", "MGMTp_methylation_status")
  for (col in factor_cols) {
    if (col %in% names(df)) {
      # Convert text "NA", "Unknown" etc. to proper NA values.
      clean_vals <- dplyr::na_if(as.character(df[[col]]), "NA")
      clean_vals <- dplyr::na_if(clean_vals, "Unknown")
      df[[col]] <- factor(clean_vals)
    }
  }

  # --- Basic Data Validation ---
  if (all(c("OS", "Censor") %in% names(df))) {
    if (any(df$OS < 0, na.rm = TRUE)) warning("OS contains negative values.")
    if (!all(df$Censor %in% c(0, 1, NA))) warning("Censor column should only contain 0, 1, or NA.")
  }
  return(df)
}

#' @title Convert Days to Months
#' @description A simple helper to make plot axes more readable.
#' @param days A numeric value or vector of days.
#' @return The equivalent number of months.
to_months <- function(days) {
  days / 30.4375
}

#' @title Ensure the 'plots' Directory Exists
#' @description Checks for the 'plots' directory and creates it if it doesn't exist.
ensure_plots_dir <- function(path = "plots") {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
}

#' @title Save a ggplot to Both PNG and PDF
#' @description A convenience function to save a plot in two common formats.
#' @param plot_obj The ggplot object to save.
#' @param base_filename The base name for the output file (without extension).
save_plot_both <- function(plot_obj, base_filename, path = "plots", width = 8, height = 6) {
  ensure_plots_dir(path)
  ggplot2::ggsave(file.path(path, paste0(base_filename, ".png")), plot = plot_obj, width = width, height = height, dpi = 300)
  ggplot2::ggsave(file.path(path, paste0(base_filename, ".pdf")), plot = plot_obj, width = width, height = height)
}

#' Save a list of ggplot objects to both PDF and PNG formats.
#'
#' This function iterates over a list of ggplot objects and saves each one
#' as both a PDF and a PNG file in the 'plots' directory.
#'
#' @param plot_list A list of ggplot objects.
#' @param base_filename The base name for the output files.
#' @return Invisible NULL.
save_plot_list_both <- function(plot_list, base_filename) {
  # Ensure the 'plots' directory exists.
  ensure_plots_dir()
  # Loop through the list of plots
  for (i in seq_along(plot_list)) {
    # Create a unique filename for each plot
    filename_with_index <- paste0(base_filename, "_", i)
    pdf_path <- file.path("plots", paste0(filename_with_index, ".pdf"))
    png_path <- file.path("plots", paste0(filename_with_index, ".png"))

    # Save to PDF
    ggplot2::ggsave(
      pdf_path,
      plot = plot_list[[i]],
      width = 8,
      height = 6,
      units = "in",
      device = "pdf"
    )

    # Save to PNG
    ggplot2::ggsave(
      png_path,
      plot = plot_list[[i]],
      width = 1200,
      height = 900,
      units = "px",
      dpi = 150,
      bg = "white"
    )
  }
}

#' Impute Missing Clinical Data
#'
#' @description
#' This function takes the raw clinical data and uses multiple imputation
#' via the `mice` package to fill in missing values.
#'
#' @param df The raw clinical data frame from `load_clinical_data`.
#' @param seed A random seed for reproducibility.
#' @return A data frame with missing values imputed.
impute_clinical_data <- function(df, seed = 123) {
  load_required_packages("mice")
  
  # Store Patient_ID and other non-imputed columns to re-attach later
  patient_ids <- df$CGGA_ID
  gender_col <- df$Gender
  
  # Select columns for imputation
  vars_to_impute <- c(
    "PRS_type", "Grade", "Age", "OS", "Censor", "Histology",
    "Radio_status", "Chemo_status", "IDH_mutation_status",
    "MGMTp_methylation_status"
  )
  imputable_df <- df[, names(df) %in% vars_to_impute]
  
  # Run the MICE algorithm
  imputed_data <- mice(imputable_df, m = 5, maxit = 5, method = 'pmm', seed = seed, printFlag = FALSE)
  
  # Get the first completed dataset
  df_complete <- complete(imputed_data, 1)
  
  # Add the preserved columns back
  df_complete$Patient_ID <- patient_ids
  df_complete$Gender <- gender_col

  # --- Re-apply Data Types ---
  numeric_cols <- c("Age", "OS", "Censor", "Chemo_status", "Radio_status")
  for (col in numeric_cols) {
    if (col %in% names(df_complete)) df_complete[[col]] <- as.numeric(df_complete[[col]])
  }
  factor_cols <- c("Grade", "PRS_type","Histology", "IDH_mutation_status", "MGMTp_methylation_status")
  for (col in factor_cols) {
    if (col %in% names(df_complete)) {
      df_complete[[col]] <- factor(df_complete[[col]])
    }
  }           
  
  return(df_complete)
}

#' @title A Consistent ggplot2 Theme for Clinical Plots
#' @description Creates a clean, minimal theme to be applied to all plots
#'   for a consistent and professional look.
clinical_theme <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0),
      legend.position = "right",
      panel.grid.minor = ggplot2::element_blank()
    )
}

#' @title Print Session Information for Reproducibility
#' @description Prints the R version and loaded package versions, which is
#'   crucial for documenting the environment in which an analysis was run.
print_session_info <- function() {
  cat("\n--- Session Info ---\n")
  print(utils::sessionInfo())
}

# --- Transcriptomic Helper Functions ---

#' Load RNA-seq Data
load_rnaseq_data <- function(file_path) {
  df <- read.delim(file_path, row.names = 1, check.names = FALSE)
  rownames(df) <- sub("_.*", "", rownames(df))
  return(df)
}

#' Integrate Clinical and RNA-seq Data
integrate_data <- function(clinical_df, rnaseq_df) {
  common_samples <- intersect(clinical_df$Patient_ID, colnames(rnaseq_df))
  
  clinical_df <- clinical_df[clinical_df$Patient_ID %in% common_samples, ]
  rnaseq_df <- rnaseq_df[, common_samples]
  
  clinical_df <- clinical_df[order(clinical_df$Patient_ID), ]
  rnaseq_df <- rnaseq_df[, order(colnames(rnaseq_df))]
  
  load_required_packages("DESeq2")
  
  # Create a DESeqDataSet object with the clinical data in the colData slot
  dds <- DESeqDataSetFromMatrix(
    countData = round(rnaseq_df),
    colData = clinical_df, # Use the actual clinical data here
    design = ~ 1
  )
  
  # Apply the VST
  vsd <- vst(dds, blind = TRUE)
  
  return(list(
    clinical = clinical_df, 
    vst_counts = assay(vsd), 
    vsd = vsd,
    raw_counts = as.matrix(round(rnaseq_df)) # Ensure output is a matrix
  ))
}



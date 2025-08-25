# ===============================================================
# Utilities for Clinical Data Analysis Tutorials
# ===============================================================

# load_required_packages: quietly loads required libraries (assumes setup.R ran)
load_required_packages <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      stop(paste0("Package not available: ", pkg, ". Run source('R/setup.R') first."))
    }
  }
}

# load_clinical_data: reads dataset, standardizes names/types, and returns data.frame
load_clinical_data <- function(path = "Data/ClinicalData.xlsx") {
  if (!file.exists(path)) {
    stop(paste0("ERROR: Data file not found at ", path, ". Please ensure the file exists."))
  }

  df <- tryCatch({
    readxl::read_excel(path)
  }, error = function(e) {
    stop(paste0("ERROR: Could not read data file: ", e$message))
  })

  # Normalize known verbose column names to canonical names
  rename_map <- c(
    "Censor (alive=0; dead=1)" = "Censor",
    "Chemo_status (TMZ treated=1;un-treated=0)" = "Chemo_status",
    "Radio_status (treated=1;un-treated=0)" = "Radio_status"
  )

  common_old <- intersect(names(rename_map), names(df))
  if (length(common_old) > 0) {
    names(df)[match(common_old, names(df))] <- unname(rename_map[common_old])
  }

  # Coerce types where applicable (ignore missing columns gracefully)
  if ("Age" %in% names(df)) df$Age <- suppressWarnings(as.numeric(df$Age))
  if ("OS" %in% names(df)) df$OS <- suppressWarnings(as.numeric(df$OS))
  if ("Censor" %in% names(df)) df$Censor <- suppressWarnings(as.numeric(df$Censor))
  if ("Chemo_status" %in% names(df)) df$Chemo_status <- suppressWarnings(as.numeric(df$Chemo_status))
  if ("Radio_status" %in% names(df)) df$Radio_status <- suppressWarnings(as.numeric(df$Radio_status))

  factorize <- c("Grade", "Gender", "PRS_type", "IDH_mutation_status",
                 "MGMTp_methylation_status", "Histology", "1p19q_codeletion_status")
  for (col in factorize) {
    if (col %in% names(df)) df[[col]] <- as.factor(df[[col]])
  }

  # Basic validation for survival analysis
  if (all(c("OS", "Censor") %in% names(df))) {
    if (any(df$OS < 0, na.rm = TRUE)) warning("OS contains negative values; verify time units (days expected)")
    if (!all(df$Censor %in% c(0, 1, NA))) warning("Censor should be 0/1; found other values")
  }

  df
}

# to_months: helper to convert days to months for display/plot labels
to_months <- function(days) {
  days / 30.4375
}

# Ensure plots directory exists
ensure_plots_dir <- function(path = "plots") {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)
  invisible(path)
}

# Save a ggplot to both PNG and PDF
save_plot_both <- function(plot_obj, base_filename, path = "plots", width = 8, height = 6, dpi = 300) {
  ensure_plots_dir(path)
  png_path <- file.path(path, paste0(base_filename, ".png"))
  pdf_path <- file.path(path, paste0(base_filename, ".pdf"))
  ggplot2::ggsave(png_path, plot = plot_obj, width = width, height = height, dpi = dpi)
  ggplot2::ggsave(pdf_path, plot = plot_obj, width = width, height = height)
  invisible(list(png = png_path, pdf = pdf_path))
}



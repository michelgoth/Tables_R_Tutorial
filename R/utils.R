# ===============================================================
# Utilities for Clinical Data Analysis Tutorials
# ===============================================================

# load_required_packages: quietly loads required libraries (assumes setup.R ran)
load_required_packages <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      stop(paste0("Package not available: ", pkg, ". Run source('R/setup.R') first."))
    }
    if (pkg == "ggplot2") {
      # Set a consistent clinical theme when ggplot2 is available
      if (exists("clinical_theme", mode = "function")) {
        ggplot2::theme_set(clinical_theme())
      }
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

  # Convert literal "NA" factor levels to actual NA to avoid plotting as a category
  for (col in factorize) {
    if (col %in% names(df)) {
      tmp <- as.character(df[[col]])
      tmp[tmp == "NA" | tmp == "Unknown" | tmp == "Not Available"] <- NA
      df[[col]] <- droplevels(factor(tmp))
    }
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


# filter_complete_cases: drop rows with NA in specified columns (safe for missing cols)
filter_complete_cases <- function(df, cols) {
  use_cols <- cols[cols %in% names(df)]
  if (length(use_cols) == 0) return(df)
  cc <- stats::complete.cases(df[, use_cols, drop = FALSE])
  df[cc, , drop = FALSE]
}


# clinical_theme: consistent plotting theme for all figures
clinical_theme <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0, margin = ggplot2::margin(b = 6)),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 6)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 6)),
      legend.position = "right",
      panel.grid.minor = ggplot2::element_blank()
    )
}

# print_session_info: helper to log session details at lesson end
print_session_info <- function() {
  try({
    cat("\n--- Session Info ---\n")
    print(sessionInfo())
  }, silent = TRUE)
}



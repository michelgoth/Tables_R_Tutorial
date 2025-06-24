# ===============================================================
# SETUP SCRIPT: Install Required Packages for Clinical Data Analysis
# ===============================================================
# 
# This script installs all necessary R packages for the Clinical Data
# Analysis tutorial series. Run this script once before starting the lessons.
#
# Author: Clinical Data Analysis Tutorial Team
# Date: 2024
# ===============================================================

# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")[["CRAN"]])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

cat("🧬 Setting up Clinical Data Analysis Environment...\n\n")

# SECTION 1: CHECK R VERSION --------------------------------------
cat("📊 Checking R version...\n")
r_version <- R.version.string
cat("Current R version:", r_version, "\n")

# Check if R version is 4.0 or higher
r_major <- as.numeric(R.version$major)
r_minor <- as.numeric(R.version$minor)
r_version_numeric <- r_major + (r_minor / 10)

if (is.na(r_version_numeric) || r_version_numeric < 4.0) {
  warning("⚠️  R version 4.0 or higher is recommended for this tutorial series.\n")
} else {
  cat("✅ R version is compatible!\n")
}

# SECTION 2: DEFINE REQUIRED PACKAGES ----------------------------
cat("\n📦 Installing required packages...\n")

# Core data manipulation and visualization
core_packages <- c(
  "readxl",      # Excel file reading
  "ggplot2",     # Advanced plotting
  "dplyr",       # Data manipulation
  "tidyr",       # Data tidying
  "stringr"      # String manipulation
)

# Statistical analysis packages
stats_packages <- c(
  "survival",    # Survival analysis
  "survminer",   # Survival visualization
  "rstatix",     # Statistical testing
  "car",         # Regression diagnostics
  "psych"        # Descriptive statistics
)

# Visualization packages
viz_packages <- c(
  "ggpubr",      # Publication-ready plots
  "corrplot",    # Correlation matrices
  "RColorBrewer", # Color palettes
  "scales"       # Scale functions for ggplot2
)

# Combine all packages
all_packages <- c(core_packages, stats_packages, viz_packages)

# SECTION 3: INSTALL PACKAGES ------------------------------------
cat("Installing packages...\n")

# Function to install packages with error handling
install_packages_safely <- function(packages) {
  for (pkg in packages) {
    cat("Installing", pkg, "... ")
    
    # Check if package is already installed
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      tryCatch({
        install.packages(pkg, dependencies = TRUE, quiet = TRUE)
        cat("✅\n")
      }, error = function(e) {
        cat("❌ Failed to install", pkg, "\n")
        cat("Error:", e$message, "\n")
      })
    } else {
      cat("✅ (already installed)\n")
    }
  }
}

# Install packages
install_packages_safely(all_packages)

# SECTION 4: VERIFY INSTALLATION ---------------------------------
cat("\n🔍 Verifying package installation...\n")

# Check which packages are successfully loaded
loaded_packages <- c()
failed_packages <- c()

for (pkg in all_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    loaded_packages <- c(loaded_packages, pkg)
  } else {
    failed_packages <- c(failed_packages, pkg)
  }
}

# Report results
cat("✅ Successfully loaded packages:", length(loaded_packages), "/", length(all_packages), "\n")
if (length(failed_packages) > 0) {
  cat("❌ Failed to load packages:", paste(failed_packages, collapse = ", "), "\n")
  cat("Try running: install.packages(c(", paste0('"', failed_packages, '"', collapse = ", "), "))\n")
}

# SECTION 5: SETUP COMPLETION ------------------------------------
cat("\n🎉 Setup complete!\n\n")

if (length(failed_packages) == 0) {
  cat("✅ All packages installed successfully!\n")
  cat("🚀 You're ready to start the tutorial series.\n")
  cat("📚 Begin with Lesson 1: R/Lesson1.R\n\n")
} else {
  cat("⚠️  Some packages failed to install.\n")
  cat("Please check the error messages above and try installing them manually.\n\n")
}

# SECTION 6: HELPFUL COMMANDS ------------------------------------
cat("💡 Helpful commands for getting started:\n")
cat("   • getwd()                    # Check current working directory\n")
cat("   • list.files()               # List files in current directory\n")
cat("   • ?function_name             # Get help for any function\n")
cat("   • sessionInfo()              # View loaded packages and R version\n\n")

# SECTION 7: NEXT STEPS ------------------------------------------
cat("📋 Next steps:\n")
cat("1. Make sure your working directory contains the Data/ folder\n")
cat("2. Open R/Lesson1.R in RStudio\n")
cat("3. Follow along with the comments and complete practice tasks\n")
cat("4. Check progress_tracker.md to track your learning\n\n")

cat("🎓 Happy learning! 🧬\n") 
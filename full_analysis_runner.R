# ===============================================================
# FULL ANALYSIS RUNNER
# ===============================================================
# This script runs all lessons sequentially for a complete analysis

cat("Starting full analysis pipeline...\n\n")

# Run all lessons in sequence
for (i in 1:24) {
  lesson_file <- file.path("R", paste0("Lesson", i, ".R"))
  if (file.exists(lesson_file)) {
    cat("Running Lesson", i, "...\n")
    source(lesson_file)
    cat("Lesson", i, "completed.\n\n")
  } else {
    cat("Lesson", i, "not found. Skipping...\n\n")
  }
}

cat("Full analysis pipeline completed!\n")

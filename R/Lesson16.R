# ===============================================================
# LESSON 16: Radiotherapy adjusted survival analysis
# ===============================================================

source("R/utils.R")
load_required_packages(c("dplyr", "ggplot2", "survival"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

cat("=== LESSON 16: Radiotherapy adjusted analysis ===\n")
cat("Sample size:", nrow(data), "patients\n\n")

required_cols <- c("OS", "Censor", "Radio_status")
missing_cols <- setdiff(required_cols, names(data))
if (length(missing_cols) > 0) {
  cat("Missing required columns:", paste(missing_cols, collapse = ", "), "\n")
  quit(save = "no")
}

df <- data %>%
  dplyr::mutate(Radio_factor = factor(Radio_status, levels = c(0, 1), labels = c("No RT", "RT"))) %>%
  dplyr::filter(!is.na(OS) & !is.na(Censor) & !is.na(Radio_factor))

cat("Counts by Radiotherapy:\n")
print(table(df$Radio_factor))

# Descriptive KM
surv_obj <- Surv(time = df$OS, event = df$Censor)
fit_km <- survfit(surv_obj ~ Radio_factor, data = df)

ensure_plots_dir()
png(file.path("plots", "Lesson16_KM_Radiotherapy.png"), width = 1200, height = 900, res = 150)
plot(fit_km, col = c("firebrick", "forestgreen"), lwd = 2,
     xlab = "Time (days)", ylab = "Survival Probability",
     main = "KM: Radiotherapy vs No RT")
legend("topright", legend = levels(df$Radio_factor), col = c("firebrick", "forestgreen"), lwd = 2)
dev.off()
pdf(file.path("plots", "Lesson16_KM_Radiotherapy.pdf"), width = 9, height = 7)
plot(fit_km, col = c("firebrick", "forestgreen"), lwd = 2,
     xlab = "Time (days)", ylab = "Survival Probability",
     main = "KM: Radiotherapy vs No RT")
legend("topright", legend = levels(df$Radio_factor), col = c("firebrick", "forestgreen"), lwd = 2)
dev.off()

# Adjusted Cox
adj_vars <- intersect(c("Age", "Grade", "IDH_mutation_status", "MGMTp_methylation_status"), names(df))
cox_formula <- as.formula(paste(
  "surv_obj ~ Radio_factor",
  if (length(adj_vars) > 0) paste("+", paste(adj_vars, collapse = " + ")) else ""
))

fit <- tryCatch(coxph(cox_formula, data = df), error = function(e) NULL)
if (!is.null(fit)) {
  s <- summary(fit)
  coefs <- as.data.frame(s$coef)
  coefs$Term <- rownames(coefs)
  forest_df <- coefs[grepl("^Radio_factor", coefs$Term), , drop = FALSE]
  if (nrow(forest_df) > 0) {
    forest_df$HR <- forest_df$`exp(coef)`
    forest_df$Lower <- exp(log(forest_df$HR) - 1.96 * forest_df$`se(coef)`)
    forest_df$Upper <- exp(log(forest_df$HR) + 1.96 * forest_df$`se(coef)`)
    forest_df$Display <- gsub("Radio_factor", "RT vs No RT: ", forest_df$Term, fixed = TRUE)
    p_forest <- ggplot(forest_df, aes(x = HR, y = reorder(Display, HR))) +
      geom_point(color = "steelblue") +
      geom_errorbarh(aes(xmin = Lower, xmax = Upper), height = 0.2, color = "steelblue") +
      geom_vline(xintercept = 1, linetype = "dashed", color = "gray50") +
      scale_x_log10() +
      theme_minimal() +
      labs(title = "Adjusted HR: Radiotherapy", x = "Hazard Ratio (log)", y = "Term")
    print(p_forest)
    save_plot_both(p_forest, base_filename = "Lesson16_Forest_Radiotherapy_Adjusted")
  } else {
    cat("No radiotherapy term found to plot.\n")
  }
} else {
  cat("Cox model failed; forest plot skipped.\n")
}

cat("Lesson 16 completed. Plots saved to plots/.\n")



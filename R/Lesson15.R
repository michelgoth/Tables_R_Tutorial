# ===============================================================
# LESSON 15: Temozolomide benefit and MGMT interaction
# ===============================================================

source("R/utils.R")
load_required_packages(c("dplyr", "ggplot2", "survival"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

cat("=== LESSON 15: TMZ × MGMT Interaction ===\n")
cat("Sample size:", nrow(data), "patients\n\n")

required_cols <- c("OS", "Censor", "Chemo_status", "MGMTp_methylation_status")
missing_cols <- setdiff(required_cols, names(data))
if (length(missing_cols) > 0) {
  cat("Missing required columns:", paste(missing_cols, collapse = ", "), "\n")
  quit(save = "no")
}

df <- data %>%
  dplyr::mutate(
    Chemo_factor = factor(Chemo_status, levels = c(0, 1), labels = c("No TMZ", "TMZ"))
  ) %>%
  dplyr::filter(!is.na(OS) & !is.na(Censor) & !is.na(Chemo_factor) & !is.na(MGMTp_methylation_status)) %>%
  droplevels()

cat("Counts by MGMT and TMZ:\n")
print(with(df, table(MGMTp_methylation_status, Chemo_factor)))

# KM stratified by MGMT, comparing TMZ vs No TMZ within each MGMT group
ensure_plots_dir()
for (lvl in levels(df$MGMTp_methylation_status)) {
  dfi <- df[df$MGMTp_methylation_status == lvl, ]
  if (nrow(dfi) < 5) next
  surv_obj <- Surv(time = dfi$OS, event = dfi$Censor)
  fit_km <- survfit(surv_obj ~ Chemo_factor, data = dfi)
  base_name <- paste0("Lesson15_KM_Treatment_by_MGMT_", gsub("[^A-Za-z0-9]+", "_", lvl))
  png(file.path("plots", paste0(base_name, ".png")), width = 1200, height = 900, res = 150)
  plot(fit_km, col = c("firebrick", "forestgreen"), lwd = 2,
       xlab = "Time (days)", ylab = "Survival Probability",
       main = paste0("KM: TMZ vs No TMZ (", lvl, ")"))
  legend("topright", legend = levels(dfi$Chemo_factor), col = c("firebrick", "forestgreen"), lwd = 2)
  dev.off()
  pdf(file.path("plots", paste0(base_name, ".pdf")), width = 9, height = 7)
  plot(fit_km, col = c("firebrick", "forestgreen"), lwd = 2,
       xlab = "Time (days)", ylab = "Survival Probability",
       main = paste0("KM: TMZ vs No TMZ (", lvl, ")"))
  legend("topright", legend = levels(dfi$Chemo_factor), col = c("firebrick", "forestgreen"), lwd = 2)
  dev.off()
}

# Cox model with interaction: Chemo × MGMT, adjusted for Age and Grade if present
adj_vars <- intersect(c("Age", "Grade"), names(df))
surv_obj_all <- Surv(time = df$OS, event = df$Censor)
cox_formula <- as.formula(paste(
  "surv_obj_all ~ Chemo_factor * MGMTp_methylation_status",
  if (length(adj_vars) > 0) paste("+", paste(adj_vars, collapse = " + ")) else ""
))

fit <- tryCatch(coxph(cox_formula, data = df), error = function(e) NULL)

if (!is.null(fit)) {
  s <- summary(fit)
  coefs <- as.data.frame(s$coef)
  coefs$Term <- rownames(coefs)
  # Keep main Chemo term and interaction terms for forest
  keep <- grepl("^Chemo_factor", coefs$Term) | grepl(":", coefs$Term)
  forest_df <- coefs[keep, , drop = FALSE]
  if (nrow(forest_df) > 0) {
    forest_df$HR <- forest_df$`exp(coef)`
    forest_df$Lower <- exp(log(forest_df$HR) - 1.96 * forest_df$`se(coef)`)
    forest_df$Upper <- exp(log(forest_df$HR) + 1.96 * forest_df$`se(coef)`)
    forest_df$Display <- forest_df$Term
    p_forest <- ggplot(forest_df, aes(x = HR, y = reorder(Display, HR))) +
      geom_point(color = "steelblue") +
      geom_errorbarh(aes(xmin = Lower, xmax = Upper), height = 0.2, color = "steelblue") +
      geom_vline(xintercept = 1, linetype = "dashed", color = "gray50") +
      scale_x_log10() +
      theme_minimal() +
      labs(title = "Cox: TMZ main and Chemo×MGMT interaction", x = "Hazard Ratio (log)", y = "Term")
    print(p_forest)
    save_plot_both(p_forest, base_filename = "Lesson15_Forest_Treatment_Interaction")
  } else {
    cat("No treatment/interaction terms found to plot.\n")
  }
} else {
  cat("Cox model failed; forest plot skipped.\n")
}

cat("Lesson 15 completed. Plots saved to plots/.\n")



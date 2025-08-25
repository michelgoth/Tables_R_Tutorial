# ===============================================================
# LESSON 14: Joint Risk Groups – IDH mutation × MGMT methylation
# ===============================================================

source("R/utils.R")
load_required_packages(c("dplyr", "ggplot2", "survival"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

cat("=== LESSON 14: IDH × MGMT Joint Risk Groups ===\n")
cat("Sample size:", nrow(data), "patients\n\n")

required_cols <- c("OS", "Censor", "IDH_mutation_status", "MGMTp_methylation_status")
if (!all(required_cols %in% names(data))) {
  cat("Missing required columns:", paste(setdiff(required_cols, names(data)), collapse = ", "), "\n")
  quit(save = "no")
}

# Build joint groups (drop rows with missing IDH or MGMT for these analyses)
df <- data %>%
  dplyr::filter(!is.na(IDH_mutation_status) & !is.na(MGMTp_methylation_status) & !is.na(OS) & !is.na(Censor)) %>%
  droplevels() %>%
  dplyr::mutate(
    IDH_chr = as.character(IDH_mutation_status),
    MGMT_chr = as.character(MGMTp_methylation_status),
    JointGroup = factor(paste0("IDH=", IDH_chr, " | MGMT=", MGMT_chr))
  )

cat("Joint group counts:\n")
print(table(df$JointGroup))

# KM by joint group (base plotting to avoid extra deps)
surv_obj <- Surv(time = df$OS, event = df$Censor)
fit_km <- survfit(surv_obj ~ JointGroup, data = df)

ensure_plots_dir()
png(file.path("plots", "Lesson14_KM_by_IDH_MGMT.png"), width = 1400, height = 1000, res = 150)
plot(fit_km, col = rainbow(nlevels(df$JointGroup)), lwd = 2,
     xlab = "Time (days)", ylab = "Survival Probability",
     main = "KM: Joint Groups (IDH × MGMT)")
legend("topright", legend = levels(df$JointGroup), col = rainbow(nlevels(df$JointGroup)), lwd = 2, cex = 0.9)
dev.off()
pdf(file.path("plots", "Lesson14_KM_by_IDH_MGMT.pdf"), width = 10, height = 7.5)
plot(fit_km, col = rainbow(nlevels(df$JointGroup)), lwd = 2,
     xlab = "Time (days)", ylab = "Survival Probability",
     main = "KM: Joint Groups (IDH × MGMT)")
legend("topright", legend = levels(df$JointGroup), col = rainbow(nlevels(df$JointGroup)), lwd = 2)
dev.off()

# Adjusted Cox with group as factor (adjust for Age, Grade if available)
adj_vars <- intersect(c("Age", "Grade"), names(df))
cox_formula <- as.formula(paste("surv_obj ~ JointGroup",
                                if (length(adj_vars) > 0) paste("+", paste(adj_vars, collapse = " + ")) else ""))
fit_cox <- tryCatch(coxph(cox_formula, data = df), error = function(e) NULL)

if (!is.null(fit_cox)) {
  s <- summary(fit_cox)
  coefs <- as.data.frame(s$coef)
  coefs$Term <- rownames(coefs)
  # Keep JointGroup terms only for the forest
  forest_df <- coefs[grepl("^JointGroup", coefs$Term), , drop = FALSE]
  if (nrow(forest_df) > 0) {
    forest_df$HR <- forest_df$`exp(coef)`
    forest_df$Lower <- exp(log(forest_df$HR) - 1.96 * forest_df$`se(coef)`)
    forest_df$Upper <- exp(log(forest_df$HR) + 1.96 * forest_df$`se(coef)`)
    forest_df$Display <- gsub("JointGroup", "", forest_df$Term, fixed = TRUE)

    p_forest <- ggplot(forest_df, aes(x = HR, y = reorder(Display, HR))) +
      geom_point(color = "steelblue") +
      geom_errorbarh(aes(xmin = Lower, xmax = Upper), height = 0.2, color = "steelblue") +
      geom_vline(xintercept = 1, linetype = "dashed", color = "gray50") +
      scale_x_log10() +
      theme_minimal() +
      labs(title = "Adjusted HRs by Joint Group (ref group implicit)", x = "Hazard Ratio (log scale)", y = "IDH | MGMT")
    print(p_forest)
    save_plot_both(p_forest, base_filename = "Lesson14_Forest_IDH_MGMT")
  } else {
    cat("No JointGroup terms found in Cox model output.\n")
  }
} else {
  cat("Adjusted Cox model failed; forest plot skipped.\n")
}

cat("Lesson 14 completed. Plots saved to plots/.\n")



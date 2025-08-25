# ===============================================================
# LESSON 17: Parsimonious bedside prognostic score
# ===============================================================

source("R/utils.R")
load_required_packages(c("dplyr", "ggplot2", "survival"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

cat("=== LESSON 17: Parsimonious prognostic score ===\n")
cat("Sample size:", nrow(data), "patients\n\n")

required_cols <- c("OS", "Censor")
if (!all(required_cols %in% names(data))) {
  cat("Missing required survival columns.\n")
  quit(save = "no")
}

# Candidate predictors
predictors <- intersect(c("Age", "Grade", "IDH_mutation_status", "MGMTp_methylation_status"), names(data))
if (length(predictors) < 2) {
  cat("Not enough predictors available.\n")
  quit(save = "no")
}

# Complete-case subset
cc_idx <- complete.cases(data[, predictors]) & !is.na(data$OS) & !is.na(data$Censor)
df <- data[cc_idx, ]
surv_obj <- Surv(time = df$OS, event = df$Censor)

fml <- as.formula(paste("surv_obj ~", paste(predictors, collapse = " + ")))
fit <- tryCatch(coxph(fml, data = df), error = function(e) NULL)
if (is.null(fit)) {
  cat("Cox fit failed.\n")
  quit(save = "no")
}

s <- summary(fit)
coefs <- as.data.frame(s$coef)
coefs$Term <- rownames(coefs)

# Convert coefficients to simple integer points
# Reference category has 0; positive beta increases risk.
beta <- coefs$coef
names(beta) <- coefs$Term
scale_factor <- 5 / max(abs(beta[is.finite(beta)]), na.rm = TRUE)
points <- round(beta * scale_factor)

# Build a points table for each predictor level
point_map <- data.frame(Term = names(points), Points = as.integer(points), stringsAsFactors = FALSE)
cat("Point assignments (scaled integers):\n")
print(point_map)

# Compute linear predictor and point total per patient
lp <- as.numeric(predict(fit, type = "lp"))
df$Score <- round((lp - min(lp, na.rm = TRUE)) / (max(lp, na.rm = TRUE) - min(lp, na.rm = TRUE)) * 100)

# Risk strata by tertiles of Score
df$RiskStratum <- cut(df$Score, breaks = quantile(df$Score, probs = c(0, 1/3, 2/3, 1), na.rm = TRUE),
                      labels = c("Low", "Medium", "High"), include.lowest = TRUE)

# KM by risk strata
fit_km <- survfit(Surv(OS, Censor) ~ RiskStratum, data = df)
ensure_plots_dir()
png(file.path("plots", "Lesson17_Score_KM_by_Tertile.png"), width = 1200, height = 900, res = 150)
plot(fit_km, col = c("forestgreen", "goldenrod", "firebrick"), lwd = 2,
     xlab = "Time (days)", ylab = "Survival Probability",
     main = "KM: Parsimonious Score (tertiles)")
legend("topright", legend = levels(df$RiskStratum), col = c("forestgreen", "goldenrod", "firebrick"), lwd = 2)
dev.off()
pdf(file.path("plots", "Lesson17_Score_KM_by_Tertile.pdf"), width = 9, height = 7)
plot(fit_km, col = c("forestgreen", "goldenrod", "firebrick"), lwd = 2,
     xlab = "Time (days)", ylab = "Survival Probability",
     main = "KM: Parsimonious Score (tertiles)")
legend("topright", legend = levels(df$RiskStratum), col = c("forestgreen", "goldenrod", "firebrick"), lwd = 2)
dev.off()

# Export a simple scorecard table figure
score_tbl <- point_map %>% dplyr::arrange(desc(Points))
p_tbl <- ggplot(score_tbl, aes(x = reorder(Term, Points), y = Points)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Scorecard (scaled Cox coefficients)", x = "Term", y = "Points")
print(p_tbl)
save_plot_both(p_tbl, base_filename = "Lesson17_Scorecard_Table")

cat("Lesson 17 completed. Plots saved to plots/.\n")



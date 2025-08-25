# Set default CRAN mirror for non-interactive mode
if (!interactive() && is.null(getOption("repos")["CRAN"])) {
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
}

source("R/utils.R")
load_required_packages(c("readxl", "dplyr", "ggplot2", "survival"))

data <- load_clinical_data("Data/ClinicalData.xlsx")

# ===============================================================
# LESSON 12: CLINICIAN-FOCUSED SURVIVAL EXTENSIONS (ON THIS DATASET)
# ===============================================================

cat("=== LESSON 12: CLINICIAN SURVIVAL EXTENSIONS ===\n")
cat("Sample size:", nrow(data), "patients\n")
cat("Available variables:", paste(names(data), collapse = ", "), "\n\n")

# SECTION 1: BASELINE SUMMARY (TABLE 1 STYLE) -----------------

cat("SECTION 1: BASELINE CHARACTERISTICS\n\n")

summarize_factor <- function(x) {
  tb <- sort(table(x, useNA = "no"), decreasing = TRUE)
  as.data.frame(tb)
}

# Overall
cat("Overall counts by key clinical factors:\n")
if ("Gender" %in% names(data)) print(summarize_factor(data$Gender))
if ("Grade" %in% names(data)) print(summarize_factor(data$Grade))
if ("IDH_mutation_status" %in% names(data)) print(summarize_factor(data$IDH_mutation_status))
if ("MGMTp_methylation_status" %in% names(data)) print(summarize_factor(data$MGMTp_methylation_status))
cat("\nAge (years):\n")
if ("Age" %in% names(data)) print(summary(data$Age))

# SECTION 2: MISSINGNESS PROFILE ------------------------------

cat("\nSECTION 2: MISSINGNESS PROFILE\n\n")
miss_df <- data.frame(
  Variable = names(data),
  Missing = sapply(data, function(x) sum(is.na(x)))
)

p_miss <- ggplot(miss_df, aes(x = reorder(Variable, Missing), y = Missing)) +
  geom_col(fill = "firebrick", alpha = 0.8) +
  coord_flip() +
  theme_minimal() +
  labs(title = "Missingness by Variable", x = "Variable", y = "Missing (count)")
print(p_miss)
save_plot_both(p_miss, base_filename = "Lesson12_Missingness_Profile")

# SECTION 3: UNIVARIABLE COX FOREST PLOT ----------------------

cat("\nSECTION 3: UNIVARIABLE COX HAZARD RATIOS\n\n")

if (all(c("OS", "Censor") %in% names(data))) {
  surv_obj <- Surv(time = data$OS, event = data$Censor)
  candidate_vars <- c("Age", "Gender", "Grade", "IDH_mutation_status", 
                      "MGMTp_methylation_status", "PRS_type", "Chemo_status", "Radio_status")
  candidate_vars <- candidate_vars[candidate_vars %in% names(data)]
  results <- list()
  for (v in candidate_vars) {
    fml <- as.formula(paste("surv_obj ~", v))
    out <- tryCatch({
      fit <- coxph(fml, data = data)
      s <- summary(fit)
      hr <- s$coef[, "exp(coef)"]
      se <- s$coef[, "se(coef)"]
      p <- s$coef[, "Pr(>|z|)"]
      rr <- data.frame(
        Term = rownames(s$coef),
        HR = as.numeric(hr),
        Lower = as.numeric(exp(log(hr) - 1.96 * se)),
        Upper = as.numeric(exp(log(hr) + 1.96 * se)),
        p = as.numeric(p),
        Variable = v,
        stringsAsFactors = FALSE
      )
      rr
    }, error = function(e) NULL)
    if (!is.null(out)) results[[v]] <- out
  }
  if (length(results) > 0) {
    uni_df <- do.call(rbind, results)
    # remove non-finite/infinite rows for plotting
    uni_df <- uni_df[is.finite(uni_df$HR) & is.finite(uni_df$Lower) & is.finite(uni_df$Upper) & uni_df$HR > 0, ]
    if (nrow(uni_df) > 0) {
      uni_df$Display <- ifelse(grepl("=", uni_df$Term), uni_df$Term, uni_df$Variable)
      p_forest <- ggplot(uni_df, aes(x = HR, y = reorder(Display, HR))) +
        geom_point(color = "steelblue") +
        geom_errorbarh(aes(xmin = Lower, xmax = Upper), height = 0.2, color = "steelblue") +
        geom_vline(xintercept = 1, linetype = "dashed", color = "gray50") +
        scale_x_log10() +
        theme_minimal() +
        labs(title = "Univariable Hazard Ratios (log scale)", x = "Hazard Ratio", y = "Variable/Level")
      print(p_forest)
      save_plot_both(p_forest, base_filename = "Lesson12_UniCox_Forest")
    } else {
      cat("No finite HRs to plot for univariable Cox.\n")
    }
  } else {
    cat("No univariable Cox results available.\n")
  }
} else {
  cat("OS/Censor not available for Cox analyses.\n")
}

# SECTION 4: MULTIVARIABLE RISK STRATIFICATION ---------------

cat("\nSECTION 4: RISK STRATIFICATION FROM MULTIVARIABLE COX\n\n")

mv_fit <- NULL
if (all(c("OS", "Censor") %in% names(data))) {
  mv_vars <- c("Age", "Grade", "IDH_mutation_status", "MGMTp_methylation_status")
  mv_vars <- mv_vars[mv_vars %in% names(data)]
  if (length(mv_vars) >= 2) {
    # complete-case subset for multivariable model
    cc_idx <- complete.cases(data[, mv_vars]) & !is.na(data$OS) & !is.na(data$Censor)
    mv_df <- data[cc_idx, ]
    surv_obj_cc <- Surv(time = mv_df$OS, event = mv_df$Censor)
    fml <- as.formula(paste("surv_obj_cc ~", paste(mv_vars, collapse = " + ")))
    mv_fit <- tryCatch(coxph(fml, data = mv_df), error = function(e) NULL)
    if (!is.null(mv_fit)) {
      print(summary(mv_fit))
      lp <- as.numeric(predict(mv_fit, newdata = mv_df, type = "lp"))
      rg <- cut(lp, breaks = quantile(lp, probs = c(0, 1/3, 2/3, 1), na.rm = TRUE),
                labels = c("Low", "Medium", "High"), include.lowest = TRUE)
      mv_df$RiskGroup <- rg
      rg_fit <- survfit(Surv(OS, Censor) ~ RiskGroup, data = mv_df)
      ensure_plots_dir()
      png(file.path("plots", "Lesson12_KM_by_Risk.png"), width = 1200, height = 900, res = 150)
      plot(rg_fit, col = c("forestgreen", "goldenrod", "firebrick"), lwd = 2,
           xlab = "Time (days)", ylab = "Survival Probability", main = "KM by Risk Group (Cox LP tertiles)")
      legend("topright", legend = levels(mv_df$RiskGroup), col = c("forestgreen", "goldenrod", "firebrick"), lwd = 2)
      dev.off()
      pdf(file.path("plots", "Lesson12_KM_by_Risk.pdf"), width = 9, height = 7)
      plot(rg_fit, col = c("forestgreen", "goldenrod", "firebrick"), lwd = 2,
           xlab = "Time (days)", ylab = "Survival Probability", main = "KM by Risk Group (Cox LP tertiles)")
      legend("topright", legend = levels(mv_df$RiskGroup), col = c("forestgreen", "goldenrod", "firebrick"), lwd = 2)
      dev.off()
    } else {
      cat("Multivariable model failed to fit.\n")
    }
  } else {
    cat("Not enough variables for multivariable model.\n")
  }
}

# SECTION 5: PH ASSUMPTION CHECKS -----------------------------

cat("\nSECTION 5: PROPORTIONAL HAZARDS CHECKS\n\n")

if (!is.null(mv_fit)) {
  zph <- tryCatch(cox.zph(mv_fit), error = function(e) NULL)
  if (!is.null(zph)) {
    print(zph)
    ensure_plots_dir()
    png(file.path("plots", "Lesson12_Cox_PH_Checks.png"), width = 1200, height = 900, res = 150)
    plot(zph)
    dev.off()
    pdf(file.path("plots", "Lesson12_Cox_PH_Checks.pdf"), width = 9, height = 7)
    plot(zph)
    dev.off()
  } else {
    cat("PH checks could not be computed.\n")
  }
} else {
  cat("PH checks skipped (no multivariable model).\n")
}

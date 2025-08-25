# ===============================================================
# LESSON 17: CREATING A PARSIMONIOUS CLINICAL RISK SCORE
# ===============================================================
#
# OBJECTIVE:
# To translate the output of a multivariable Cox regression model
# into a simple, point-based prognostic score that can be easily
# used for clinical risk stratification.
# ===============================================================

# SECTION 0: SETUP ---------------------------------------------
# For this lesson, we will use the `ggeffects` package to help visualize model predictions.
source("R/utils.R")
load_required_packages(c("readxl", "dplyr", "survival", "survminer", "ggplot2", "ggeffects"))

# Load and impute the clinical data
raw_data <- load_clinical_data("Data/ClinicalData.xlsx")
data <- impute_clinical_data(raw_data)
cat("--- LESSON 17: Parsimonious Prognostic Score ---\n")

# ===============================================================
# SECTION 1: BUILDING A PARSIMONIOUS COX MODEL ------------------
# "Parsimonious" means simpler. While our full model in Lesson 6
# The first step is to build a multivariable Cox model using the
# key prognostic variables we want to include in our score.
# ===============================================================
predictors <- intersect(c("Age", "Grade", "IDH_mutation_status", "MGMTp_methylation_status"), names(data))
if (length(predictors) < 2) {
  stop("Not enough predictors available for the model.")
}

# NOTE: The model is now built on the full, imputed dataset.
df <- data
surv_obj <- Surv(time = df$OS, event = df$Censor)
fml <- as.formula(paste("surv_obj ~", paste(predictors, collapse = " + ")))

fit <- tryCatch(coxph(fml, data = df), error = function(e) NULL)
if (is.null(fit)) {
  stop("Cox model failed to fit. Cannot proceed.")
}

# ===============================================================
# SECTION 2: CONVERT MODEL COEFFICIENTS TO POINTS ---------------
# The raw coefficients (betas) from the model are not intuitive.
# We can scale them to create a simple integer-based point system.
# ===============================================================
s <- summary(fit)
coefs <- as.data.frame(s$coef)
beta <- coefs$coef
names(beta) <- rownames(coefs)

# This scaling method assigns the variable with the largest effect a
# score of +5 (if a risk factor) or -5 (if protective) and scales
# the other variables' points relative to that.
scale_factor <- 5 / max(abs(beta), na.rm = TRUE)
points <- round(beta * scale_factor)
point_map <- data.frame(Term = names(points), Points = as.integer(points))

cat("Point assignments for the scorecard:\n")
print(point_map)

# ===============================================================
# SECTION 3: CALCULATE TOTAL SCORE AND STRATIFY PATIENTS --------
# Now we apply this point system to each patient to get their total
# risk score and then stratify them into risk groups.
# ===============================================================
# The 'predict()' function calculates the linear predictor (risk score) for each patient.
df$Score <- predict(fit, type = "lp")

# We can use 'cut()' to divide the continuous scores into tertiles (three equal-sized groups).
df$RiskStratum <- cut(df$Score,
                      breaks = quantile(df$Score, probs = c(0, 1/3, 2/3, 1), na.rm = TRUE),
                      labels = c("Low Risk", "Medium Risk", "High Risk"),
                      include.lowest = TRUE)

# ===============================================================
# SECTION 4: VISUALIZE THE SCORE'S PERFORMANCE ------------------
# A Kaplan-Meier plot of our new risk strata will show if the score
# successfully separates patients with different survival outcomes.
# ===============================================================
fit_km <- survfit(Surv(OS, Censor) ~ RiskStratum, data = df)

# Generate and save a publication-quality KM plot.
p_km_score <- ggsurvplot(
  fit_km,
  data = df,
  pval = TRUE,
  conf.int = TRUE,
  risk.table = TRUE,
  title = "Survival by Prognostic Score Risk Group",
  xlab = "Time (days)",
  legend.title = "Risk Group",
  palette = c("forestgreen", "goldenrod", "firebrick")
)

ensure_plots_dir()
pdf(file.path("plots", "Lesson17_Score_KM_by_Tertile.pdf"), width = 9, height = 7)
print(p_km_score, newpage = FALSE)
dev.off()

# Also, visualize the scorecard itself.
p_tbl <- ggplot(point_map, aes(x = reorder(Term, Points), y = Points)) +
  geom_col(fill = "steelblue") + coord_flip() + theme_minimal() +
  labs(title = "Clinical Risk Score Points", x = "Predictor", y = "Points")
print(p_tbl)
save_plot_both(p_tbl, base_filename = "Lesson17_Scorecard_Table")

# ===============================================================
# PRACTICE TASKS ----------------------------------------------
# ===============================================================
# 1. Based on the point assignments, what is the single most important
#    risk factor in this model?

# 2. Manually calculate the risk score for a hypothetical patient:
#    Age 60, Grade IV, IDH-Wildtype, MGMT-un-methylated.
#    (Note: Age is continuous, so its contribution is 60 * its beta coefficient, then scaled).

# 3. Try building a simpler, "parsimonious" model with only the top 2-3
#    predictors and see if the resulting risk score still separates the
#    Kaplan-Meier curves well.



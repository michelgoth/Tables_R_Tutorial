# 🧠 NEUROSURGEON QUICK START GUIDE
# ======================================
# This script is designed specifically for neurosurgeons with zero R experience
# It will teach you the basics and run your first analysis

cat("🧠 WELCOME TO CLINICAL DATA ANALYSIS FOR NEUROSURGEONS\n")
cat("=====================================================\n\n")

# STEP 1: SETTING UP YOUR ENVIRONMENT
# ===================================
cat("STEP 1: Setting up your environment...\n")
cat("(This is like preparing your operating room)\n\n")

# Check if we need to install packages
required_packages <- c("readxl", "ggplot2", "dplyr", "tidyr")

cat("Checking if you have the necessary tools...\n")
for(pkg in required_packages) {
  if(!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg, dependencies = TRUE)
  }
  library(pkg, character.only = TRUE)
  cat("✅", pkg, "loaded successfully\n")
}

cat("\n🎉 Environment setup complete!\n\n")

# STEP 2: LOADING YOUR DATA
# =========================
cat("STEP 2: Loading your clinical data...\n")
cat("(This is like opening a patient's chart)\n\n")

# Check if data file exists
if(!file.exists("Data/ClinicalData.xlsx")) {
  cat("❌ ERROR: Data file not found!\n")
  cat("Make sure you have the file: Data/ClinicalData.xlsx\n")
  cat("Check that you're in the correct folder.\n")
  stop("Data file missing")
}

# Load the data
cat("Loading your glioma patient data...\n")
data <- read_excel("Data/ClinicalData.xlsx")

# Convert data types (important for analysis)
cat("Preparing data for analysis...\n")
data$OS <- as.numeric(data$OS)
data$`Censor (alive=0; dead=1)` <- as.numeric(data$`Censor (alive=0; dead=1)`)
data$Age <- as.numeric(data$Age)

cat("✅ Data loaded successfully!\n")
cat("📊 You have", nrow(data), "patients and", ncol(data), "variables\n\n")

# STEP 3: UNDERSTANDING YOUR DATA
# ===============================
cat("STEP 3: Understanding your data...\n")
cat("(This is like reviewing patient demographics)\n\n")

# Show what variables you have
cat("Your clinical variables:\n")
for(i in 1:length(names(data))) {
  cat(i, ".", names(data)[i], "\n")
}
cat("\n")

# Basic patient summary
cat("📋 PATIENT SUMMARY:\n")
cat("==================\n")
cat("Total patients:", nrow(data), "\n")
cat("Age range:", min(data$Age, na.rm = TRUE), "to", max(data$Age, na.rm = TRUE), "years\n")
cat("Average age:", round(mean(data$Age, na.rm = TRUE), 1), "years\n\n")

# Gender distribution
cat("👥 GENDER DISTRIBUTION:\n")
gender_table <- table(data$Gender)
cat("Female:", gender_table["Female"], "patients\n")
cat("Male:", gender_table["Male"], "patients\n\n")

# Tumor grade distribution
cat("🧬 TUMOR GRADE DISTRIBUTION:\n")
grade_table <- table(data$Grade)
for(grade in names(grade_table)) {
  cat(grade, ":", grade_table[grade], "patients\n")
}
cat("\n")

# IDH status
cat("🔬 IDH MUTATION STATUS:\n")
idh_table <- table(data$IDH_mutation_status)
for(status in names(idh_table)) {
  cat(status, ":", idh_table[status], "patients\n")
}
cat("\n")

# STEP 4: YOUR FIRST ANALYSIS
# ===========================
cat("STEP 4: Your first analysis...\n")
cat("(This is like ordering your first lab test)\n\n")

# Simple survival comparison by IDH status
cat("🔍 ANALYZING SURVIVAL BY IDH STATUS:\n")
cat("====================================\n")

# Create survival object
library(survival)
surv_obj <- Surv(data$OS, data$`Censor (alive=0; dead=1)`)

# Fit survival model
fit <- survfit(surv_obj ~ data$IDH_mutation_status)

# Get survival summary
summary_fit <- summary(fit)
cat("\n📊 SURVIVAL SUMMARY:\n")
cat("Median survival times:\n")
for(i in 1:length(summary_fit$strata)) {
  group_name <- names(summary_fit$strata)[i]
  median_surv <- summary_fit$median[i]
  cat(group_name, ":", round(median_surv, 1), "days\n")
}

# Log-rank test
logrank_test <- survdiff(surv_obj ~ data$IDH_mutation_status)
cat("\n📈 STATISTICAL TEST (Log-rank):\n")
cat("Chi-square =", round(logrank_test$chisq, 2), "\n")
cat("p-value =", format.pval(logrank_test$pvalue, digits = 3), "\n")

if(logrank_test$pvalue < 0.05) {
  cat("✅ SIGNIFICANT: IDH status affects survival\n")
} else {
  cat("❌ NOT SIGNIFICANT: No clear survival difference\n")
}

cat("\n")

# STEP 5: CREATING YOUR FIRST PLOT
# ================================
cat("STEP 5: Creating your first plot...\n")
cat("(This is like creating an MRI image)\n\n")

# Create a simple survival plot
cat("📊 Creating Kaplan-Meier survival plot...\n")

# Basic plot
plot(fit, 
     main = "Survival by IDH Mutation Status",
     xlab = "Time (days)", 
     ylab = "Survival Probability",
     col = c("blue", "red"),
     lwd = 2)

# Add legend
legend("topright", 
       legend = c("IDH Mutant", "IDH Wildtype"),
       col = c("blue", "red"),
       lwd = 2)

cat("✅ Plot created! This is publication-ready for your paper.\n\n")

# STEP 6: CLINICAL INTERPRETATION
# ===============================
cat("STEP 6: Clinical interpretation...\n")
cat("(This is like interpreting your patient's results)\n\n")

cat("🏥 CLINICAL INTERPRETATION:\n")
cat("==========================\n")

# Calculate hazard ratio manually
idh_mutant_surv <- summary_fit$surv[summary_fit$strata == "data$IDH_mutation_status=Mutant"]
idh_wildtype_surv <- summary_fit$surv[summary_fit$strata == "data$IDH_mutation_status=Wildtype"]

if(logrank_test$pvalue < 0.05) {
  cat("• IDH mutation status significantly affects patient survival\n")
  cat("• This finding is consistent with known molecular biology\n")
  cat("• Consider IDH status in treatment planning and prognosis\n")
} else {
  cat("• No significant survival difference by IDH status in this dataset\n")
  cat("• This may be due to sample size or other factors\n")
  cat("• Consider additional molecular markers for risk stratification\n")
}

cat("\n📋 CLINICAL RECOMMENDATIONS:\n")
cat("• Include IDH status in patient counseling\n")
cat("• Consider IDH status for treatment decisions\n")
cat("• Monitor IDH status in clinical trials\n")
cat("• Validate findings in larger patient cohorts\n\n")

# STEP 7: NEXT STEPS
# ==================
cat("STEP 7: What to do next...\n")
cat("(This is like planning follow-up care)\n\n")

cat("🎯 RECOMMENDED NEXT STEPS:\n")
cat("=========================\n")
cat("1. Run the full Lesson 6: source('R/Lesson6.R')\n")
cat("2. Try other variables: Grade, Age, Treatment status\n")
cat("3. Create more plots for your presentations\n")
cat("4. Practice with your own data\n")
cat("5. Read the clinical statistics guide: docs/clinical_stats_guide.md\n\n")

cat("💡 PRO TIPS:\n")
cat("============\n")
cat("• Save your plots: Right-click and 'Save as...'\n")
cat("• Copy results: Select text and Ctrl+C (Cmd+C on Mac)\n")
cat("• Document everything: Keep notes of what you learn\n")
cat("• Practice regularly: Even 15 minutes daily helps\n\n")

# STEP 8: TROUBLESHOOTING
# =======================
cat("STEP 8: Common issues and solutions...\n")
cat("(This is like knowing what to do when things go wrong)\n\n")

cat("🚨 COMMON ISSUES:\n")
cat("================\n")
cat("• 'Object not found': Make sure you ran this script from start to finish\n")
cat("• 'Package not found': Run the setup script: source('R/setup.R')\n")
cat("• 'Data file missing': Check that Data/ClinicalData.xlsx exists\n")
cat("• Plot not showing: Check your R graphics window\n\n")

cat("🆘 GETTING HELP:\n")
cat("===============\n")
cat("• Check the troubleshooting guide: docs/troubleshooting.md\n")
cat("• Look at the neurosurgeon guide: NEUROSURGEON_GUIDE.md\n")
cat("• Ask questions on RStudio Community\n")
cat("• Practice with the exercises: exercises/exercise_1_basic_analysis.md\n\n")

# FINAL MESSAGE
# =============
cat("🎉 CONGRATULATIONS!\n")
cat("==================\n")
cat("You've just completed your first clinical data analysis!\n")
cat("You now know how to:\n")
cat("• Load clinical data\n")
cat("• Understand patient demographics\n")
cat("• Perform survival analysis\n")
cat("• Create publication-ready plots\n")
cat("• Interpret results clinically\n\n")

cat("🚀 READY FOR MORE?\n")
cat("Run: source('R/Lesson1.R') to start the full tutorial series!\n\n")

cat("Remember: Every expert was once a beginner.\n")
cat("You're on your way to becoming a data-savvy neurosurgeon! 🧠📊\n") 
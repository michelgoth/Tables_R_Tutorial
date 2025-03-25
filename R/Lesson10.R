# ===============================================================
# LESSON 10: CORRELATION ANALYSIS BETWEEN NUMERIC VARIABLES
# ===============================================================

# LEARNING OBJECTIVES:
# - Identify relationships between numeric variables
# - Use correlation matrices and plots
# - Interpret positive and negative correlations

# WHAT YOU'LL LEARN:
# Correlation helps you measure the strength and direction of relationships
# between continuous variables — such as Age, Survival Time, or Treatment Use.

# SECTION 1: SELECT NUMERIC DATA --------------------------------

# Filter only the numeric columns (adjust if needed)
numeric_data <- data %>%
  select(Age, OS, Censor, Chemo_status, Radio_status) %>%
  na.omit()

# SECTION 2: COMPUTE CORRELATION MATRIX --------------------------

# Create a correlation matrix
corr_matrix <- cor(numeric_data)

# SECTION 3: VISUALIZE WITH CORRPLOT -----------------------------

# Visualize the correlation matrix
corrplot(
  corr_matrix,
  method = "circle",
  type = "upper",
  tl.col = "black",
  tl.srt = 45
)

# Interpretation Tips:
# - Correlation ranges from -1 (perfect negative) to +1 (perfect positive)
# - 0 means no linear relationship
# - Always check sample size before interpreting!

# PRACTICE TASKS ------------------------------------------------

# 1. Which variables are most positively correlated? Most negatively?

# 2. Do any variables show a surprisingly weak or strong relationship?

# 3. Add a new numeric variable (if available) and re-run the matrix

# 4. Optional: Use `cor.test()` to test significance of individual correlations
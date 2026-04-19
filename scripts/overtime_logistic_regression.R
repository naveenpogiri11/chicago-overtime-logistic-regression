# =============================================================================
# Chicago Employee Overtime - Logistic Regression Analysis
# Author: Naveen Pogiri
# =============================================================================
# Goal: Predict the probability that a City of Chicago employee earned $5,000+
#       in overtime pay during 2016, using department affiliation and the
#       number of months the employee received overtime as predictors.
#
# Dataset: 20,907 employees across the 5 largest City of Chicago departments
#          (Police, Fire, Streets and Sanitation, Water Management, Aviation)
# =============================================================================

# ---- Setup ----
rm(list = ls())
library(rio)       # data import
library(moments)   # descriptive statistics

# ---- 1. Load the dataset ----
overtime <- import("data/employee_overtime_dataset.xlsx")
colnames(overtime) <- tolower(make.names(colnames(overtime)))

cat("Dataset dimensions:", dim(overtime), "\n")
cat("Columns:", colnames(overtime), "\n\n")

# ---- 2. Reproducible random sample of 4,500 employees ----
# Using a fixed seed so results are repeatable
set.seed(14902438)
sample_data <- overtime[sample(1:nrow(overtime), 4500), ]

# ---- 3. Inspect structure ----
str(sample_data)

# ---- 4. Logistic regression: over5000 ~ department.name + nummos ----
model <- glm(over5000 ~ department.name + nummos,
             data   = sample_data,
             family = binomial)

cat("\n========== MODEL SUMMARY ==========\n")
print(summary(model))

cat("\n--- Goodness-of-fit ---\n")
cat("Null Deviance:    ", round(model$null.deviance, 2), "\n")
cat("Residual Deviance:", round(model$deviance, 2), "\n")
cat("Deviance Reduction:", round(100 * (1 - model$deviance / model$null.deviance), 1), "%\n")
cat("AIC:              ", round(model$aic, 2), "\n\n")

# ---- 5. Prediction grid: every department x months-worked combination ----
prediction_grid <- expand.grid(
  department.name = unique(sample_data$department.name),
  nummos          = unique(sample_data$nummos)
)
prediction_grid$pred_prob <- round(
  predict(model, newdata = prediction_grid, type = "response"),
  4
)

cat("========== FIRST 10 PREDICTED PROBABILITIES ==========\n")
print(head(prediction_grid, 10))

# ---- 6. Highest- and lowest-risk profiles ----
cat("\n--- Maximum predicted probability ---\n")
print(prediction_grid[which.max(prediction_grid$pred_prob), ])

cat("\n--- Minimum predicted probability ---\n")
print(prediction_grid[which.min(prediction_grid$pred_prob), ])

# =============================================================================
# KEY FINDINGS
# -----------------------------------------------------------------------------
# * Deviance dropped from 6,211.7 (null) to 2,983.0 - 52% reduction, showing
#   the model carries substantial predictive signal.
# * Fire department is the strongest positive driver (coef = +1.31).
# * Streets and Sanitation is the strongest negative driver (coef = -1.49).
# * Each extra month of overtime activity adds +0.71 to the log-odds.
# * Highest-risk profile: Fire dept., 12 months of overtime -> 99.5% probability
# * Lowest-risk profile : Streets & Sanitation, 0 months    ->  0.3% probability
# =============================================================================

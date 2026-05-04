# ============================================================
# Biostatistics Courses
# Course 3 — Week 2, Session 2: Multiple imputation with mice
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(mice)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Estimate the association between BMI and cholesterol in the
# nhanes teaching dataset, using multiple imputation for the
# missing values.

# --- 2. Data ---------------------------------------------------
data(nhanes, package = "mice")
print(md.pattern(nhanes, plot = FALSE))

# --- 3. Visualise ----------------------------------------------
p <- nhanes |>
  mutate(missing_chl = is.na(chl)) |>
  ggplot(aes(bmi, chl, colour = missing_chl)) +
  geom_point(size = 2) +
  labs(x = "BMI", y = "Cholesterol", colour = "chl missing?")
print(p)

# --- 4. Assumptions --------------------------------------------
# MAR given variables in the imputation model; PMM imputation
# compatible with the linear analysis model.

# --- 5. Conduct / Fit ------------------------------------------
imp <- mice(nhanes, m = 10, method = "pmm", printFlag = FALSE, seed = 42)
print(imp)
fit   <- with(imp, lm(chl ~ age + bmi))
pooled <- pool(fit)
print(summary(pooled, conf.int = TRUE))

# --- 6. Report -------------------------------------------------
cat("Pooled coefficients printed above (Rubin's rules).\n")

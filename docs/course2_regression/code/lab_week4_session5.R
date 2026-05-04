# ============================================================
# Biostatistics Courses
# Course 2 — Week 4, Session 5: Explanation vs prediction, reporting
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(gtsummary)
library(broom)
library(palmerpenguins)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Goal ---------------------------------------------------
# Fit one linear model; present as both explanatory and predictive.

# --- 2. Data ---------------------------------------------------
peng <- penguins |>
  drop_na(body_mass_g, flipper_length_mm, sex, species)

# --- 3. Visualise ----------------------------------------------
print(
  ggplot(peng, aes(flipper_length_mm, body_mass_g, colour = species)) +
    geom_point(alpha = 0.6) +
    geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
    labs(x = "Flipper length (mm)", y = "Body mass (g)")
)

# --- 4. Assumptions --------------------------------------------
fit_expl <- lm(body_mass_g ~ flipper_length_mm + sex + species, data = peng)
par(mfrow = c(2, 2)); plot(fit_expl); par(mfrow = c(1, 1))

# --- 5. Conduct / Fit ------------------------------------------
print(glance(fit_expl))
print(tidy(fit_expl, conf.int = TRUE))

k <- 5
folds <- sample(rep(seq_len(k), length.out = nrow(peng)))
rmse_k <- sapply(seq_len(k), function(i) {
  tr <- peng[folds != i, ]
  te <- peng[folds == i, ]
  f  <- lm(body_mass_g ~ flipper_length_mm + sex + species, data = tr)
  sqrt(mean((predict(f, te) - te$body_mass_g)^2))
})
cat("5-fold CV RMSE:", round(mean(rmse_k), 1), "g\n")

# --- 6. Report -------------------------------------------------
tbl_regression(fit_expl, intercept = TRUE) |> print()

# ============================================================
# Biostatistics Courses
# Course 2 — Week 1, Session 4: Diagnostics
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
library(car)
library(performance)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Use diagnostics to flag heteroscedasticity, leverage, and VIF.

# --- 2. Data ---------------------------------------------------
n <- 150
x1 <- rnorm(n); x2 <- x1 + rnorm(n, 0, 0.3); x3 <- rnorm(n)
y  <- 1 + 2 * x1 - 1.5 * x2 + 0.5 * x3 + rnorm(n, 0, 1 + 0.4 * abs(x1))
x1[1] <- 5; x2[1] <- 5; y[1] <- 0
dat <- tibble(y, x1, x2, x3)

# --- 3. Visualise ----------------------------------------------
p <- ggplot(dat, aes(x1, y)) + geom_point(alpha = 0.6) +
  labs(x = "x1", y = "y")
print(p)

# --- 4. Assumptions --------------------------------------------
fit <- lm(y ~ x1 + x2 + x3, data = dat)
par(mfrow = c(2, 2)); plot(fit); par(mfrow = c(1, 1))

# --- 5. Conduct / Fit ------------------------------------------
infl <- augment(fit) |> mutate(row = row_number())
print(infl |> arrange(desc(.cooksd)) |> head(5))
print(vif(fit))
print(check_model(fit, check = c("vif", "qq", "outliers", "linearity")))

# --- 6. Report -------------------------------------------------
cat(sprintf("Max Cook's D: %.2f; max VIF: %.1f\n",
            max(infl$.cooksd), max(vif(fit))))

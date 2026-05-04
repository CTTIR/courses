# ============================================================
# Biostatistics Courses
# Course 2 — Week 1, Session 5: Robust / weighted / sandwich
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
library(MASS)
library(sandwich)
library(lmtest)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Compare OLS, robust, and weighted regression; apply HC SEs.

# --- 2. Data ---------------------------------------------------
n <- 200
x <- runif(n, 0, 10)
eps <- rnorm(n, 0, 0.3 + 0.2 * x)
outl <- sample(seq_len(n), 8); eps[outl] <- eps[outl] + rnorm(8, 0, 6)
y <- 2 + 0.7 * x + eps
dat <- tibble(x, y)

# --- 3. Visualise ----------------------------------------------
p <- ggplot(dat, aes(x, y)) + geom_point(alpha = 0.6) +
  labs(x = "x", y = "y")
print(p)

# --- 4. Assumptions --------------------------------------------
fit_ols <- lm(y ~ x, data = dat)
par(mfrow = c(2, 2)); plot(fit_ols); par(mfrow = c(1, 1))

# --- 5. Conduct / Fit ------------------------------------------
fit_rlm <- MASS::rlm(y ~ x, data = dat)
w <- 1 / (0.3 + 0.2 * dat$x)^2
fit_wls <- lm(y ~ x, data = dat, weights = w)
print(tidy(fit_ols))
print(summary(fit_rlm))
print(tidy(fit_wls))
print(coeftest(fit_ols, vcov. = vcovHC(fit_ols, type = "HC3")))

# --- 6. Report -------------------------------------------------
cat(sprintf("Slopes — OLS: %.2f; robust: %.2f; WLS: %.2f\n",
            coef(fit_ols)[2], coef(fit_rlm)[2], coef(fit_wls)[2]))

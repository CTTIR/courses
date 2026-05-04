# ============================================================
# Biostatistics Courses
# Course 2 — Week 1, Session 1: Correlation vs regression; Model-I/II
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Compare OLS and SMA when both variables carry measurement error.

# --- 2. Data ---------------------------------------------------
n <- 200
true_size <- rnorm(n, mean = 50, sd = 10)
x <- true_size + rnorm(n, 0, 3)
y <- true_size + rnorm(n, 0, 3)
dat <- tibble(x, y)

# --- 3. Visualise ----------------------------------------------
p <- ggplot(dat, aes(x, y)) +
  geom_point(alpha = 0.6, colour = "grey30") +
  labs(x = "Instrument 1", y = "Instrument 2")
print(p)

# --- 4. Assumptions --------------------------------------------
fit_ols <- lm(y ~ x, data = dat)
par(mfrow = c(1, 2)); plot(fit_ols, which = c(1, 2)); par(mfrow = c(1, 1))

# --- 5. Conduct / Fit ------------------------------------------
print(cor.test(dat$x, dat$y))
print(tidy(fit_ols, conf.int = TRUE))

sma_slope <- function(x, y) sign(cor(x, y)) * sd(y) / sd(x)
sma_intercept <- function(x, y) mean(y) - sma_slope(x, y) * mean(x)
b_sma <- sma_slope(dat$x, dat$y)
a_sma <- sma_intercept(dat$x, dat$y)
b_ols <- coef(fit_ols)[2]

# --- 6. Report -------------------------------------------------
cat(sprintf("OLS slope: %.2f; SMA slope: %.2f; cor: %.2f\n",
            unname(b_ols), b_sma, cor(dat$x, dat$y)))

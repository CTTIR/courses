# ============================================================
# Biostatistics Courses
# Course 2 — Week 2, Session 4: GAMs with mgcv
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(mgcv)
library(gratia)
library(broom)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Recover a sine-wave relationship with a GAM; compare with lm.

# --- 2. Data ---------------------------------------------------
n <- 300
x <- runif(n, 0, 4 * pi); y <- sin(x) + rnorm(n, 0, 0.4)
dat <- tibble(x, y)

# --- 3. Visualise ----------------------------------------------
p <- ggplot(dat, aes(x, y)) +
  geom_point(alpha = 0.5, colour = "grey30") +
  labs(x = "x", y = "y")
print(p)

# --- 4. Assumptions --------------------------------------------
fit_lm  <- lm(y ~ x, data = dat)
fit_gam <- gam(y ~ s(x, bs = "cr", k = 20), data = dat, method = "REML")
plot(fit_gam, residuals = TRUE, pch = 1, shade = TRUE)
gam.check(fit_gam)

# --- 5. Conduct / Fit ------------------------------------------
print(summary(fit_gam))
print(AIC(fit_lm, fit_gam))
print(draw(fit_gam))

# --- 6. Report -------------------------------------------------
cat(sprintf("Smooth edf: %.1f\n", summary(fit_gam)$s.table[, "edf"]))

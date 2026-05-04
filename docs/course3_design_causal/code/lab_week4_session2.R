# ============================================================
# Biostatistics Courses
# Course 3 — Week 4, Session 2: Meta-analysis basics
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(metafor)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis ---------------------------------------------
# H0: pooled log RR = 0. H1: pooled log RR != 0. alpha = 0.05.

# --- 2. Data ---------------------------------------------------
dat <- escalc(measure = "RR",
              ai = tpos, bi = tneg, ci = cpos, di = cneg,
              data = dat.bcg, slab = paste(author, year))

# --- 3. Visualise ----------------------------------------------
fit <- rma(yi, vi, data = dat, method = "REML")
forest(fit, header = TRUE, cex = 0.8)
funnel(fit)

# --- 4. Assumptions --------------------------------------------
# Random-effects model absorbs between-study heterogeneity.
print(regtest(fit, model = "lm"))

# --- 5. Conduct / Fit ------------------------------------------
print(fit)

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "Pooled RR = %.2f (95%% CI %.2f, %.2f), tau^2 = %.2f, I^2 = %.1f%%\n",
  exp(fit$b[1]), exp(fit$ci.lb), exp(fit$ci.ub), fit$tau2, fit$I2
))

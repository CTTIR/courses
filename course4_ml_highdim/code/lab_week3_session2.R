# ============================================================
# Biostatistics Courses
# Course 4 — Week 3, Session 2: brms / Stan, LOO, hierarchical models
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(lme4)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Fit a two-level hierarchical model (patients nested in centres);
# compare random-intercept vs random-slope; sketch brms version.

# --- 2. Data ---------------------------------------------------
n_centre <- 20; per_centre <- 15
centre <- rep(seq_len(n_centre), each = per_centre)
alpha0 <- rnorm(n_centre, 0, 1)
beta0  <- rnorm(n_centre, 0.5, 0.3)
dose <- rnorm(n_centre * per_centre)
y <- alpha0[centre] + beta0[centre] * dose + rnorm(n_centre * per_centre, 0, 0.7)
d <- tibble(y = y, dose = dose, centre = factor(centre))

# --- 3. Visualise ----------------------------------------------
p1 <- ggplot(d, aes(dose, y, colour = centre)) +
  geom_point(alpha = 0.5) + geom_smooth(method = "lm", se = FALSE) +
  theme(legend.position = "none")
print(p1)

# --- 4. Assumptions --------------------------------------------
# Gaussian random effects on intercepts and slopes; Gaussian residuals.

# --- 5. Conduct / Fit ------------------------------------------
fit_lmer_ri  <- lmer(y ~ dose + (1 | centre), data = d)
fit_lmer_rs  <- lmer(y ~ dose + (dose | centre), data = d)

# brms sketch (not run):
# library(brms)
# m_rs <- brm(y ~ dose + (dose | centre), data = d, ...)
# loo_compare(loo(m_ri), loo(m_rs))

# --- 6. Report -------------------------------------------------
print(anova(fit_lmer_ri, fit_lmer_rs))
print(fixef(fit_lmer_rs))

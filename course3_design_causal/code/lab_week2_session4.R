# ============================================================
# Biostatistics Courses
# Course 3 — Week 2, Session 4: GLMMs and GEE
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(lme4)
library(glmmTMB)
library(geepack)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Binary outcome in clustered data; compare GLMM and GEE
# coefficients and interpretations.

# --- 2. Data ---------------------------------------------------
J  <- 30
nj <- 20
dat <- tibble(
  clinic = factor(rep(seq_len(J), each = nj)),
  trt    = rbinom(J * nj, 1, 0.5),
  u      = rep(rnorm(J, 0, 0.8), each = nj)
) |>
  mutate(lp = -0.5 * trt + u,
         y  = rbinom(n(), 1, plogis(lp)))

# --- 3. Visualise ----------------------------------------------
p <- dat |>
  group_by(clinic, trt) |>
  summarise(p = mean(y), .groups = "drop") |>
  ggplot(aes(factor(trt), p)) +
  geom_boxplot(alpha = 0.6) +
  labs(x = "Treatment", y = "Event probability per clinic")
print(p)

# --- 4. Assumptions --------------------------------------------
# GLMM: normal random intercepts, correct link.
# GEE:  correct mean structure; robust SE.

# --- 5. Conduct / Fit ------------------------------------------
fit_glmer <- glmer(y ~ trt + (1 | clinic), data = dat, family = binomial)
fit_tmb   <- glmmTMB(y ~ trt + (1 | clinic), data = dat, family = binomial)
fit_gee   <- geeglm(y ~ trt, id = clinic, data = dat,
                    family = binomial, corstr = "exchangeable")
print(summary(fit_glmer)$coefficients)
print(summary(fit_tmb)$coefficients$cond)
print(summary(fit_gee)$coefficients)

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "GLMM trt: %.2f; GEE trt: %.2f\n",
  fixef(fit_glmer)["trt"], coef(fit_gee)["trt"]
))

# ============================================================
# Biostatistics Courses
# Course 3 — Week 1, Session 5: Power (closed-form + simulation)
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(pwr)
library(lme4)
library(lmerTest)
library(simr)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Compute closed-form power for a two-sample t-test and simulate
# power for a simple two-arm cluster study.

# --- 2. Data ---------------------------------------------------
J   <- 20
nj  <- 10
dat <- tibble(
  cluster = factor(rep(seq_len(J), each = nj)),
  arm     = rep(rep(c(0, 1), each = nj), length.out = J * nj),
  y       = NA_real_
)

# --- 3. Visualise ----------------------------------------------
ns <- seq(20, 400, by = 20)
pw <- map_dbl(ns, \(n) pwr.t.test(
  n = n / 2, d = 0.4, sig.level = 0.05, type = "two.sample"
)$power)
p <- tibble(n = ns, power = pw) |>
  ggplot(aes(n, power)) +
  geom_line() +
  geom_hline(yintercept = 0.8, linetype = "dashed", colour = "grey40") +
  labs(x = "Total sample size", y = "Power")
print(p)

# --- 4. Assumptions --------------------------------------------
# Closed-form: equal variance, independence, normality.
# Simulation: model correctly specifies cluster structure.

# --- 5. Conduct / Fit ------------------------------------------
res <- pwr.t.test(d = 0.4, power = 0.8, sig.level = 0.05, type = "two.sample")
print(res)

m0 <- makeLmer(
  y ~ arm + (1 | cluster),
  fixef   = c(0, 0.3),
  VarCorr = 0.5,
  sigma   = 1.0,
  data    = dat
)
ps <- powerSim(m0, nsim = 50, test = fixed("arm"), progress = FALSE)
print(ps)

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "Closed-form n per arm: %.0f; simulated mixed-model power: %.2f\n",
  ceiling(res$n), summary(ps)$mean
))

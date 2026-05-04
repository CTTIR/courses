# ============================================================
# Biostatistics Courses
# Course 4 — Week 3, Session 1: Bayesian thinking; alpha vs decision error
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Assess whether a response rate exceeds 0.2 given 7 of 20 successes,
# using three different Beta priors.

# --- 2. Data ---------------------------------------------------
k <- 7; n <- 20
theta <- seq(0, 1, length.out = 400)
priors <- tibble(
  name = c("uniform", "sceptical", "informative"),
  a0 = c(1, 2, 4), b0 = c(1, 8, 4)
)

# --- 3. Visualise ----------------------------------------------
post <- priors |>
  rowwise() |>
  mutate(data = list(tibble(
    theta = theta,
    prior = dbeta(theta, a0, b0),
    posterior = dbeta(theta, a0 + k, b0 + n - k)
  ))) |>
  unnest(data) |>
  pivot_longer(c(prior, posterior), names_to = "density")
p1 <- ggplot(post, aes(theta, value, colour = density)) +
  geom_line() + facet_wrap(~ name)
print(p1)

# --- 4. Assumptions --------------------------------------------
# Exchangeable Bernoulli trials; beta-binomial conjugacy.

# --- 5. Conduct / Fit ------------------------------------------
summ <- priors |>
  rowwise() |>
  mutate(
    post_mean = (a0 + k) / (a0 + b0 + n),
    ci_lo = qbeta(0.025, a0 + k, b0 + n - k),
    ci_hi = qbeta(0.975, a0 + k, b0 + n - k),
    p_gt_0_2 = 1 - pbeta(0.2, a0 + k, b0 + n - k)
  )
bt <- binom.test(k, n, p = 0.2, alternative = "greater")

# --- 6. Report -------------------------------------------------
print(summ)
print(bt)

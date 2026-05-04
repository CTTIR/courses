# ============================================================
# Biostatistics Courses
# Course 1 — Week 3, Session 3: Maximum likelihood estimation
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# MLE for normal mean (known sigma) and Poisson rate; Wald CIs.

# --- 2. Data ---------------------------------------------------
n <- 50
mu_true <- 5
sigma <- 2
x <- rnorm(n, mu_true, sigma)
y <- rpois(100, lambda = 3.2)

# --- 3. Visualise ----------------------------------------------
grid <- tibble(mu = seq(3.5, 6.5, length.out = 300)) |>
  mutate(loglik = sapply(mu, function(m) sum(dnorm(x, m, sigma, log = TRUE))))
p <- ggplot(grid, aes(mu, loglik)) +
  geom_line() +
  geom_vline(xintercept = mean(x), linetype = 2, colour = "firebrick") +
  labs(x = expression(mu), y = "log-likelihood")
print(p)

# --- 4. Assumptions --------------------------------------------
# iid data; regularity conditions on the likelihood.

# --- 5. Conduct / Fit ------------------------------------------
mle_mu <- mean(x)
I_mu <- n / sigma^2
se_mu <- 1 / sqrt(I_mu)
ci_mu <- mle_mu + c(-1, 1) * qnorm(0.975) * se_mu

mle_lambda <- mean(y)
I_lambda <- length(y) / mle_lambda
se_lambda <- 1 / sqrt(I_lambda)
ci_lambda <- mle_lambda + c(-1, 1) * qnorm(0.975) * se_lambda

# --- 6. Report -------------------------------------------------
cat(sprintf("Normal MLE: mu=%.3f SE=%.3f CI=(%.2f, %.2f)\n",
            mle_mu, se_mu, ci_mu[1], ci_mu[2]))
cat(sprintf("Poisson MLE: lambda=%.3f SE=%.3f CI=(%.2f, %.2f)\n",
            mle_lambda, se_lambda, ci_lambda[1], ci_lambda[2]))

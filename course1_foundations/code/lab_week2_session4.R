# ============================================================
# Biostatistics Courses
# Course 1 — Week 2, Session 4: Discrete distributions
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Explore Bernoulli, binomial, and Poisson by simulation.

# --- 2. Data ---------------------------------------------------
n_rep <- 10000
bin <- rbinom(n_rep, size = 20, prob = 0.3)
pois <- rpois(n_rep, lambda = 3)

# --- 3. Visualise ----------------------------------------------
bin_tibble <- tibble(k = bin) |>
  count(k) |>
  mutate(prop = n / sum(n),
         theo = dbinom(k, 20, 0.3))
p <- bin_tibble |>
  ggplot(aes(k, prop)) +
  geom_col(fill = "grey70", alpha = 0.8) +
  geom_point(aes(y = theo), colour = "firebrick", size = 2) +
  labs(x = "k", y = "Prop vs. P(k)")
print(p)

# --- 4. Assumptions --------------------------------------------
# Binomial: fixed n, constant p, independent trials.
# Poisson: constant rate, independent counts.
probs <- tibble(
  k = 0:10,
  binom = dbinom(k, 1000, 0.003),
  pois  = dpois(k, 3)
)
print(probs)

# --- 5. Conduct / Fit ------------------------------------------
p_ge8       <- 1 - pbinom(7, 20, 0.3)
p_pois_ge7  <- 1 - ppois(6, 3)
empirical   <- mean(pois >= 7)

# --- 6. Report -------------------------------------------------
cat(sprintf("P(binomial >= 8) = %.4f\n", p_ge8))
cat(sprintf("P(Poisson >= 7)  = %.4f\n", p_pois_ge7))
cat(sprintf("Empirical       = %.4f\n", empirical))

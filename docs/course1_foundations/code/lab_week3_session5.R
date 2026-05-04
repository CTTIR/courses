# ============================================================
# Biostatistics Courses
# Course 1 — Week 3, Session 5: HT philosophy, p-values, errors
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Show p-values uniform under H0; quantify type I, type II, power.

# --- 2. Data ---------------------------------------------------
simulate_pvals <- function(n_per_group = 30, delta = 0, B = 5000) {
  replicate(B, {
    a <- rnorm(n_per_group, 0, 1)
    b <- rnorm(n_per_group, delta, 1)
    t.test(a, b)$p.value
  })
}
p_h0 <- simulate_pvals(30, 0)
p_h1 <- simulate_pvals(30, 0.5)

# --- 3. Visualise ----------------------------------------------
p <- tibble(p = p_h0) |>
  ggplot(aes(p)) +
  geom_histogram(bins = 20, fill = "grey60", colour = "white") +
  geom_hline(yintercept = length(p_h0) / 20,
             linetype = 2, colour = "firebrick") +
  labs(x = "p-value under H0", y = "Count")
print(p)

# --- 4. Assumptions --------------------------------------------
# p uniform under H0 requires H0 correctly specified.

# --- 5. Conduct / Fit ------------------------------------------
type_I <- mean(p_h0 < 0.05)
power_obs <- mean(p_h1 < 0.05)

grid <- expand_grid(
  n = c(10, 20, 50, 100),
  delta = seq(0, 1.2, by = 0.2)
)
grid$power <- with(grid, mapply(function(nn, dd) {
  mean(simulate_pvals(nn, dd, B = 500) < 0.05)
}, n, delta))

# --- 6. Report -------------------------------------------------
cat(sprintf("Empirical type I: %.3f (nominal 0.05)\n", type_I))
cat(sprintf("Empirical power (d=0.5, n=30): %.3f\n", power_obs))
print(head(grid, 10))

# ============================================================
# Biostatistics Courses
# Course 1 — Week 3, Session 1: Populations, samples, CLT
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Demonstrate the CLT on an exponential population; quantify
# bias and variance of the sample mean.

# --- 2. Data ---------------------------------------------------
rate <- 1
pop_mean <- 1 / rate
pop_sd   <- 1 / rate

sim_means <- function(n, B = 4000) replicate(B, mean(rexp(n, rate)))

# --- 3. Visualise ----------------------------------------------
means_df <- bind_rows(
  tibble(n = "n = 2",   mean = sim_means(2)),
  tibble(n = "n = 5",   mean = sim_means(5)),
  tibble(n = "n = 30",  mean = sim_means(30)),
  tibble(n = "n = 100", mean = sim_means(100))
) |>
  mutate(n = factor(n, levels = c("n = 2", "n = 5", "n = 30", "n = 100")))
p <- means_df |>
  ggplot(aes(mean)) +
  geom_histogram(bins = 40, fill = "grey60", colour = "white") +
  facet_wrap(~ n, scales = "free") +
  geom_vline(xintercept = pop_mean, linetype = 2) +
  labs(x = "Sample mean", y = "Count")
print(p)

# --- 4. Assumptions --------------------------------------------
# iid sampling; finite variance.

# --- 5. Conduct / Fit ------------------------------------------
summarise_means <- function(n, B = 2000) {
  xbars <- replicate(B, mean(rexp(n, rate)))
  tibble(n = n,
         bias = mean(xbars) - pop_mean,
         variance = var(xbars),
         mse = mean((xbars - pop_mean)^2),
         se = sd(xbars))
}
bv <- map_dfr(c(5, 10, 30, 100, 500), summarise_means) |>
  mutate(expected_se = pop_sd / sqrt(n),
         ratio = se / expected_se)
print(bv)

# --- 6. Report -------------------------------------------------
cat("Bias near zero across n; SE scales as 1/sqrt(n).\n")

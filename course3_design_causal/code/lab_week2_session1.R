# ============================================================
# Biostatistics Courses
# Course 3 — Week 2, Session 1: MCAR, MAR, MNAR
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Show that complete-case analysis is unbiased under MCAR and biased
# under MAR and MNAR.

# --- 2. Data ---------------------------------------------------
n  <- 1000
df <- tibble(
  x = rnorm(n, 50, 10),
  y = 2 + 0.5 * x + rnorm(n, 0, 5)
)

mcar <- df |> mutate(y_obs = if_else(runif(n) < 0.30, NA_real_, y), mech = "MCAR")
mar  <- df |> mutate(p = plogis(-2 + 0.05 * (x - 50)),
                     y_obs = if_else(runif(n) < p, NA_real_, y), mech = "MAR")
mnar <- df |> mutate(p = plogis(-2 + 0.05 * (y - mean(y))),
                     y_obs = if_else(runif(n) < p, NA_real_, y), mech = "MNAR")

all <- bind_rows(
  mcar |> select(mech, x, y, y_obs),
  mar  |> select(mech, x, y, y_obs),
  mnar |> select(mech, x, y, y_obs)
)

# --- 3. Visualise ----------------------------------------------
p <- all |>
  mutate(missing = is.na(y_obs)) |>
  ggplot(aes(x, y, colour = missing)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~ mech) +
  labs(colour = "Y missing?")
print(p)

# --- 4. Assumptions --------------------------------------------
# Complete-case unbiased only under MCAR.

# --- 5. Conduct / Fit ------------------------------------------
results <- all |>
  group_by(mech) |>
  summarise(
    truth = mean(y),
    cc    = mean(y_obs, na.rm = TRUE),
    bias  = cc - truth,
    pct_missing = mean(is.na(y_obs)) * 100
  )
print(results)

# --- 6. Report -------------------------------------------------
cat("Bias by mechanism (MCAR, MAR, MNAR):\n")
print(results[c("mech", "bias")])

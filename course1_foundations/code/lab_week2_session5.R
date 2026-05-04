# ============================================================
# Biostatistics Courses
# Course 1 — Week 2, Session 5: Continuous distributions
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Characterise continuous distributions and check fit with Q-Q plots.

# --- 2. Data ---------------------------------------------------
n <- 200
samples <- tibble(
  normal_sample = rnorm(n),
  heavy_tail    = rt(n, df = 3),
  exponential   = rexp(n, rate = 1)
)

# --- 3. Visualise ----------------------------------------------
p <- samples |>
  pivot_longer(everything(), names_to = "sample", values_to = "value") |>
  ggplot(aes(sample = value)) +
  stat_qq(alpha = 0.6) +
  stat_qq_line(colour = "firebrick") +
  facet_wrap(~ sample, scales = "free") +
  labs(x = "Theoretical quantiles", y = "Sample quantiles")
print(p)

# --- 4. Assumptions --------------------------------------------
# iid sampling; Q-Q plot needs n >= ~20.

# --- 5. Conduct / Fit ------------------------------------------
sw <- samples |>
  pivot_longer(everything(), names_to = "sample", values_to = "value") |>
  group_by(sample) |>
  summarise(p = shapiro.test(value)$p.value, .groups = "drop")
print(sw)

# --- 6. Report -------------------------------------------------
cat("Shapiro-Wilk p-values per sample printed above.\n")

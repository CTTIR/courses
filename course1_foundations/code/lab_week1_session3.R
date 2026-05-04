# ============================================================
# Biostatistics Courses
# Course 1 — Week 1, Session 3: Data types, tidy data, accuracy/precision/bias
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Reshape a wide dataset to long form and back; quantify
# accuracy, precision, and bias in simulated measurements.

# --- 2. Data ---------------------------------------------------
clinic <- tibble(
  id = sprintf("P%02d", 1:12),
  sex = sample(c("F", "M"), 12, replace = TRUE),
  visit1_sbp1 = rnorm(12, 140, 10),
  visit1_sbp2 = rnorm(12, 140, 10),
  visit1_sbp3 = rnorm(12, 140, 10),
  visit2_sbp1 = rnorm(12, 135, 10),
  visit2_sbp2 = rnorm(12, 135, 10),
  visit2_sbp3 = rnorm(12, 135, 10)
)

long <- clinic |>
  pivot_longer(
    cols = starts_with("visit"),
    names_to = c("visit", "reading"),
    names_pattern = "visit(\\d)_sbp(\\d)",
    values_to = "sbp"
  ) |>
  mutate(visit = factor(paste0("V", visit)),
         reading = as.integer(reading))

# --- 3. Visualise ----------------------------------------------
p <- long |>
  ggplot(aes(visit, sbp, colour = sex)) +
  geom_jitter(width = 0.1, alpha = 0.6) +
  labs(x = NULL, y = "SBP (mmHg)")
print(p)

# --- 4. Assumptions --------------------------------------------
# Tidy data: one row per observation, one column per variable.
by_visit <- long |>
  group_by(id, visit, sex) |>
  summarise(sbp_mean = mean(sbp), .groups = "drop")
wide <- by_visit |> pivot_wider(names_from = visit, values_from = sbp_mean)

# --- 5. Conduct / Fit ------------------------------------------
truth <- 120
n <- 500
devices <- tibble(
  device_A = rnorm(n, mean = 120, sd = 1),
  device_B = rnorm(n, mean = 125, sd = 1),
  device_C = rnorm(n, mean = 120, sd = 5)
) |>
  pivot_longer(everything(), names_to = "device", values_to = "reading")

summary_table <- devices |>
  group_by(device) |>
  summarise(mean = mean(reading),
            sd = sd(reading),
            bias = mean(reading) - truth,
            rmse = sqrt(mean((reading - truth)^2)))
print(summary_table)

# --- 6. Report -------------------------------------------------
cat("Device A bias:", round(summary_table$bias[1], 2), "\n")
cat("Device B bias:", round(summary_table$bias[2], 2), "\n")
cat("Device C bias:", round(summary_table$bias[3], 2), "\n")

# ============================================================
# Biostatistics Courses
# Course 3 — Week 1, Session 2: Randomised controlled trials
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Treatment reduces symptom score versus placebo in a parallel-group
# RCT. Contrast ITT with per-protocol analyses when non-adherence is
# informative.

# --- 2. Data ---------------------------------------------------
n <- 200
trial <- tibble(
  id    = seq_len(n),
  arm   = sample(rep(c("placebo", "treatment"), each = n / 2)),
  crossed = if_else(arm == "treatment" & runif(n) < 0.15, TRUE, FALSE),
  received = if_else(crossed, "placebo", arm),
  y = rnorm(n, mean = 50, sd = 8) +
      if_else(received == "treatment", -5, 0)
)

# --- 3. Visualise ----------------------------------------------
p <- trial |>
  ggplot(aes(arm, y, fill = arm)) +
  geom_boxplot(alpha = 0.6, colour = "grey30") +
  labs(x = NULL, y = "Symptom score") +
  theme(legend.position = "none")
print(p)

# --- 4. Assumptions --------------------------------------------
print(trial |> group_by(arm) |> summarise(mean = mean(y), sd = sd(y), n = n()))

# --- 5. Conduct / Fit ------------------------------------------
itt <- t.test(y ~ arm, data = trial)
pp  <- t.test(y ~ received, data = trial)
print(itt)
print(pp)

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "ITT diff: %.2f; PP diff: %.2f\n",
  diff(itt$estimate) * -1, diff(pp$estimate) * -1
))

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
# RCT. Contrast ITT with per-protocol analyses with independent simulated non-adherence.

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
itt <- with(trial, t.test(y[arm == "treatment"], y[arm == "placebo"]))
pp <- with(subset(trial, !crossed),
           t.test(y[arm == "treatment"], y[arm == "placebo"]))
as_treated <- with(trial,
                   t.test(y[received == "treatment"], y[received == "placebo"]))
itt_diff <- unname(itt$estimate[1] - itt$estimate[2])
pp_diff <- unname(pp$estimate[1] - pp$estimate[2])
at_diff <- unname(as_treated$estimate[1] - as_treated$estimate[2])
print(itt)
print(pp)

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "Treatment minus placebo: ITT %.2f; PP %.2f; as-treated %.2f\n",
  itt_diff, pp_diff, at_diff
))

# ============================================================
# Biostatistics Courses
# Course 3 — Week 1, Session 3: Adaptive, NI, equivalence trials
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Demonstrate a non-inferiority test against a pre-specified margin.

# --- 2. Data ---------------------------------------------------
n <- 150
trial <- tibble(
  arm = rep(c("comparator", "new"), each = n),
  y   = c(rnorm(n, 70, 10), rnorm(n, 69, 10))
)

# --- 3. Visualise ----------------------------------------------
p <- trial |>
  ggplot(aes(arm, y, fill = arm)) +
  geom_boxplot(alpha = 0.6, colour = "grey30") +
  labs(x = NULL, y = "Outcome") +
  theme(legend.position = "none")
print(p)

# --- 4. Assumptions --------------------------------------------
# Pre-specified margin, independent observations, approximately
# normal residuals within arm.

# --- 5. Conduct / Fit ------------------------------------------
fit <- t.test(y ~ arm, data = trial)
print(fit)

delta <- 3
ci <- fit$conf.int
est <- diff(rev(fit$estimate))  # new - comparator
ni_pass <- ci[1] > -delta

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "Mean diff: %.2f (95%% CI: %.2f, %.2f); margin: -%.1f; NI pass: %s\n",
  est, ci[1], ci[2], delta, ni_pass
))

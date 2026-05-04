# ============================================================
# Biostatistics Courses
# Course 2 — Week 3, Session 2: ANCOVA in RCTs
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Compare post-only, change-score, and ANCOVA in a simulated RCT.

# --- 2. Data ---------------------------------------------------
n <- 200
baseline <- rnorm(n, 140, 15)
arm <- rep(c("placebo", "active"), each = n / 2)
followup <- 0.6 * (baseline - 140) + 140 +
  ifelse(arm == "active", -5, 0) + rnorm(n, 0, 12)
dat <- tibble(baseline, followup, arm,
              change = followup - baseline) |>
  mutate(arm = factor(arm, levels = c("placebo", "active")))

# --- 3. Visualise ----------------------------------------------
p <- ggplot(dat, aes(baseline, followup, colour = arm)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Baseline", y = "Follow-up")
print(p)

# --- 4. Assumptions --------------------------------------------
fit_int <- lm(followup ~ arm * baseline, data = dat)
print(tidy(fit_int))

# --- 5. Conduct / Fit ------------------------------------------
fit_post   <- lm(followup ~ arm, data = dat)
fit_change <- lm(change ~ arm, data = dat)
fit_ancova <- lm(followup ~ arm + baseline, data = dat)
print(tidy(fit_post, conf.int = TRUE))
print(tidy(fit_change, conf.int = TRUE))
print(tidy(fit_ancova, conf.int = TRUE))

# --- 6. Report -------------------------------------------------
cat(sprintf("ANCOVA treatment effect: %.2f\n",
            coef(fit_ancova)["armactive"]))

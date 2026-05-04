# ============================================================
# Biostatistics Courses
# Course 1 — Week 4, Session 5: Sample size, power, Quarto reporting
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(pwr)
library(gtsummary)
library(broom)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Goal ---------------------------------------------------
# Plan a two-arm trial with 80% power to detect a 5 mmHg SBP
# difference at alpha = 0.05, verify by simulation, report.

# --- 2. Data ---------------------------------------------------
pwr_calc <- pwr.t.test(
  d = 0.5, power = 0.80, sig.level = 0.05,
  type = "two.sample", alternative = "two.sided"
)
n <- ceiling(pwr_calc$n)
trial <- tibble(
  arm = rep(c("placebo", "drug"), each = n),
  sbp_change = c(rnorm(n, 0, 10), rnorm(n, -5, 10))
)

# --- 3. Visualise ----------------------------------------------
ns <- seq(10, 200, by = 5)
powers <- sapply(ns, function(n) {
  pwr.t.test(n = n, d = 0.5, sig.level = 0.05,
             type = "two.sample")$power
})
print(
  tibble(n_per_arm = ns, power = powers) |>
    ggplot(aes(n_per_arm, power)) +
    geom_line(linewidth = 0.8) +
    geom_hline(yintercept = 0.8, linetype = 2, colour = "grey50") +
    labs(x = "N per arm", y = "Power")
)

# --- 4. Assumptions --------------------------------------------
# Verify closed-form power by simulation.
sim_trial <- function(n_per_arm, delta = 5, sd = 10) {
  placebo <- rnorm(n_per_arm, 0, sd)
  drug    <- rnorm(n_per_arm, -delta, sd)
  t.test(drug, placebo, var.equal = FALSE)$p.value
}
sim_power <- function(n_per_arm, reps = 500, ...) {
  mean(replicate(reps, sim_trial(n_per_arm, ...)) < 0.05)
}
cat("Simulated power at n =", n, ":", sim_power(n, reps = 1000), "\n")

# --- 5. Conduct / Fit ------------------------------------------
fit <- t.test(sbp_change ~ arm, data = trial, var.equal = FALSE)
print(broom::tidy(fit))

# --- 6. Report -------------------------------------------------
trial |>
  tbl_summary(
    by = arm,
    statistic = list(all_continuous() ~ "{mean} ({sd})"),
    digits    = all_continuous() ~ 1
  ) |>
  add_p() |>
  print()

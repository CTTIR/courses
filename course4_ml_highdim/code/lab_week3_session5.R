# ============================================================
# Biostatistics Courses
# Course 4 — Week 3, Session 5: Time-dependent Brier, IPA, external validation
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(survival)
library(pROC)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Evaluate a Cox model fitted on dev cohort against an external
# cohort with shifted covariate distribution; compute AUC, Brier,
# IPA, and a calibration plot.

# --- 2. Data ---------------------------------------------------
make_cohort <- function(n, mu_x = 0, beta = 0.6) {
  x <- rnorm(n, mu_x)
  lp <- beta * x
  t <- rexp(n, rate = exp(lp - 1))
  c <- rexp(n, rate = 0.1)
  time <- pmin(t, c); event <- as.integer(t <= c)
  tibble(x = x, time = time, event = event)
}
dev <- make_cohort(500, mu_x = 0)
ext <- make_cohort(500, mu_x = 1.0)

# --- 3. Visualise ----------------------------------------------
p1 <- bind_rows(dev |> mutate(cohort = "dev"),
                ext |> mutate(cohort = "ext")) |>
  ggplot(aes(x, fill = cohort)) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity")
print(p1)

# --- 4. Assumptions --------------------------------------------
# Independent right censoring; proportional hazards on dev cohort.

# --- 5. Conduct / Fit ------------------------------------------
fit <- coxph(Surv(time, event) ~ x, data = dev)
horizon <- 3
predict_surv <- function(fit, newdata, t) {
  bh <- basehaz(fit, centered = FALSE)
  H0 <- approx(bh$time, bh$hazard, xout = t, rule = 2)$y
  lp <- predict(fit, newdata = newdata, type = "lp")
  exp(-H0 * exp(lp))
}
s_dev <- predict_surv(fit, dev, horizon)
s_ext <- predict_surv(fit, ext, horizon)
obs_dev <- dev$event == 1 & dev$time <= horizon
obs_ext <- ext$event == 1 & ext$time <= horizon
brier <- function(p, y) mean((p - y)^2)
b_dev <- brier(1 - s_dev, obs_dev)
b_ext <- brier(1 - s_ext, obs_ext)
ipa_dev <- 1 - b_dev / brier(mean(obs_dev), obs_dev)
ipa_ext <- 1 - b_ext / brier(mean(obs_ext), obs_ext)

# --- 6. Report -------------------------------------------------
cat(sprintf("IPA dev: %.2f, IPA ext: %.2f\n", ipa_dev, ipa_ext))
cat(sprintf("Brier dev: %.3f, Brier ext: %.3f\n", b_dev, b_ext))

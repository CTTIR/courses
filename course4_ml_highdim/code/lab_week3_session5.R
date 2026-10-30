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
# Match the mean-centred baseline hazard to the same prediction reference.
# This helper is for the unstratified, fixed-covariate model used in this lab.
predict_surv <- function(fit, newdata, t) {
  bh <- basehaz(fit, centered = TRUE)
  stopifnot(length(t) == 1, is.finite(t), t >= 0, t <= max(bh$time))
  H0 <- c(0, bh$hazard)[findInterval(t, bh$time) + 1L]
  lp <- predict(fit, newdata = newdata, type = "lp", reference = "sample")
  exp(-H0 * exp(lp))
}

# Marginal IPCW is valid here because censoring is independent of X and T.
# Censoring that depends on predictors needs a conditional censoring model.
horizon_weights <- function(data, t) {
  g <- survfit(Surv(time, 1 - event) ~ 1, data = data)
  g_before <- c(1, g$surv)[findInterval(data$time, g$time, left.open = TRUE) + 1L]
  g_at <- c(1, g$surv)[findInterval(t, g$time) + 1L]
  cases <- data$event == 1 & data$time <= t
  controls <- data$time > t
  if (g_at <= 0 || any(g_before[cases] <= 0))
    stop("Insufficient censoring support at this horizon")
  weights <- numeric(nrow(data))
  weights[cases] <- 1 / g_before[cases]
  weights[controls] <- 1 / g_at
  list(cases = cases, controls = controls, weights = weights)
}

score_horizon <- function(data, p_event, t) {
  stopifnot(length(p_event) == nrow(data), all(is.finite(p_event)),
            all(p_event >= 0 & p_event <= 1))
  w <- horizon_weights(data, t)
  brier <- mean(w$weights * (as.numeric(w$cases) - p_event)^2)
  km <- survfit(Surv(time, event) ~ 1, data = data)
  null_risk <- 1 - c(1, km$surv)[findInterval(t, km$time) + 1L]
  null_brier <- mean(w$weights * (as.numeric(w$cases) - null_risk)^2)
  # Cumulative/dynamic AUC: observed cases by t against survivors beyond t.
  auc <- NA_real_
  if (any(w$cases) && any(w$controls)) {
    order_control <- order(p_event[w$controls])
    control_risk <- p_event[w$controls][order_control]
    cumulative_weight <- c(0, cumsum(w$weights[w$controls][order_control]))
    below <- cumulative_weight[findInterval(p_event[w$cases], control_risk,
                                           left.open = TRUE) + 1L]
    at_or_below <- cumulative_weight[findInterval(p_event[w$cases], control_risk) + 1L]
    auc <- sum(w$weights[w$cases] * (below + .5 * (at_or_below - below))) /
      (sum(w$weights[w$cases]) * sum(w$weights[w$controls]))
  }
  c(auc = auc, brier = brier,
    ipa = if (null_brier > 0) 1 - brier / null_brier else NA_real_)
}

s_dev <- predict_surv(fit, dev, horizon)
s_ext <- predict_surv(fit, ext, horizon)
metrics_dev <- score_horizon(dev, 1 - s_dev, horizon)
metrics_ext <- score_horizon(ext, 1 - s_ext, horizon)
b_dev <- unname(metrics_dev["brier"]); b_ext <- unname(metrics_ext["brier"])
ipa_dev <- unname(metrics_dev["ipa"]); ipa_ext <- unname(metrics_ext["ipa"])
auc_dev <- unname(metrics_dev["auc"]); auc_ext <- unname(metrics_ext["auc"])
rbind(development_apparent = metrics_dev, external = metrics_ext)

# --- 6. Report -------------------------------------------------
cat(sprintf("IPA dev: %.2f, IPA ext: %.2f\n", ipa_dev, ipa_ext))
cat(sprintf("Brier dev: %.3f, Brier ext: %.3f\n", b_dev, b_ext))

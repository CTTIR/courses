# ============================================================
# Biostatistics Courses
# Course 3 — Week 3, Session 1: Immortal-time bias and landmarks
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(survival)
library(ggsurvfit)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Show immortal-time bias in a naive Cox model and correct it with
# landmark and time-dependent analyses.

# --- 2. Data ---------------------------------------------------
n <- 500
dat <- tibble(
  id = seq_len(n),
  t_event = rexp(n, rate = 0.02),
  t_drug  = rexp(n, rate = 0.05),
  ever_drug = t_drug < t_event,
  t_drug_obs = pmin(t_drug, t_event),
  t_obs   = pmin(t_event, 100),
  event   = as.integer(t_event <= 100)
)

# --- 3. Visualise ----------------------------------------------
p <- dat |>
  ggplot(aes(t_obs, fill = ever_drug)) +
  geom_histogram(bins = 30, alpha = 0.6, position = "identity") +
  labs(x = "Observed time", y = "Count", fill = "Ever drug?")
print(p)

# --- 4. Assumptions --------------------------------------------
# Proportional hazards, non-informative censoring.

# --- 5. Conduct / Fit ------------------------------------------
fit_naive <- coxph(Surv(t_obs, event) ~ ever_drug, data = dat)
landmark  <- 20
dat_lm <- dat |>
  filter(t_obs > landmark) |>
  mutate(drug_lm = t_drug < landmark,
         t_obs_lm = t_obs - landmark)
fit_lm <- coxph(Surv(t_obs_lm, event) ~ drug_lm, data = dat_lm)

td <- dat |>
  transmute(id, tstart = 0,
            tstop  = if_else(ever_drug, t_drug_obs, t_obs),
            event  = if_else(ever_drug, 0L, event),
            drug   = 0L) |>
  bind_rows(
    dat |> filter(ever_drug) |>
      transmute(id, tstart = t_drug_obs, tstop  = t_obs,
                event  = event, drug = 1L)
  ) |>
  filter(tstop > tstart) |>
  arrange(id, tstart)
fit_td <- coxph(Surv(tstart, tstop, event) ~ drug, data = td)

print(summary(fit_naive))
print(summary(fit_lm))
print(summary(fit_td))

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "HR naive: %.2f; landmark: %.2f; time-dependent: %.2f\n",
  exp(coef(fit_naive)), exp(coef(fit_lm)), exp(coef(fit_td))
))

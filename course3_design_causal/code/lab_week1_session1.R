# ============================================================
# Biostatistics Courses
# Course 3 — Week 1, Session 1: Observational designs and STROBE
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Compare exposure-outcome association recovered by a full cohort
# analysis and a nested case-control sample from the same source.

# --- 2. Data ---------------------------------------------------
n_pop <- 5000
pop <- tibble(
  id       = seq_len(n_pop),
  age      = rnorm(n_pop, 55, 10),
  exposure = rbinom(n_pop, 1, 0.30)
)
lp <- -4 + 0.8 * pop$exposure + 0.04 * (pop$age - 55)
pop <- pop |>
  mutate(prob = plogis(lp),
         outcome = rbinom(n_pop, 1, prob))

cases    <- pop |> filter(outcome == 1)
controls <- pop |>
  filter(outcome == 0) |>
  slice_sample(n = 4 * nrow(cases))
ncc <- bind_rows(cases, controls)

# --- 3. Visualise ----------------------------------------------
p <- pop |>
  count(exposure, outcome) |>
  mutate(exposure = factor(exposure, labels = c("unexposed", "exposed")),
         outcome  = factor(outcome,  labels = c("no", "yes"))) |>
  ggplot(aes(exposure, n, fill = outcome)) +
  geom_col(position = "dodge", alpha = 0.8) +
  labs(x = NULL, y = "Count", fill = "Outcome")
print(p)

# --- 4. Assumptions --------------------------------------------
# Cohort: correct specification of covariates; outcome is a faithful
# measure of incidence; follow-up complete.
# Case-control: controls sampled from same source population as cases;
# outcome rare enough for OR to approximate RR.

# --- 5. Conduct / Fit ------------------------------------------
fit_cohort <- glm(outcome ~ exposure + age, data = pop, family = binomial)
fit_ncc    <- glm(outcome ~ exposure + age, data = ncc, family = binomial)
print(broom::tidy(fit_cohort, conf.int = TRUE, exponentiate = TRUE))
print(broom::tidy(fit_ncc,    conf.int = TRUE, exponentiate = TRUE))

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "Cohort OR: %.2f; NCC OR: %.2f\n",
  exp(coef(fit_cohort))["exposure"],
  exp(coef(fit_ncc))["exposure"]
))

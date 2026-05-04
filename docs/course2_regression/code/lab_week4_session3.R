# ============================================================
# Biostatistics Courses
# Course 2 — Week 4, Session 3: Survival primer (KM, log-rank, Cox)
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(survival)
library(ggsurvfit)
library(broom)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis ---------------------------------------------
# H0: HR_female/male = 1. H1: HR != 1. alpha = 0.05.

# --- 2. Data ---------------------------------------------------
lung2 <- lung |>
  mutate(sex = factor(sex, levels = 1:2, labels = c("male", "female")))

# --- 3. Visualise ----------------------------------------------
print(
  survfit2(Surv(time, status) ~ sex, data = lung2) |>
    ggsurvfit() +
    add_confidence_interval() +
    add_risktable() +
    labs(x = "Days", y = "Survival probability")
)

# --- 4. Assumptions --------------------------------------------
cox_fit <- coxph(Surv(time, status) ~ sex + age, data = lung2)
print(cox.zph(cox_fit))

# --- 5. Conduct / Fit ------------------------------------------
print(survdiff(Surv(time, status) ~ sex, data = lung2))
print(tidy(cox_fit, exponentiate = TRUE, conf.int = TRUE))

# --- 6. Report -------------------------------------------------
hr_row <- tidy(cox_fit, exponentiate = TRUE, conf.int = TRUE) |>
  filter(term == "sexfemale")
cat(sprintf(
  "HR (female vs male) = %.2f (95%% CI %.2f, %.2f), p = %.3f\n",
  hr_row$estimate, hr_row$conf.low, hr_row$conf.high, hr_row$p.value
))

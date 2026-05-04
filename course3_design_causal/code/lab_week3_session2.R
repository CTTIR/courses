# ============================================================
# Biostatistics Courses
# Course 3 — Week 3, Session 2: Competing risks and multistate
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(survival)
library(tidycmprsk)
library(mstate)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Cause-specific cumulative incidence and Fine-Gray subdistribution
# hazards in the colon dataset, plus a small illness-death
# transition matrix.

# --- 2. Data ---------------------------------------------------
data(colon, package = "survival")
dat <- colon |>
  filter(etype == 1) |>
  transmute(id, time, status_rec = status, rx, age, sex) |>
  left_join(
    colon |> filter(etype == 2) |>
      transmute(id, time_d = time, status_d = status),
    by = "id"
  ) |>
  mutate(
    etype = case_when(
      status_rec == 1 ~ 1L,
      status_d   == 1 ~ 2L,
      TRUE            ~ 0L
    ),
    etime = pmin(time, time_d, na.rm = TRUE),
    etype_f = factor(etype, levels = 0:2,
                     labels = c("censored", "recurrence", "death"))
  ) |>
  drop_na(etime, etype_f, rx)

# --- 3. Visualise ----------------------------------------------
p <- ggplot(dat, aes(etime, fill = etype_f)) +
  geom_histogram(bins = 40, alpha = 0.7, position = "identity") +
  labs(x = "Time (days)", y = "Count", fill = NULL)
print(p)

# --- 4. Assumptions --------------------------------------------
# Non-informative censoring within cause; PH for Fine-Gray; Markov
# transitions for the multistate example.

# --- 5. Conduct / Fit ------------------------------------------
cif <- cuminc(Surv(etime, etype_f) ~ rx, data = dat)
print(cif)
fg <- crr(Surv(etime, etype_f) ~ rx + age + sex, data = dat,
          failcode = "recurrence")
print(fg)

tmat <- transMat(x = list(c(2, 3), c(3), c()),
                 names = c("healthy", "ill", "dead"))
print(tmat)

# --- 6. Report -------------------------------------------------
cat("CIFs and Fine-Gray coefficients printed above.\n")

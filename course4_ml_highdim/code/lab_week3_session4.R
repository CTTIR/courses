# ============================================================
# Biostatistics Courses
# Course 4 — Week 3, Session 4: Survival ML (RSF, DeepSurv)
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(survival)
library(randomForestSRC)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Fit RSF and Cox on pbc, compare concordance on a hold-out.

# --- 2. Data ---------------------------------------------------
d <- survival::pbc |>
  as_tibble() |>
  drop_na(bili, albumin, age, edema, protime, stage) |>
  mutate(status = ifelse(status == 2, 1, 0))

# --- 3. Visualise ----------------------------------------------
p1 <- ggplot(d, aes(time / 365.25, fill = factor(status))) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity")
print(p1)

# --- 4. Assumptions --------------------------------------------
# Independent right censoring; proportional hazards for the Cox model
# (RSF relaxes this).

# --- 5. Conduct / Fit ------------------------------------------
idx <- sample(nrow(d), 0.7 * nrow(d))
tr <- d[idx, ]; te <- d[-idx, ]
cox2 <- coxph(Surv(time, status) ~ bili + albumin + age + edema +
                protime + stage, data = tr)
rsf2 <- rfsrc(Surv(time, status) ~ bili + albumin + age + edema +
                protime + stage,
              data = as.data.frame(tr), ntree = 500)
c_cox <- survival::concordance(cox2, newdata = te)$concordance
p_rsf <- predict(rsf2, newdata = as.data.frame(te))$predicted
c_rsf <- survival::concordance(Surv(te$time, te$status) ~ p_rsf,
                               reverse = TRUE)$concordance

# --- 6. Report -------------------------------------------------
cat(sprintf("Cox test concordance: %.3f\n", c_cox))
cat(sprintf("RSF test concordance: %.3f\n", c_rsf))

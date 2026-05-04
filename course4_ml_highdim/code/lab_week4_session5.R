# ============================================================
# Biostatistics Courses
# Course 4 — Week 4, Session 5: TRIPOD-AI, fairness, reproducibility
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(pROC)
library(MASS)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Audit a logistic prediction model on Pima.tr by a synthetic
# subgroup attribute; sketch a targets pipeline.

# --- 2. Data ---------------------------------------------------
d <- as_tibble(MASS::Pima.tr) |>
  mutate(subgroup = sample(c("A", "B"), n(), replace = TRUE,
                           prob = c(0.7, 0.3)))

# --- 3. Visualise ----------------------------------------------
p1 <- ggplot(d, aes(glu, fill = subgroup)) +
  geom_histogram(alpha = 0.7, bins = 20, position = "identity")
print(p1)

# --- 4. Assumptions --------------------------------------------
# Subgroup labels are observed; predictions are well-defined for
# both groups.

# --- 5. Conduct / Fit ------------------------------------------
fit <- glm(type ~ glu + bmi + age, data = d, family = binomial())
d$p <- predict(fit, type = "response")
auc_overall <- as.numeric(auc(roc(d$type, d$p, quiet = TRUE)))
auc_by <- d |>
  group_by(subgroup) |>
  summarise(auc = as.numeric(auc(roc(type, p, quiet = TRUE))),
            n = n(), .groups = "drop")

# targets sketch (not run):
# library(targets)
# tar_script({ list(tar_target(raw, ...), tar_target(fit, ...)) })
# tar_make(); tar_read(report)

# --- 6. Report -------------------------------------------------
cat(sprintf("Overall AUC: %.2f\n", auc_overall))
print(auc_by)

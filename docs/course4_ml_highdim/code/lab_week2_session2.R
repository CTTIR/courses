# ============================================================
# Biostatistics Courses
# Course 4 — Week 2, Session 2: Interpretability and SHAP
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(ranger)
library(DALEX)
library(iml)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Fit a random forest on penguins and produce permutation
# importance, partial dependence, and a Shapley explanation.

# --- 2. Data ---------------------------------------------------
d <- palmerpenguins::penguins |>
  tidyr::drop_na() |>
  mutate(species = factor(species))

# --- 3. Visualise ----------------------------------------------
p1 <- ggplot(d, aes(bill_length_mm, body_mass_g, colour = species)) +
  geom_point(alpha = 0.7)
print(p1)

# --- 4. Assumptions --------------------------------------------
# Feature correlation is moderate; we cross-check importance
# methods to detect artefacts.

# --- 5. Conduct / Fit ------------------------------------------
rf <- ranger(species ~ bill_length_mm + bill_depth_mm +
               flipper_length_mm + body_mass_g,
             data = d, probability = TRUE, num.trees = 500)

explainer <- DALEX::explain(
  model = rf,
  data  = d[, c("bill_length_mm", "bill_depth_mm",
                "flipper_length_mm", "body_mass_g")],
  y     = as.integer(d$species == "Adelie"),
  predict_function = function(m, newdata) predict(m, newdata)$predictions[, "Adelie"],
  label = "rf-Adelie",
  verbose = FALSE
)
vi <- DALEX::model_parts(explainer, type = "variable_importance")
print(vi)

pred_fun <- function(model, newdata) predict(model, newdata)$predictions[, "Adelie"]
predictor <- iml::Predictor$new(rf, data = d[, 3:6],
                                y = as.integer(d$species == "Adelie"),
                                predict.function = pred_fun)
sh <- iml::Shapley$new(predictor, x.interest = d[1, 3:6])

# --- 6. Report -------------------------------------------------
print(sh$results)

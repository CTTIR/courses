# ============================================================
# Biostatistics Courses
# Course 4 — Week 2, Session 5: tidymodels pipelines
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(tidymodels)
library(MASS)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Fit an elastic-net logistic regression with full tidymodels
# pipeline: split, recipe, workflow, tune, finalise, evaluate.

# --- 2. Data ---------------------------------------------------
d <- as_tibble(MASS::Pima.tr)

# --- 3. Visualise ----------------------------------------------
p1 <- ggplot(d, aes(glu, bmi, colour = type)) + geom_point(alpha = 0.7)
print(p1)

# --- 4. Assumptions --------------------------------------------
# Stratified split and folds keep class balance; normalisation
# happens inside CV to avoid leakage.

# --- 5. Conduct / Fit ------------------------------------------
d_split <- initial_split(d, prop = 0.75, strata = type)
d_train <- training(d_split); d_test <- testing(d_split)
folds <- vfold_cv(d_train, v = 5, strata = type)

rec <- recipe(type ~ ., data = d_train) |>
  step_normalize(all_numeric_predictors())
mod <- logistic_reg(penalty = tune(), mixture = tune()) |>
  set_engine("glmnet")
wf  <- workflow() |> add_recipe(rec) |> add_model(mod)
grid <- grid_regular(penalty(), mixture(), levels = 5)
res  <- tune_grid(wf, resamples = folds, grid = grid,
                  metrics = metric_set(roc_auc, accuracy))
best <- select_best(res, metric = "roc_auc")
wf_final <- finalize_workflow(wf, best)
fit_final <- fit(wf_final, data = d_train)
preds <- predict(fit_final, d_test, type = "prob") |>
  bind_cols(predict(fit_final, d_test), d_test)

# --- 6. Report -------------------------------------------------
print(roc_auc(preds, truth = type, .pred_Yes, event_level = "second"))
print(accuracy(preds, truth = type, estimate = .pred_class))

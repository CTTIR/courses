# ============================================================
# Biostatistics Courses
# Course 4 — Week 2, Session 1: Trees, random forests, gradient boosting
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(rpart)
library(ranger)
library(xgboost)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Predict mpg on mtcars with a tree, random forest, and xgboost;
# compare CV errors and variable importance.

# --- 2. Data ---------------------------------------------------
d <- mtcars

# --- 3. Visualise ----------------------------------------------
p1 <- ggplot(d, aes(wt, mpg, colour = factor(cyl))) +
  geom_point() + labs(colour = "cyl")
print(p1)

# --- 4. Assumptions --------------------------------------------
# Axis-aligned splits are sensible; IID observations; response on
# continuous scale.

# --- 5. Conduct / Fit ------------------------------------------
tree_fit <- rpart(mpg ~ ., data = d, cp = 0.01)
rf_fit   <- ranger(mpg ~ ., data = d, importance = "permutation",
                   num.trees = 500)
xg_fit   <- xgboost(
  data = as.matrix(d[, -1]), label = d$mpg,
  nrounds = 100, eta = 0.05, max_depth = 3,
  objective = "reg:squarederror", verbose = 0
)

K <- 5
folds <- sample(rep(1:K, length.out = nrow(d)))
mse <- function(y, yhat) mean((y - yhat)^2)
err_tree <- err_rf <- err_xg <- numeric(K)
for (k in 1:K) {
  tr <- folds != k; te <- folds == k
  f_tr <- d[tr, ]; f_te <- d[te, ]
  t1 <- rpart(mpg ~ ., data = f_tr, cp = 0.01)
  r1 <- ranger(mpg ~ ., data = f_tr, num.trees = 500)
  x1 <- xgboost(
    data = as.matrix(f_tr[, -1]), label = f_tr$mpg,
    nrounds = 100, eta = 0.05, max_depth = 3,
    objective = "reg:squarederror", verbose = 0
  )
  err_tree[k] <- mse(f_te$mpg, predict(t1, f_te))
  err_rf[k]   <- mse(f_te$mpg, predict(r1, f_te)$predictions)
  err_xg[k]   <- mse(f_te$mpg, predict(x1, as.matrix(f_te[, -1])))
}
errs <- c(tree = mean(err_tree), rf = mean(err_rf), xgb = mean(err_xg))

# --- 6. Report -------------------------------------------------
print(errs)

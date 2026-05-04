# ============================================================
# Biostatistics Courses
# Course 4 — Week 1, Session 1: Cross-validation, nested CV, bootstrap .632+
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(glmnet)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Estimate honest generalisation error for a lasso on high-p-low-n
# data using naive CV, nested CV, and the bootstrap .632+.

# --- 2. Data ---------------------------------------------------
n <- 120; p <- 40
X <- matrix(rnorm(n * p), n, p)
beta <- c(rep(1.5, 5), rep(0, p - 5))
y <- as.numeric(X %*% beta + rnorm(n, sd = 1.0))

# --- 3. Visualise ----------------------------------------------
p1 <- tibble(yhat = as.numeric(X %*% beta), y = y) |>
  ggplot(aes(yhat, y)) +
  geom_point(alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0, colour = "grey50") +
  labs(x = "True linear predictor", y = "Observed y")
print(p1)

# --- 4. Assumptions --------------------------------------------
# IID sampling; linear signal + Gaussian noise; K-fold folds are
# independent of y.

# --- 5. Conduct / Fit ------------------------------------------
cv1 <- cv.glmnet(X, y, alpha = 1, nfolds = 5)
naive_mse <- min(cv1$cvm)

K <- 5
folds <- sample(rep(1:K, length.out = n))
outer_mse <- numeric(K)
for (k in 1:K) {
  tr <- folds != k; te <- folds == k
  fit_k <- cv.glmnet(X[tr, ], y[tr], alpha = 1, nfolds = 5)
  yhat  <- as.numeric(predict(fit_k, newx = X[te, ], s = "lambda.min"))
  outer_mse[k] <- mean((y[te] - yhat)^2)
}
nested_mse <- mean(outer_mse)

B <- 50
errs_in <- errs_oob <- numeric(B)
for (b in 1:B) {
  idx <- sample.int(n, n, replace = TRUE)
  oob <- setdiff(seq_len(n), unique(idx))
  fit_b <- cv.glmnet(X[idx, ], y[idx], alpha = 1, nfolds = 5)
  yhat_in  <- as.numeric(predict(fit_b, newx = X[idx, ], s = "lambda.min"))
  yhat_oob <- as.numeric(predict(fit_b, newx = X[oob, ], s = "lambda.min"))
  errs_in[b]  <- mean((y[idx] - yhat_in)^2)
  errs_oob[b] <- mean((y[oob] - yhat_oob)^2)
}
err_app <- mean(errs_in); err_oob <- mean(errs_oob)
err_632 <- 0.368 * err_app + 0.632 * err_oob

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "Naive CV MSE:  %.2f\nNested CV MSE: %.2f\nBoot .632 MSE: %.2f\n",
  naive_mse, nested_mse, err_632
))

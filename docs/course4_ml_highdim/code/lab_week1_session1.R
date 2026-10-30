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

# Apparent error uses the model trained on the original sample.
yhat_full <- as.numeric(predict(cv1, newx = X, s = "lambda.min"))
err_app <- mean((y - yhat_full)^2)
B <- 50
oob_loss <- matrix(NA_real_, nrow = n, ncol = B)
for (b in seq_len(B)) {
  idx <- sample.int(n, n, replace = TRUE)
  oob <- setdiff(seq_len(n), unique(idx))
  if (!length(oob)) next
  # Copies of the same observation stay together in the tuning folds.
  unique_idx <- unique(idx)
  boot_folds <- sample(rep(seq_len(5), length.out = length(unique_idx)))
  fit_b <- cv.glmnet(X[idx, ], y[idx], alpha = 1,
                     foldid = boot_folds[match(idx, unique_idx)])
  yhat_oob <- as.numeric(predict(fit_b, newx = X[oob, , drop = FALSE],
                                 s = "lambda.min"))
  oob_loss[oob, b] <- (y[oob] - yhat_oob)^2
}
stopifnot(all(rowSums(!is.na(oob_loss)) > 0))
# Average within observations first, so each observation has equal weight.
err_oob <- mean(rowMeans(oob_loss, na.rm = TRUE))
# No-information loss: all pairings of observed responses and fitted predictions.
gamma <- mean(outer(y, yhat_full, "-")^2)
bootstrap_errors <- function(apparent, oob, no_information) {
  stopifnot(all(is.finite(c(apparent, oob, no_information))),
            all(c(apparent, oob, no_information) >= 0))
  base <- 0.368 * apparent + 0.632 * oob
  bounded_oob <- min(oob, no_information)
  relative <- if (oob > apparent && no_information > apparent) {
    (bounded_oob - apparent) / (no_information - apparent)
  } else 0
  # Efron & Tibshirani (1997), equations 31-32: bounded correction.
  plus <- base + (bounded_oob - apparent) *
    0.368 * 0.632 * relative / (1 - 0.368 * relative)
  c(boot632 = base, boot632plus = plus, relative_overfit = relative)
}
boot_errors <- bootstrap_errors(err_app, err_oob, gamma)
err_632 <- unname(boot_errors["boot632"])
err_632plus <- unname(boot_errors["boot632plus"])
c(apparent = err_app, oob = err_oob, boot_errors, nested = nested_mse)

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "Naive CV MSE:  %.2f\nNested CV MSE: %.2f\nBoot .632 MSE: %.2f\nBoot .632+ MSE: %.2f\n",
  naive_mse, nested_mse, err_632, err_632plus
))

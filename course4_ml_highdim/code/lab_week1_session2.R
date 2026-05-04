# ============================================================
# Biostatistics Courses
# Course 4 — Week 1, Session 2: Regularisation (ridge, lasso, elastic net)
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(glmnet)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Compare ridge, lasso, and elastic net on a simulated high-d
# regression with block-correlated predictors.

# --- 2. Data ---------------------------------------------------
n <- 100; p <- 200
Z <- matrix(rnorm(n * (p / 10)), n, p / 10)
X <- Z[, rep(seq_len(p / 10), each = 10)] + 0.2 * matrix(rnorm(n * p), n, p)
beta <- c(rep(2, 5), rep(-1.5, 5), rep(0, p - 10))
y <- as.numeric(X %*% beta + rnorm(n))

# --- 3. Visualise ----------------------------------------------
p1 <- tibble(i = seq_along(beta), beta = beta) |>
  ggplot(aes(i, beta)) + geom_segment(aes(xend = i, yend = 0)) +
  labs(x = "feature index", y = "true coefficient")
print(p1)

# --- 4. Assumptions --------------------------------------------
# Standardisation before penalisation (glmnet does this by default).
# Correlation structure in predictors is the stress test.

# --- 5. Conduct / Fit ------------------------------------------
cv_ridge <- cv.glmnet(X, y, alpha = 0,   nfolds = 5)
cv_lasso <- cv.glmnet(X, y, alpha = 1,   nfolds = 5)
cv_enet  <- cv.glmnet(X, y, alpha = 0.5, nfolds = 5)

# --- 6. Report -------------------------------------------------
res <- tibble(
  model = c("ridge", "lasso", "enet"),
  min_cvmse = c(min(cv_ridge$cvm), min(cv_lasso$cvm), min(cv_enet$cvm)),
  nonzero   = c(sum(coef(cv_ridge, s = "lambda.min") != 0),
                sum(coef(cv_lasso, s = "lambda.min") != 0),
                sum(coef(cv_enet,  s = "lambda.min") != 0))
)
print(res)

# ============================================================
# Biostatistics Courses
# Course 4 — Week 2, Session 3: Tabular neural networks with torch
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Fit a simple regression by manual gradient descent; show the
# analogous torch training loop (not executed).

# --- 2. Data ---------------------------------------------------
n <- 500; p <- 10
X <- matrix(rnorm(n * p), n, p)
beta <- c(2, -1, 0.5, rep(0, p - 3))
y <- as.numeric(X %*% beta + rnorm(n, 0, 0.5))

# --- 3. Visualise ----------------------------------------------
p1 <- tibble(i = seq_len(n), y = y) |>
  ggplot(aes(i, y)) + geom_point(alpha = 0.3, size = 0.6)
print(p1)

# --- 4. Assumptions --------------------------------------------
# Inputs standardised (here already ~N(0,1)); loss surface is
# convex for a linear model, nonconvex for a real NN.

# --- 5. Conduct / Fit ------------------------------------------
w <- rep(0, p); lr <- 0.01
losses <- numeric(200)
for (step in 1:200) {
  yhat <- X %*% w
  resid <- as.numeric(y - yhat)
  grad <- -2 * t(X) %*% resid / n
  w <- w - lr * grad
  losses[step] <- mean(resid^2)
}

# torch equivalent (not run):
# library(torch)
# x_t <- torch_tensor(X, dtype = torch_float())
# y_t <- torch_tensor(matrix(y, ncol = 1), dtype = torch_float())
# net <- nn_sequential(nn_linear(p, 16), nn_relu(), nn_linear(16, 1))
# optimizer <- optim_adam(net$parameters, lr = 1e-2)
# loss_fn <- nn_mse_loss()

# --- 6. Report -------------------------------------------------
cat(sprintf("Final MSE after 200 steps: %.4f\n", tail(losses, 1)))

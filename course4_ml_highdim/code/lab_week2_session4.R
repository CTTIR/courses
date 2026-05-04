# ============================================================
# Biostatistics Courses
# Course 4 — Week 2, Session 4: Imaging and sequence models intro
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Manually compute 2-D and 1-D convolutions on toy data to make
# the building blocks of CNNs explicit.

# --- 2. Data ---------------------------------------------------
img <- matrix(0, 16, 16)
img[5:10, 5:10] <- 1
img <- img + matrix(rnorm(256, 0, 0.1), 16, 16)
seq1 <- c(rep(0, 10), rep(1, 5), rep(0, 10))

# --- 3. Visualise ----------------------------------------------
image(t(img[16:1, ]), col = grey.colors(100), main = "toy image")

# --- 4. Assumptions --------------------------------------------
# Locality for images; ordered context for sequences.

# --- 5. Conduct / Fit ------------------------------------------
kernel <- matrix(c(-1, -1, -1, -1, 8, -1, -1, -1, -1), 3, 3)
conv2d <- function(img, k) {
  kh <- nrow(k); kw <- ncol(k)
  out <- matrix(0, nrow(img) - kh + 1, ncol(img) - kw + 1)
  for (i in seq_len(nrow(out))) for (j in seq_len(ncol(out)))
    out[i, j] <- sum(img[i:(i + kh - 1), j:(j + kw - 1)] * k)
  out
}
feat <- conv2d(img, kernel)

conv1d <- function(x, k) {
  out <- numeric(length(x) - length(k) + 1)
  for (i in seq_along(out)) out[i] <- sum(x[i:(i + length(k) - 1)] * k)
  out
}
feat1d <- conv1d(seq1, c(-1, 1))

# torch sketches (not run):
# library(torch)
# cnn <- nn_sequential(nn_conv2d(1, 8, 3, padding = 1), nn_relu(), ...)

# --- 6. Report -------------------------------------------------
cat("2D feature map dims:", dim(feat), "\n")
cat("1D feature response range:", range(feat1d), "\n")

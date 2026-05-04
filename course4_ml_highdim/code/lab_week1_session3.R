# ============================================================
# Biostatistics Courses
# Course 4 — Week 1, Session 3: PCA, factor analysis, CCA, LDA
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(MASS)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Compare PCA (unsupervised) and LDA (supervised) projections on
# iris, and classify species with LDA.

# --- 2. Data ---------------------------------------------------
d <- iris

# --- 3. Visualise ----------------------------------------------
p1 <- d |>
  pivot_longer(-Species) |>
  ggplot(aes(value, fill = Species)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ name, scales = "free")
print(p1)

# --- 4. Assumptions --------------------------------------------
# PCA: centred features. LDA: approximately Gaussian per class with
# common covariance.

# --- 5. Conduct / Fit ------------------------------------------
pca <- prcomp(d[, 1:4], scale. = TRUE)
lda_fit <- lda(Species ~ ., data = d)

idx <- sample(nrow(d), 0.7 * nrow(d))
fit2 <- lda(Species ~ ., data = d[idx, ])
pred <- predict(fit2, d[-idx, ])$class
acc <- mean(pred == d$Species[-idx])

# --- 6. Report -------------------------------------------------
cat(sprintf("PC1+PC2 variance explained: %.1f%%\n",
            sum(summary(pca)$importance[2, 1:2]) * 100))
cat(sprintf("LDA hold-out accuracy: %.1f%%\n", acc * 100))

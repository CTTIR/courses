# ============================================================
# Biostatistics Courses
# Course 4 — Week 1, Session 4: Clustering (k-means, hierarchical, model-based)
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(mclust)
library(cluster)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Recover three simulated Gaussian blobs via k-means, hierarchical
# and model-based clustering; compare partitions.

# --- 2. Data ---------------------------------------------------
make_blob <- function(n, mu, sd = 1) matrix(rnorm(n * 5, 0, sd), n, 5) +
  rep(mu, each = n)
X <- rbind(
  make_blob(60, c(0, 0, 0, 0, 0)),
  make_blob(40, c(3, 0, 0, 0, 0)),
  make_blob(30, c(0, 3, 0, 0, 0))
)
true_lbl <- rep(c("A", "B", "C"), c(60, 40, 30))

# --- 3. Visualise ----------------------------------------------
pc <- prcomp(X)$x[, 1:2]
p1 <- tibble(PC1 = pc[, 1], PC2 = pc[, 2], group = true_lbl) |>
  ggplot(aes(PC1, PC2, colour = group)) + geom_point(alpha = 0.7)
print(p1)

# --- 4. Assumptions --------------------------------------------
# k-means: spherical equal-variance clusters. mclust: Gaussian
# mixture. hclust: Euclidean distance is meaningful.

# --- 5. Conduct / Fit ------------------------------------------
wss <- sapply(2:8, function(k) kmeans(X, centers = k, nstart = 10)$tot.withinss)
sil <- sapply(2:8, function(k) {
  km <- kmeans(X, centers = k, nstart = 10)
  mean(silhouette(km$cluster, dist(X))[, 3])
})
hc <- hclust(dist(X), method = "ward.D2")
mc <- Mclust(X, G = 1:6)

# --- 6. Report -------------------------------------------------
cat(sprintf("mclust selected G = %d\n", mc$G))
cat(sprintf("Best k by silhouette: k = %d (mean sil = %.2f)\n",
            which.max(sil) + 1, max(sil)))

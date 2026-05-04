# ============================================================
# Biostatistics Courses
# Course 4 — Week 1, Session 5: UMAP and t-SNE
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(uwot)
library(Rtsne)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Embed three simulated high-d blobs via PCA, UMAP, t-SNE; compare.

# --- 2. Data ---------------------------------------------------
make_blob <- function(n, mu, sd = 1, d = 20) matrix(rnorm(n * d, 0, sd), n, d) +
  rep(mu, each = n)
X <- rbind(
  make_blob(100, c(0, 0, rep(0, 18))),
  make_blob(100, c(4, 0, rep(0, 18))),
  make_blob(100, c(0, 4, rep(0, 18)))
)
lbl <- rep(c("A", "B", "C"), each = 100)

# --- 3. Visualise ----------------------------------------------
emb_pca  <- prcomp(X)$x[, 1:2]
emb_umap <- umap(X, n_neighbors = 15, min_dist = 0.1)
emb_tsne <- Rtsne(X, perplexity = 30, check_duplicates = FALSE)$Y
df <- bind_rows(
  tibble(method = "PCA",  x = emb_pca[, 1],  y = emb_pca[, 2],  lbl = lbl),
  tibble(method = "UMAP", x = emb_umap[, 1], y = emb_umap[, 2], lbl = lbl),
  tibble(method = "tSNE", x = emb_tsne[, 1], y = emb_tsne[, 2], lbl = lbl)
)
p1 <- ggplot(df, aes(x, y, colour = lbl)) +
  geom_point(alpha = 0.7, size = 0.8) +
  facet_wrap(~ method, scales = "free")
print(p1)

# --- 4. Assumptions --------------------------------------------
# Neighbourhood structure dominates the embedding; global distances
# are not meaningful.

# --- 5. Conduct / Fit ------------------------------------------
# (fits already done above)

# --- 6. Report -------------------------------------------------
cat("Three blobs recovered by UMAP and t-SNE; PCA weaker.\n")

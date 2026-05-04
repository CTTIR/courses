# ============================================================
# Biostatistics Courses
# Course 4 — Week 4, Session 3: scRNA-seq with Seurat
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(uwot)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Recover three simulated cell types through a minimal
# preprocess-reduce-cluster-embed pipeline; Seurat sketched.

# --- 2. Data ---------------------------------------------------
n_cell <- 300; n_gene <- 500
cell_type <- rep(c("T", "B", "myeloid"), each = n_cell / 3)
mu_base <- exp(rnorm(n_gene, 1, 1))
X <- matrix(0, n_cell, n_gene)
for (i in seq_len(n_cell)) {
  program <- rep(1, n_gene)
  if (cell_type[i] == "T")       program[1:20]  <- 5
  if (cell_type[i] == "B")       program[21:40] <- 5
  if (cell_type[i] == "myeloid") program[41:60] <- 5
  X[i, ] <- rnbinom(n_gene, mu = mu_base * program, size = 2)
}

# --- 3. Visualise ----------------------------------------------
p1 <- tibble(lib = rowSums(X), ct = cell_type) |>
  ggplot(aes(ct, lib)) + geom_boxplot()
print(p1)

# --- 4. Assumptions --------------------------------------------
# Negative-binomial counts per cell; variable-gene selection
# identifies discriminating programmes.

# --- 5. Conduct / Fit ------------------------------------------
logX <- log1p(sweep(X, 1, rowSums(X), FUN = "/") * 1e4)
gene_var <- apply(logX, 2, var)
keep <- order(gene_var, decreasing = TRUE)[1:100]
pcs <- prcomp(logX[, keep])$x[, 1:10]
emb <- umap(pcs, n_neighbors = 20, min_dist = 0.1)
km <- kmeans(pcs, centers = 3, nstart = 10)

# Seurat sketch (not run):
# library(Seurat)
# obj <- CreateSeuratObject(counts = t(X))
# obj <- NormalizeData(obj); obj <- FindVariableFeatures(obj)
# obj <- RunPCA(obj); obj <- RunUMAP(obj, dims = 1:10)

# --- 6. Report -------------------------------------------------
print(table(cluster = km$cluster, truth = cell_type))

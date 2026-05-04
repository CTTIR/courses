# ============================================================
# Biostatistics Courses
# Course 4 — Week 4, Session 1: RNA-seq with DESeq2 / edgeR
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(MASS)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Differential expression on a simulated 500-gene, 10-sample
# matrix; NB GLM per gene with BH adjustment; DESeq2/edgeR sketch.

# --- 2. Data ---------------------------------------------------
n_gene <- 500; n_samp <- 10
group <- rep(c("A", "B"), each = 5)
mu <- 2 * runif(n_gene, 1, 10)
lfc <- c(rep(log(3), 10), rep(0, n_gene - 10))
counts <- sapply(seq_len(n_samp), function(j) {
  rate <- mu * exp(ifelse(group[j] == "B", lfc, 0))
  rnbinom(n_gene, mu = rate, size = 5)
})
rownames(counts) <- paste0("g", seq_len(n_gene))
colnames(counts) <- paste0("s", seq_len(n_samp))

# --- 3. Visualise ----------------------------------------------
p1 <- tibble(mean = rowMeans(counts), var = apply(counts, 1, var)) |>
  ggplot(aes(mean, var)) + geom_point(alpha = 0.3) +
  scale_x_log10() + scale_y_log10()
print(p1)

# --- 4. Assumptions --------------------------------------------
# Negative-binomial counts per gene; common dispersion baseline;
# equal library sizes (simulated).

# --- 5. Conduct / Fit ------------------------------------------
pvals <- numeric(n_gene); logfcs <- numeric(n_gene)
for (g in seq_len(n_gene)) {
  y <- counts[g, ]
  fit <- try(glm.nb(y ~ group), silent = TRUE)
  if (inherits(fit, "try-error")) { pvals[g] <- NA; next }
  s <- summary(fit)
  pvals[g]  <- s$coefficients[2, 4]
  logfcs[g] <- s$coefficients[2, 1]
}
padj <- p.adjust(pvals, method = "BH")

# DESeq2 sketch (not run):
# library(DESeq2)
# dds <- DESeqDataSetFromMatrix(counts, colData = ..., design = ~ group)
# dds <- DESeq(dds); res <- results(dds)

# --- 6. Report -------------------------------------------------
cat(sprintf("True DE genes recovered at FDR<0.05: %.0f%%\n",
            mean(padj[1:10] < 0.05, na.rm = TRUE) * 100))
cat(sprintf("Null genes flagged (FDR<0.05): %.1f%%\n",
            mean(padj[11:n_gene] < 0.05, na.rm = TRUE) * 100))

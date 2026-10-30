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
  rate <- mu * exp(if (group[j] == "B") lfc else rep(0, n_gene))
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
pvals <- logfcs <- rep(NA_real_, n_gene)
fit_problems <- rep("", n_gene)
for (g in seq_len(n_gene)) {
  y <- counts[g, ]
  problems <- character()
  fit <- tryCatch(withCallingHandlers(
    glm.nb(y ~ group),
    warning = function(w) problems <<- c(problems, conditionMessage(w))
  ), error = function(e) {
    problems <<- c(problems, conditionMessage(e)); NULL
  })
  if (is.null(fit) || length(problems) || !isTRUE(fit$converged)) {
    fit_problems[g] <- paste(c(problems, "fit not used for inference"), collapse = "; ")
    next
  }
  estimates <- summary(fit)$coefficients
  pvals[g] <- estimates[2, 4]
  logfcs[g] <- estimates[2, 1]
}
padj <- p.adjust(pvals, method = "BH", n = n_gene)
discovered <- !is.na(padj) & padj < .05
recovery <- mean(discovered[1:10])
null_flagged <- mean(discovered[11:n_gene])
fdp <- sum(discovered[11:n_gene]) / max(sum(discovered), 1)
cat("Genes with failed or warned fits (excluded):", sum(nzchar(fit_problems)), "\n")
print(head(data.frame(gene = rownames(counts), reason = fit_problems)[nzchar(fit_problems), ]))

# DESeq2 sketch (not run):
# library(DESeq2)
# dds <- DESeqDataSetFromMatrix(counts, colData = ..., design = ~ group)
# dds <- DESeq(dds); res <- results(dds)

# --- 6. Report -------------------------------------------------
cat(sprintf("True DE genes recovered at BH-adjusted p<0.05: %.0f%%\n",
            recovery * 100))
cat(sprintf("Null genes flagged (BH-adjusted p<0.05): %.1f%%\n",
            null_flagged * 100))

cat(sprintf("Realised false-discovery proportion: %.1f%%\n", 100 * fdp))

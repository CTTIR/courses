# ============================================================
# Biostatistics Courses
# Course 4 — Week 4, Session 2: Enrichment analysis (GSEA / ORA)
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Perform a hypergeometric ORA by hand and sketch a running-sum
# GSEA on a simulated ranked gene list.

# --- 2. Data ---------------------------------------------------
N <- 5000
pathway <- sample(seq_len(N), 80)
true_de <- unique(c(sample(pathway, 40), sample(setdiff(seq_len(N), pathway), 60)))

# --- 3. Visualise ----------------------------------------------
p1 <- tibble(in_pathway = seq_len(N) %in% pathway,
             de = seq_len(N) %in% true_de) |>
  count(in_pathway, de) |>
  ggplot(aes(in_pathway, n, fill = de)) +
  geom_col(position = "dodge")
print(p1)

# --- 4. Assumptions --------------------------------------------
# Background universe is the set of tested genes; gene-set
# independence (violated for overlapping pathways).

# --- 5. Conduct / Fit ------------------------------------------
n_de <- length(true_de)
k_in <- sum(true_de %in% pathway)
p_hyper <- phyper(k_in - 1, 80, N - 80, n_de, lower.tail = FALSE)

stat <- rnorm(N)
stat[pathway] <- stat[pathway] + 1.2
names(stat) <- paste0("g", seq_len(N))
stat <- sort(stat, decreasing = TRUE)
in_set <- names(stat) %in% paste0("g", pathway)
p_hit <- abs(stat) / sum(abs(stat[in_set]))
p_miss <- 1 / sum(!in_set)
run_sum <- cumsum(ifelse(in_set, p_hit, -p_miss))
ES <- run_sum[which.max(abs(run_sum))]

# fgsea sketch (not run):
# library(fgsea)
# fgsea(list(pathway = paste0("g", pathway)), stat, minSize = 15)

# --- 6. Report -------------------------------------------------
cat(sprintf("ORA overlap: %d (expected %.1f), p = %.2g\n",
            k_in, n_de * 80 / N, p_hyper))
cat(sprintf("GSEA ES: %.2f\n", ES))

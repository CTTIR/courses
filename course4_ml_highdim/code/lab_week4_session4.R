# ============================================================
# Biostatistics Courses
# Course 4 — Week 4, Session 4: FDR, knockoffs, replication crisis
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Compare uncorrected, Bonferroni, and BH on 1000 tests with
# 50 true alternatives; sketch knockoffs.

# --- 2. Data ---------------------------------------------------
m <- 1000; m1 <- 50
is_alt <- c(rep(TRUE, m1), rep(FALSE, m - m1))
mu <- ifelse(is_alt, 3, 0)
z <- rnorm(m, mu, 1)
p <- 2 * (1 - pnorm(abs(z)))

# --- 3. Visualise ----------------------------------------------
p1 <- tibble(p = p, is_alt = is_alt) |>
  ggplot(aes(p, fill = is_alt)) +
  geom_histogram(bins = 40, position = "identity", alpha = 0.7)
print(p1)

# --- 4. Assumptions --------------------------------------------
# Independent tests (or positive dependence for BH); well-defined
# null distribution.

# --- 5. Conduct / Fit ------------------------------------------
bonf <- p.adjust(p, method = "bonferroni")
bh   <- p.adjust(p, method = "BH")
res <- tibble(
  method = c("raw", "Bonferroni", "BH"),
  discovered = c(sum(p < 0.05), sum(bonf < 0.05), sum(bh < 0.05)),
  true_pos   = c(sum(p[is_alt] < 0.05),
                 sum(bonf[is_alt] < 0.05),
                 sum(bh[is_alt] < 0.05)),
  false_pos  = c(sum(p[!is_alt] < 0.05),
                 sum(bonf[!is_alt] < 0.05),
                 sum(bh[!is_alt] < 0.05))
) |> mutate(fdp = false_pos / pmax(discovered, 1))

# knockoff sketch (not run):
# library(knockoff)
# ko <- knockoff.filter(X, y, fdr = 0.1); ko$selected

# --- 6. Report -------------------------------------------------
print(res)

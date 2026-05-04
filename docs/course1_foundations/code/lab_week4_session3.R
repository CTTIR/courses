# ============================================================
# Biostatistics Courses
# Course 1 — Week 4, Session 3: Pearson and Spearman correlation
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(datasauRus)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Compare Pearson and Spearman in linear and monotone-nonlinear cases.

# --- 2. Data ---------------------------------------------------
n <- 200
x <- rnorm(n)
y_linear   <- 0.6 * x + rnorm(n, 0, 0.8)
y_monotone <- exp(x) + rnorm(n, 0, 0.5)

# --- 3. Visualise ----------------------------------------------
p <- datasaurus_dozen |>
  ggplot(aes(x, y)) +
  geom_point(alpha = 0.4, size = 0.8) +
  facet_wrap(~ dataset) +
  labs(x = NULL, y = NULL)
print(p)

# --- 4. Assumptions --------------------------------------------
# Pearson: linear + bivariate-normal. Spearman: monotone.

# --- 5. Conduct / Fit ------------------------------------------
p1_pearson  <- cor.test(x, y_linear,   method = "pearson")
p1_spearman <- cor.test(x, y_linear,   method = "spearman", exact = FALSE)
p2_pearson  <- cor.test(x, y_monotone, method = "pearson")
p2_spearman <- cor.test(x, y_monotone, method = "spearman", exact = FALSE)

results <- tibble(
  relationship = c("linear", "linear", "monotone", "monotone"),
  method = c("Pearson", "Spearman", "Pearson", "Spearman"),
  est = c(p1_pearson$estimate, p1_spearman$estimate,
          p2_pearson$estimate, p2_spearman$estimate),
  p = c(p1_pearson$p.value, p1_spearman$p.value,
        p2_pearson$p.value, p2_spearman$p.value)
)
print(results)

# --- 6. Report -------------------------------------------------
cat("See results table above; monotone-case Spearman > Pearson.\n")

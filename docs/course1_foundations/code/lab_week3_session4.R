# ============================================================
# Biostatistics Courses
# Course 1 — Week 3, Session 4: One-sample t and proportion tests
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# A: H0 mu = 95 for glucose. B: H0 pi = 0.60 for acceptance.

# --- 2. Data ---------------------------------------------------
n <- 40
glucose <- rnorm(n, 100, 12)
accept <- 78
total  <- 120

# --- 3. Visualise ----------------------------------------------
p <- tibble(glucose) |>
  ggplot(aes(glucose)) +
  geom_histogram(bins = 15, fill = "grey60", colour = "white") +
  geom_vline(xintercept = 95, linetype = 2) +
  geom_vline(xintercept = mean(glucose), colour = "firebrick") +
  labs(x = "Glucose", y = "Count")
print(p)

# --- 4. Assumptions --------------------------------------------
# t-test: approx normality of sample mean; prop test: np0 >= 5.

# --- 5. Conduct / Fit ------------------------------------------
tt <- t.test(glucose, mu = 95)
pt_large <- prop.test(accept, total, p = 0.60)
pt_exact <- binom.test(accept, total, p = 0.60)
print(tt)
print(pt_large)
print(pt_exact)

# --- 6. Report -------------------------------------------------
cat(sprintf("Glucose: mean=%.1f t=%.2f p=%.3f\n",
            mean(glucose), tt$statistic, tt$p.value))
cat(sprintf("Acceptance: %d/%d = %.3f, exact p=%.3f\n",
            accept, total, accept/total, pt_exact$p.value))

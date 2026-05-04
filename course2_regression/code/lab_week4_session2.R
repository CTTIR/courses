# ============================================================
# Biostatistics Courses
# Course 2 — Week 4, Session 2: Kappa, ICC, Bland–Altman
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
library(psych)
library(irr)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Measurement agreement: categorical (kappa) and continuous (ICC, BA).

# --- 2. Data ---------------------------------------------------
cats <- c("normal", "mild", "severe")
truth <- sample(cats, 100, replace = TRUE, prob = c(0.5, 0.3, 0.2))
r1 <- ifelse(runif(100) < 0.2, sample(cats, 100, replace = TRUE), truth)
r2 <- ifelse(runif(100) < 0.25, sample(cats, 100, replace = TRUE), truth)
kap_tbl <- tibble(r1 = factor(r1, levels = cats),
                  r2 = factor(r2, levels = cats))
n <- 60
true_val <- rnorm(n, 100, 15)
inst1 <- true_val + rnorm(n, 0, 3)
inst2 <- true_val + 2 + rnorm(n, 0, 3)
meas <- tibble(inst1, inst2)

# --- 3. Visualise ----------------------------------------------
ba <- meas |> mutate(mean_val = (inst1 + inst2) / 2,
                    diff_val = inst2 - inst1)
loa <- mean(ba$diff_val) + c(-1.96, 0, 1.96) * sd(ba$diff_val)
p <- ggplot(ba, aes(mean_val, diff_val)) +
  geom_point(alpha = 0.7) +
  geom_hline(yintercept = loa[1], linetype = 2, colour = "firebrick") +
  geom_hline(yintercept = loa[2], linetype = 1, colour = "steelblue") +
  geom_hline(yintercept = loa[3], linetype = 2, colour = "firebrick") +
  labs(x = "Mean", y = "Difference")
print(p)

# --- 4. Assumptions --------------------------------------------
# differences approximately normal across the range.

# --- 5. Conduct / Fit ------------------------------------------
print(kappa2(kap_tbl[, c("r1", "r2")]))
print(ICC(as.matrix(meas)))

# --- 6. Report -------------------------------------------------
cat(sprintf("Kappa: %.2f; mean bias: %.1f (LoA: %.1f, %.1f)\n",
            kappa2(kap_tbl[, c("r1","r2")])$value,
            mean(ba$diff_val), loa[1], loa[3]))

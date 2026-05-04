# ============================================================
# Biostatistics Courses
# Course 1 — Week 4, Session 2: Two proportions, chi-square, RR/OR
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Test H0: event independent of treatment; estimate RD, RR, OR.

# --- 2. Data ---------------------------------------------------
n_per <- 200
sim <- tibble(
  arm = rep(c("control", "treatment"), each = n_per),
  event = c(rbinom(n_per, 1, 0.25),
            rbinom(n_per, 1, 0.15))
)
tab <- table(arm = sim$arm, event = sim$event)

# --- 3. Visualise ----------------------------------------------
p <- as_tibble(tab) |>
  mutate(arm = factor(arm, levels = c("control", "treatment")),
         event = recode(event, `0` = "no event", `1` = "event")) |>
  ggplot(aes(arm, n, fill = event)) +
  geom_col(position = "fill", alpha = 0.7) +
  labs(x = NULL, y = "Proportion", fill = NULL)
print(p)

# --- 4. Assumptions --------------------------------------------
print(chisq.test(tab)$expected)

# --- 5. Conduct / Fit ------------------------------------------
ct <- chisq.test(tab, correct = FALSE)
ft <- fisher.test(tab)
pt <- prop.test(x = tab[, "1"], n = rowSums(tab), correct = FALSE)

p_ctrl <- tab["control",   "1"] / sum(tab["control", ])
p_trt  <- tab["treatment", "1"] / sum(tab["treatment", ])
rd <- p_trt - p_ctrl
rr <- p_trt / p_ctrl
or <- (tab["treatment","1"] * tab["control","0"]) /
      (tab["treatment","0"] * tab["control","1"])

# Goodness-of-fit
obs <- c(AA = 260, Aa = 290, aa = 50)
exp_probs <- c(AA = 0.49, Aa = 0.42, aa = 0.09)
gof <- chisq.test(obs, p = exp_probs)

# --- 6. Report -------------------------------------------------
cat(sprintf("Chi-sq p = %.4f, Fisher p = %.4f\n",
            ct$p.value, ft$p.value))
cat(sprintf("RD=%.3f RR=%.2f OR=%.2f\n", rd, rr, or))
cat(sprintf("GoF chi-sq = %.3f, p = %.4f\n",
            gof$statistic, gof$p.value))

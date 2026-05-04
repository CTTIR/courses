# ============================================================
# Biostatistics Courses
# Course 1 — Week 4, Session 1: Two-sample and paired t-tests
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(effectsize)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Compare means in independent and paired designs; effect sizes.

# --- 2. Data ---------------------------------------------------
n <- 40
trt <- rnorm(n, 135, 12)
pla <- rnorm(n, 142, 12)
df_ind <- tibble(arm = rep(c("placebo", "treatment"), each = n),
                 sbp = c(pla, trt))

n2 <- 30
pre  <- rnorm(n2, 148, 10)
post <- pre - rnorm(n2, 5, 7)
df_pair <- tibble(id = seq_len(n2), pre = pre, post = post) |>
  mutate(delta = post - pre)

# --- 3. Visualise ----------------------------------------------
p <- df_ind |>
  ggplot(aes(arm, sbp, fill = arm)) +
  geom_boxplot(alpha = 0.6, colour = "grey30") +
  labs(x = NULL, y = "SBP (mmHg)") +
  theme(legend.position = "none")
print(p)

# --- 4. Assumptions --------------------------------------------
# Welch: approx normal sample means. Paired: approx normal diffs.

# --- 5. Conduct / Fit ------------------------------------------
tt_welch  <- t.test(sbp ~ arm, data = df_ind, var.equal = FALSE)
tt_paired <- t.test(df_pair$post, df_pair$pre, paired = TRUE)
d_ind    <- cohens_d(sbp ~ arm, data = df_ind)
g_ind    <- hedges_g(sbp ~ arm, data = df_ind)
d_paired <- cohens_d(df_pair$post, df_pair$pre, paired = TRUE)
print(tt_welch)
print(tt_paired)

# --- 6. Report -------------------------------------------------
cat(sprintf("Welch diff = %.1f, p = %.3f, d = %.2f\n",
            diff(rev(tt_welch$estimate)),
            tt_welch$p.value,
            d_ind$Cohens_d))
cat(sprintf("Paired delta = %.1f, p = %.3f, d = %.2f\n",
            mean(df_pair$delta),
            tt_paired$p.value,
            d_paired$Cohens_d))

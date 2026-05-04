# ============================================================
# Biostatistics Courses
# Course 1 — Week 1, Session 1: Scientific process and research workflow
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Goal ---------------------------------------------------
# Simulate a two-arm trial of a blood-pressure drug and walk through
# every stage of the research workflow.

# --- 2. Data ---------------------------------------------------
n <- 120
df <- tibble(
  id    = seq_len(n),
  arm   = rep(c("placebo", "drug"), each = n / 2),
  sbp_0 = rnorm(n, mean = 150, sd = 10),
  sbp_1 = sbp_0 + ifelse(arm == "drug", -6, 0) + rnorm(n, 0, 8)
)

# --- 3. Visualise ----------------------------------------------
p <- df |>
  mutate(delta = sbp_1 - sbp_0) |>
  ggplot(aes(arm, delta, fill = arm)) +
  geom_boxplot(alpha = 0.6, colour = "grey30") +
  labs(x = NULL, y = "Change in SBP (mmHg)") +
  theme(legend.position = "none")
print(p)

# --- 4. Check --------------------------------------------------
fit <- t.test(sbp_1 - sbp_0 ~ arm, data = df)
print(fit)

# --- 5. Report -------------------------------------------------
cat(sprintf(
  "Mean change difference: %.1f mmHg (95%% CI: %.1f, %.1f), p = %.3f\n",
  diff(tapply(df$sbp_1 - df$sbp_0, df$arm, mean)),
  fit$conf.int[1], fit$conf.int[2], fit$p.value
))

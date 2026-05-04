# ============================================================
# Biostatistics Courses
# Course 3 — Week 3, Session 5: G-methods, IV, DiD, RDD; HTE
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Goal ---------------------------------------------------
# Show that IPTW (a g-method) handles time-varying confounding
# where naive regression fails.

# --- 2. Data ---------------------------------------------------
n <- 2000
df <- tibble(
  l0 = rnorm(n),
  a0 = rbinom(n, 1, plogis(0.2 * l0)),
  l1 = rnorm(n, mean = 0.5 * a0 + 0.3 * l0),
  a1 = rbinom(n, 1, plogis(0.3 * l1 + 0.2 * a0)),
  y  = 1.0 * a0 + 0.8 * a1 + 0.5 * l0 + 0.5 * l1 + rnorm(n)
)

# --- 3. Visualise ----------------------------------------------
print(
  df |>
    pivot_longer(c(a0, a1)) |>
    ggplot(aes(factor(value), y)) +
    geom_boxplot(alpha = 0.6) +
    facet_wrap(~ name) +
    labs(x = "Treated", y = "Outcome y")
)

# --- 4. Assumptions --------------------------------------------
# Positivity (both treatment levels possible at every covariate value)
# and no unmeasured confounding.

# --- 5. Conduct / Fit ------------------------------------------
naive <- lm(y ~ a0 + a1 + l0 + l1, data = df)
print(tidy(naive, conf.int = TRUE) |> filter(term %in% c("a0", "a1")))

num0 <- glm(a0 ~ 1,          data = df, family = binomial)
den0 <- glm(a0 ~ l0,         data = df, family = binomial)
num1 <- glm(a1 ~ a0,         data = df, family = binomial)
den1 <- glm(a1 ~ a0 + l0 + l1, data = df, family = binomial)
w0 <- ifelse(df$a0 == 1, fitted(num0), 1 - fitted(num0)) /
      ifelse(df$a0 == 1, fitted(den0), 1 - fitted(den0))
w1 <- ifelse(df$a1 == 1, fitted(num1), 1 - fitted(num1)) /
      ifelse(df$a1 == 1, fitted(den1), 1 - fitted(den1))
df$sw <- w0 * w1
msm <- lm(y ~ a0 + a1, data = df, weights = sw)
print(tidy(msm, conf.int = TRUE) |> filter(term %in% c("a0", "a1")))

# --- 6. Report -------------------------------------------------
cat("Summary of stabilised weights:\n")
print(summary(df$sw))

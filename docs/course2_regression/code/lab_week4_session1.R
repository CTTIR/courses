# ============================================================
# Biostatistics Courses
# Course 2 — Week 4, Session 1: Dichotomisation and RTM
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Quantify dichotomisation's cost and demonstrate RTM.

# --- 2. Data ---------------------------------------------------
n <- 200
x <- rnorm(n); y <- 0.3 * x + rnorm(n, 0, 1)
dat1 <- tibble(x, y, x_bin = factor(ifelse(x > median(x), "high", "low")))

n2 <- 1000
pre  <- rnorm(n2, 100, 15)
post <- 0.7 * (pre - 100) + 100 + rnorm(n2, 0, 11)
dat2 <- tibble(pre, post) |>
  mutate(high_baseline = pre > quantile(pre, 0.8))

# --- 3. Visualise ----------------------------------------------
p1 <- ggplot(dat1, aes(x, y)) + geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", colour = "steelblue")
print(p1)
p2 <- ggplot(dat2, aes(pre, post)) + geom_point(alpha = 0.3) +
  geom_abline(slope = 1, intercept = 0, linetype = 2, colour = "grey50") +
  geom_smooth(method = "lm", colour = "firebrick")
print(p2)

# --- 4. Assumptions --------------------------------------------
# standard lm assumptions.

# --- 5. Conduct / Fit ------------------------------------------
print(tidy(lm(y ~ x, data = dat1)))
print(tidy(lm(y ~ x_bin, data = dat1)))
print(dat2 |> group_by(high_baseline) |>
        summarise(pre_mean = mean(pre), post_mean = mean(post),
                  change = mean(post - pre)))

# --- 6. Report -------------------------------------------------
cat(sprintf("Continuous p: %.3g; median-split p: %.3g\n",
            tidy(lm(y ~ x, data = dat1))$p.value[2],
            tidy(lm(y ~ x_bin, data = dat1))$p.value[2]))

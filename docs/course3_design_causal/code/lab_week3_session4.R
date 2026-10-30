# ============================================================
# Biostatistics Courses
# Course 3 — Week 3, Session 4: Propensity scores and IPTW
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(MatchIt)
library(cobalt)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Compare covariate-adjusted regression, nearest-neighbour matching, and IPTW
# against a known simulated treatment effect of -1.5.

# --- 2. Data ---------------------------------------------------
n <- 1000
dat <- tibble(
  age  = rnorm(n, 60, 10),
  sev  = rnorm(n, 0,   1),
  sex  = rbinom(n, 1, 0.5)
) |>
  mutate(ps = plogis(-1 + 0.04 * (age - 60) + 0.8 * sev + 0.3 * sex),
         trt = rbinom(n, 1, ps),
         y   = 2 - 1.5 * trt + 0.05 * (age - 60) +
                 0.8 * sev + 0.3 * sex + rnorm(n, 0, 1))

# --- 3. Visualise ----------------------------------------------
p <- ggplot(dat, aes(ps, fill = factor(trt))) +
  geom_density(alpha = 0.5) +
  labs(x = "Propensity score", y = "Density", fill = "Treated?")
print(p)

# --- 4. Assumptions --------------------------------------------
# Conditional exchangeability, positivity, correct propensity model.

# --- 5. Conduct / Fit ------------------------------------------
fit_adjusted <- lm(y ~ trt + age + sev + sex, data = dat)
m         <- matchit(trt ~ age + sev + sex, data = dat,
                     method = "nearest", ratio = 1)
matched   <- match.data(m)
fit_match <- lm(y ~ trt, data = matched, weights = matched$weights)

ps_fit <- glm(trt ~ age + sev + sex, data = dat, family = binomial())
dat$ps_hat <- fitted(ps_fit)
dat <- dat |> mutate(w = if_else(trt == 1, 1 / ps_hat, 1 / (1 - ps_hat)))
fit_iptw  <- lm(y ~ trt, data = dat, weights = w)

print(love.plot(m, thresholds = c(m = 0.1), abs = TRUE))

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "True: -1.50; adjusted: %.2f; match: %.2f; IPTW: %.2f\n",
  coef(fit_adjusted)["trt"], coef(fit_match)["trt"], coef(fit_iptw)["trt"]
))

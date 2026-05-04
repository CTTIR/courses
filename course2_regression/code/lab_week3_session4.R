# ============================================================
# Biostatistics Courses
# Course 2 — Week 3, Session 4: Poisson and negative-binomial
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
library(MASS)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Counts per exposure unit, with overdispersion.

# --- 2. Data ---------------------------------------------------
n <- 300; x <- rnorm(n); exposure <- runif(n, 0.5, 2)
mu <- exposure * exp(0.5 + 0.4 * x)
y <- rnegbin(n, mu = mu, theta = 2)
dat <- tibble(x, exposure, y)

# --- 3. Visualise ----------------------------------------------
p <- ggplot(dat, aes(x, y)) + geom_point(alpha = 0.6) +
  labs(x = "x", y = "Count")
print(p)

# --- 4. Assumptions --------------------------------------------
fit_p <- glm(y ~ x + offset(log(exposure)), data = dat, family = poisson)
cat(sprintf("Dispersion (deviance/df): %.2f\n",
            deviance(fit_p) / df.residual(fit_p)))

# --- 5. Conduct / Fit ------------------------------------------
fit_nb <- glm.nb(y ~ x + offset(log(exposure)), data = dat)
print(tidy(fit_p, conf.int = TRUE, exponentiate = TRUE))
print(tidy(fit_nb, conf.int = TRUE, exponentiate = TRUE))

# --- 6. Report -------------------------------------------------
cat(sprintf("NB IRR per unit x: %.2f\n", exp(coef(fit_nb))["x"]))

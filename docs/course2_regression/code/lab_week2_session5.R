# ============================================================
# Biostatistics Courses
# Course 2 — Week 2, Session 5: Non-linear regression with nls
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Fit a 3-parameter logistic dose-response curve.

# --- 2. Data ---------------------------------------------------
n <- 60
dose <- rep(c(0.1, 0.3, 1, 3, 10, 30), each = 10)
true_resp <- 100 / (1 + exp(-(log(dose) - log(3)) / 0.7))
resp <- true_resp + rnorm(n, 0, 5)
dat <- tibble(dose, resp)

# --- 3. Visualise ----------------------------------------------
p <- ggplot(dat, aes(dose, resp)) +
  geom_point(alpha = 0.7) + scale_x_log10() +
  labs(x = "Dose (log scale)", y = "Response")
print(p)

# --- 4. Assumptions --------------------------------------------
fit <- nls(resp ~ SSlogis(log(dose), Asym, xmid, scal), data = dat)
rplot <- tibble(fitted = fitted(fit), resid = resid(fit))
print(ggplot(rplot, aes(fitted, resid)) + geom_point() +
  geom_hline(yintercept = 0, linetype = 2, colour = "grey50"))

# --- 5. Conduct / Fit ------------------------------------------
print(summary(fit)); print(confint(fit))
pred <- tibble(dose = 10 ^ seq(-1, 1.5, length.out = 100))
pred$resp <- predict(fit, newdata = pred)
print(ggplot(dat, aes(dose, resp)) +
  geom_point(alpha = 0.7) +
  geom_line(data = pred, colour = "steelblue", linewidth = 0.8) +
  scale_x_log10())

# --- 6. Report -------------------------------------------------
cat(sprintf("Asym: %.1f; EC50: %.2f\n",
            coef(fit)["Asym"], exp(coef(fit)["xmid"])))

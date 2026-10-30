# ============================================================
# Biostatistics Courses
# Course 2 — Week 3, Session 1: Logistic regression
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
library(MASS)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Plasma glucose as a predictor of diabetes in Pima.tr.

# --- 2. Data ---------------------------------------------------
pima <- as_tibble(Pima.tr) |>
  mutate(type = factor(type, levels = c("No", "Yes")))

# --- 3. Visualise ----------------------------------------------
p <- ggplot(pima, aes(type, glu, fill = type)) +
  geom_boxplot(alpha = 0.6, colour = "grey30") +
  labs(x = "Diabetes", y = "Plasma glucose") +
  theme(legend.position = "none")
print(p)

# --- 4. Assumptions --------------------------------------------
fit <- glm(type ~ glu, data = pima, family = binomial)
fit_spline <- glm(type ~ splines::ns(glu, df = 3), data = pima, family = binomial)
# Compare a flexible specification; plotting fitted logits from the linear
# model alone cannot check linearity, because they are linear by construction.
print(anova(fit, fit_spline, test = "LRT"))
binned <- pima |>
  mutate(y = as.integer(type == "Yes"), bin = ntile(glu, 8)) |>
  group_by(bin) |>
  summarise(glu = mean(glu), successes = sum(y), n = n(), .groups = "drop") |>
  mutate(empirical_logit = log((successes + .5) / (n - successes + .5)))
p2 <- ggplot(binned, aes(glu, empirical_logit)) +
  geom_point() +
  geom_abline(intercept = coef(fit)[1], slope = coef(fit)[2], colour = "steelblue") +
  labs(x = "Plasma glucose", y = "Binned empirical logit (0.5 correction)")
print(p2)

# --- 5. Conduct / Fit ------------------------------------------
print(tidy(fit, conf.int = TRUE, exponentiate = TRUE))
print(glance(fit))
pred_prob <- predict(fit, type = "response")
pred_class <- ifelse(pred_prob > 0.5, "Yes", "No")
print(table(pred_class, truth = pima$type))

# --- 6. Report -------------------------------------------------
cat(sprintf("OR per 10 mg/dL glucose: %.2f\n",
            exp(10 * coef(fit)["glu"])))

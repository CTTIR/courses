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
p2 <- pima |> mutate(p = fitted(fit), logit = qlogis(p)) |>
  ggplot(aes(glu, logit)) + geom_point(alpha = 0.5) +
  geom_smooth(method = "loess", se = FALSE, colour = "steelblue")
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

# ============================================================
# Biostatistics Courses
# Course 2 — Week 3, Session 3: Ordinal and multinomial regression
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
library(MASS)
library(nnet)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Fit polr and multinom on the same ordered outcome.

# --- 2. Data ---------------------------------------------------
n <- 400; x <- rnorm(n); eta <- 1.2 * x
probs <- cbind(
  plogis(-0.5 - eta),
  plogis(1.0 - eta) - plogis(-0.5 - eta),
  1 - plogis(1.0 - eta))
y <- apply(probs, 1, function(p) sample(1:3, 1, prob = p))
dat <- tibble(x, y = factor(y, levels = 1:3,
                            labels = c("mild", "moderate", "severe"),
                            ordered = TRUE))

# --- 3. Visualise ----------------------------------------------
p <- ggplot(dat, aes(y, x, fill = y)) +
  geom_boxplot(alpha = 0.6, colour = "grey30") +
  labs(x = "Severity", y = "Exposure x") +
  theme(legend.position = "none")
print(p)

# --- 4. Assumptions --------------------------------------------
splits <- tibble(
  cut = c("mild vs rest", "mild+mod vs severe"),
  coef = c(
    coef(glm(I(as.numeric(y) >= 2) ~ x, data = dat, family = binomial))[2],
    coef(glm(I(as.numeric(y) >= 3) ~ x, data = dat, family = binomial))[2]))
print(splits)

# --- 5. Conduct / Fit ------------------------------------------
fit_polr <- polr(y ~ x, data = dat, Hess = TRUE)
print(summary(fit_polr))
print(exp(coef(fit_polr)))
fit_multi <- multinom(y ~ x, data = dat, trace = FALSE)
print(summary(fit_multi))

# --- 6. Report -------------------------------------------------
cat(sprintf("Cumulative OR per unit x (polr): %.2f\n",
            exp(coef(fit_polr))[1]))

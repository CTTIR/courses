# ============================================================
# Biostatistics Courses
# Course 2 — Week 1, Session 3: Multiple regression, confounding,
# interaction, and centring
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Show how adjustment and centring change the reading of a coefficient.

# --- 2. Data ---------------------------------------------------
n <- 300
age <- rnorm(n, 55, 10)
smoker <- rbinom(n, 1, plogis(-3 + 0.05 * age))
y <- 120 + 0.6 * age + 5 * smoker + 0.2 * smoker * (age - mean(age)) +
  rnorm(n, 0, 8)
dat <- tibble(age, smoker = factor(smoker, labels = c("no", "yes")), y)

# --- 3. Visualise ----------------------------------------------
p <- ggplot(dat, aes(age, y, colour = smoker)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Age (years)", y = "Outcome", colour = "Smoker")
print(p)

# --- 4. Assumptions --------------------------------------------
fit_full <- lm(y ~ age * smoker, data = dat)
par(mfrow = c(2, 2)); plot(fit_full); par(mfrow = c(1, 1))

# --- 5. Conduct / Fit ------------------------------------------
crude    <- lm(y ~ smoker, data = dat)
adjusted <- lm(y ~ smoker + age, data = dat)
inter    <- lm(y ~ smoker * age, data = dat)
print(tidy(crude, conf.int = TRUE))
print(tidy(adjusted, conf.int = TRUE))
print(tidy(inter, conf.int = TRUE))

dat_c <- dat |> mutate(age_c = age - mean(age))
inter_c <- lm(y ~ smoker * age_c, data = dat_c)
print(tidy(inter_c, conf.int = TRUE))

# --- 6. Report -------------------------------------------------
cat(sprintf("Centred smoker effect at mean age: %.2f\n",
            coef(inter_c)["smokeryes"]))

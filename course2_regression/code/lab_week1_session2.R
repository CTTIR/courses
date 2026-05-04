# ============================================================
# Biostatistics Courses
# Course 2 — Week 1, Session 2: Simple linear regression
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
library(palmerpenguins)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Does bill length predict body mass in Adelie penguins?

# --- 2. Data ---------------------------------------------------
ad <- penguins |>
  filter(species == "Adelie") |>
  drop_na(bill_length_mm, body_mass_g)

# --- 3. Visualise ----------------------------------------------
p <- ggplot(ad, aes(bill_length_mm, body_mass_g)) +
  geom_point(alpha = 0.6, colour = "grey30") +
  geom_smooth(method = "lm", se = TRUE, colour = "steelblue") +
  labs(x = "Bill length (mm)", y = "Body mass (g)")
print(p)

# --- 4. Assumptions --------------------------------------------
fit <- lm(body_mass_g ~ bill_length_mm, data = ad)
par(mfrow = c(2, 2)); plot(fit); par(mfrow = c(1, 1))

# --- 5. Conduct / Fit ------------------------------------------
print(tidy(fit, conf.int = TRUE))
print(glance(fit))

# --- 6. Report -------------------------------------------------
slope <- coef(fit)[2]; ci <- confint(fit)[2, ]
cat(sprintf("Slope: %.1f g/mm (95%% CI: %.1f, %.1f)\n",
            slope, ci[1], ci[2]))

# ============================================================
# Biostatistics Courses
# Course 2 — Week 2, Session 2: Factorial ANOVA
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
library(car)
library(emmeans)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Does delivery method alter the effect of dose on tooth length?

# --- 2. Data ---------------------------------------------------
tg <- ToothGrowth |> mutate(dose = factor(dose))

# --- 3. Visualise ----------------------------------------------
p <- ggplot(tg, aes(dose, len, colour = supp, group = supp)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun = mean, geom = "line") +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0.1) +
  labs(x = "Dose (mg/day)", y = "Tooth length", colour = "Supp")
print(p)

# --- 4. Assumptions --------------------------------------------
fit <- aov(len ~ supp * dose, data = tg)
par(mfrow = c(2, 2)); plot(fit); par(mfrow = c(1, 1))

# --- 5. Conduct / Fit ------------------------------------------
print(Anova(lm(len ~ supp * dose, data = tg), type = 2))
emm <- emmeans(fit, ~ supp | dose)
print(pairs(emm))
print(emmip(fit, supp ~ dose, CIs = TRUE))

# --- 6. Report -------------------------------------------------
cat("See ANOVA table above for main effects and interaction.\n")

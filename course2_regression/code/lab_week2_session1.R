# ============================================================
# Biostatistics Courses
# Course 2 — Week 2, Session 1: One-way ANOVA with contrasts
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
library(emmeans)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Does dose of vitamin C change tooth length (ToothGrowth)?

# --- 2. Data ---------------------------------------------------
tg <- ToothGrowth |> mutate(dose = factor(dose))

# --- 3. Visualise ----------------------------------------------
p <- ggplot(tg, aes(dose, len, fill = dose)) +
  geom_boxplot(alpha = 0.6, colour = "grey30") +
  labs(x = "Dose (mg/day)", y = "Tooth length") +
  theme(legend.position = "none")
print(p)

# --- 4. Assumptions --------------------------------------------
fit <- aov(len ~ dose, data = tg)
par(mfrow = c(2, 2)); plot(fit); par(mfrow = c(1, 1))
print(bartlett.test(len ~ dose, data = tg))

# --- 5. Conduct / Fit ------------------------------------------
print(summary(fit))
emm <- emmeans(fit, ~ dose)
print(emm)
print(pairs(emm, adjust = "tukey"))

# --- 6. Report -------------------------------------------------
cat(sprintf("Omnibus F: %.2f; p: %.3g\n",
            summary(fit)[[1]]$"F value"[1],
            summary(fit)[[1]]$"Pr(>F)"[1]))

# ============================================================
# Biostatistics Courses
# Course 2 — Week 2, Session 3: RCBD and mixed models
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
library(broom.mixed)
library(lme4)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Drug effect on extra sleep, accounting for within-subject pairing.

# --- 2. Data ---------------------------------------------------
# use base 'sleep' dataset

# --- 3. Visualise ----------------------------------------------
p <- ggplot(sleep, aes(group, extra, group = ID)) +
  geom_line(colour = "grey70") +
  geom_point(aes(colour = group), size = 3) +
  labs(x = "Drug", y = "Extra sleep (hours)", colour = "Drug")
print(p)

# --- 4. Assumptions --------------------------------------------
fit_rcbd <- aov(extra ~ group + Error(ID), data = sleep)
print(summary(fit_rcbd))
fit_lmm <- lmer(extra ~ group + (1 | ID), data = sleep)
qqnorm(resid(fit_lmm)); qqline(resid(fit_lmm))
plot(fitted(fit_lmm), resid(fit_lmm), xlab = "Fitted", ylab = "Resid")
abline(h = 0, lty = 2)

# --- 5. Conduct / Fit ------------------------------------------
print(summary(fit_lmm))
print(tidy(fit_lmm, conf.int = TRUE, effects = "fixed"))

# --- 6. Report -------------------------------------------------
cat(sprintf("Drug 2 vs drug 1 effect: %.2f hours\n", fixef(fit_lmm)[2]))

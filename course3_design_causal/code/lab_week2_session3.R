# ============================================================
# Biostatistics Courses
# Course 3 — Week 2, Session 3: Linear mixed models with lme4
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(lme4)
library(lmerTest)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Model reaction time in sleepstudy with random intercepts and
# slopes for Subject.

# --- 2. Data ---------------------------------------------------
data(sleepstudy, package = "lme4")

# --- 3. Visualise ----------------------------------------------
p <- sleepstudy |>
  ggplot(aes(Days, Reaction, group = Subject)) +
  geom_line(alpha = 0.3) +
  geom_smooth(aes(group = 1), method = "lm", se = FALSE, colour = "firebrick") +
  labs(x = "Days of deprivation", y = "Reaction time (ms)")
print(p)

# --- 4. Assumptions --------------------------------------------
# Linearity, normal random effects, approximately constant residual
# variance.

# --- 5. Conduct / Fit ------------------------------------------
ri <- lmer(Reaction ~ Days + (1 | Subject),    data = sleepstudy, REML = TRUE)
rs <- lmer(Reaction ~ Days + (Days | Subject), data = sleepstudy, REML = TRUE)
print(summary(rs))
print(anova(ri, rs, refit = FALSE))

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "Days fixed effect: %.2f ms/day; random slope SD: %.2f\n",
  fixef(rs)["Days"], sqrt(VarCorr(rs)$Subject[2, 2])
))

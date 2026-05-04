# ============================================================
# Biostatistics Courses
# Course 4 — Week 3, Session 3: Biomarker statistics
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(pROC)
library(MASS)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Assess a logistic biomarker model on Pima.tr using AUC, Youden,
# NRI, and decision curve analysis.

# --- 2. Data ---------------------------------------------------
d <- as_tibble(MASS::Pima.tr)

# --- 3. Visualise ----------------------------------------------
p1 <- ggplot(d, aes(glu, bmi, colour = type)) + geom_point(alpha = 0.7)
print(p1)

# --- 4. Assumptions --------------------------------------------
# Independent observations; glm link appropriate; no missingness.

# --- 5. Conduct / Fit ------------------------------------------
fit <- glm(type ~ glu + bmi + age, data = d, family = binomial())
d$p <- predict(fit, type = "response")
r <- roc(d$type, d$p, direction = "<", quiet = TRUE)

fit0 <- glm(type ~ glu, data = d, family = binomial())
p0 <- predict(fit0, type = "response")
case <- d$type == "Yes"
nri_up <- mean(d$p[case]  > p0[case])  - mean(d$p[case]  < p0[case])
nri_dn <- mean(d$p[!case] < p0[!case]) - mean(d$p[!case] > p0[!case])
nri <- nri_up + nri_dn

thr <- seq(0.05, 0.6, by = 0.02)
dca <- sapply(thr, function(t) {
  treat <- d$p > t
  tp <- sum(treat &  case); fp <- sum(treat & !case); N <- length(case)
  tp / N - (fp / N) * (t / (1 - t))
})

# --- 6. Report -------------------------------------------------
cat(sprintf("AUC: %.3f\n", as.numeric(auc(r))))
cat(sprintf("NRI (total): %.2f\n", nri))

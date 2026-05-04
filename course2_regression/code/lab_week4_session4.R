# ============================================================
# Biostatistics Courses
# Course 2 — Week 4, Session 4: Decision curves, NRI, IDI
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(broom)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Goal ---------------------------------------------------
# Compare a baseline logistic model with one adding a new marker.

# --- 2. Data ---------------------------------------------------
n <- 800
x1 <- rnorm(n)
x2 <- rnorm(n) + 0.3 * x1
y  <- rbinom(n, 1, plogis(-1 + 0.9 * x1 + 0.6 * x2))
df <- tibble(y = y, x1 = x1, x2 = x2)

base_fit <- glm(y ~ x1,      data = df, family = binomial)
new_fit  <- glm(y ~ x1 + x2, data = df, family = binomial)
df <- df |>
  mutate(p_base = predict(base_fit, type = "response"),
         p_new  = predict(new_fit,  type = "response"))

# --- 3. Visualise ----------------------------------------------
net_benefit <- function(y, p, thr) {
  pred_pos <- p >= thr
  sum(pred_pos &  y == 1) / length(y) -
    sum(pred_pos &  y == 0) / length(y) * (thr / (1 - thr))
}
thresholds <- seq(0.05, 0.6, by = 0.01)
dc <- tibble(
  threshold  = thresholds,
  base_model = sapply(thresholds, \(t) net_benefit(df$y, df$p_base, t)),
  new_model  = sapply(thresholds, \(t) net_benefit(df$y, df$p_new,  t)),
  treat_all  = sapply(thresholds, \(t)
                       mean(df$y) - (1 - mean(df$y)) * t / (1 - t)),
  treat_none = 0
) |>
  pivot_longer(-threshold, names_to = "strategy", values_to = "nb")

print(
  ggplot(dc, aes(threshold, nb, colour = strategy)) +
    geom_line(linewidth = 0.8) +
    labs(x = "Threshold probability", y = "Net benefit")
)

# --- 4. Assumptions --------------------------------------------
# None beyond the models themselves; decision curves are descriptive.

# --- 5. Conduct / Fit ------------------------------------------
nri <- function(y, p_old, p_new) {
  up   <- mean((p_new > p_old)[y == 1]) - mean((p_new < p_old)[y == 1])
  down <- mean((p_new < p_old)[y == 0]) - mean((p_new > p_old)[y == 0])
  c(events = up, non_events = down, overall = up + down)
}
idi <- function(y, p_old, p_new) {
  ev <- mean((p_new - p_old)[y == 1])
  ne <- mean((p_old - p_new)[y == 0])
  c(events = ev, non_events = ne, overall = ev + ne)
}
print(nri(df$y, df$p_base, df$p_new))
print(idi(df$y, df$p_base, df$p_new))

# --- 6. Report -------------------------------------------------
cat("Decision curves and category-free NRI/IDI computed above.\n")

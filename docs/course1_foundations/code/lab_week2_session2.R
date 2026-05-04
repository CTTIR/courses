# ============================================================
# Biostatistics Courses
# Course 1 — Week 2, Session 2: Probability and Bayes' theorem
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Compute and simulate the PPV of a diagnostic test using Bayes.

# --- 2. Data ---------------------------------------------------
N <- 100000
prev <- 0.01
sens <- 0.95
spec <- 0.95

pop <- tibble(
  id = seq_len(N),
  disease = rbinom(N, 1, prev)
) |>
  mutate(
    test = if_else(disease == 1,
                   rbinom(N, 1, sens),
                   rbinom(N, 1, 1 - spec))
  )

# --- 3. Visualise ----------------------------------------------
sweep <- tibble(
  prev_x = seq(0.001, 0.5, length.out = 200),
  ppv = (sens * prev_x) / (sens * prev_x + (1 - spec) * (1 - prev_x))
)
p <- ggplot(sweep, aes(prev_x, ppv)) +
  geom_line(linewidth = 1) +
  geom_hline(yintercept = 0.5, linetype = 2, colour = "grey50") +
  labs(x = "Prevalence", y = "Positive predictive value")
print(p)

# --- 4. Assumptions --------------------------------------------
# Fixed operating characteristics; independent individuals; no bias.

# --- 5. Conduct / Fit ------------------------------------------
ppv_bayes <- (sens * prev) / (sens * prev + (1 - spec) * (1 - prev))
ppv_count <- mean(pop$disease[pop$test == 1])

# --- 6. Report -------------------------------------------------
cat(sprintf("PPV (Bayes):   %.4f\n", ppv_bayes))
cat(sprintf("PPV (count):   %.4f\n", ppv_count))

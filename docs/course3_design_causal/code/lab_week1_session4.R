# ============================================================
# Biostatistics Courses
# Course 3 — Week 1, Session 4: Bench and translational design
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Detect the interaction in a 2 x 2 factorial design and show what
# pseudoreplication does to the standard error.

# --- 2. Data ---------------------------------------------------
n_per_cell <- 10
fact <- expand_grid(
  drug = c("no", "yes"),
  diet = c("standard", "modified"),
  rep  = seq_len(n_per_cell)
) |>
  mutate(
    y = 10 +
      (drug == "yes")  * 1.5 +
      (diet == "modified") * 1.0 +
      (drug == "yes" & diet == "modified") * 2.0 +
      rnorm(n(), 0, 1.5)
  )

pseudo <- fact |>
  slice(rep(seq_len(n()), each = 3)) |>
  mutate(y = y + rnorm(n(), 0, 0.3))

# --- 3. Visualise ----------------------------------------------
p <- fact |>
  ggplot(aes(diet, y, fill = drug)) +
  geom_boxplot(alpha = 0.6, colour = "grey30") +
  labs(x = NULL, y = "Biomarker", fill = "Drug")
print(p)

# --- 4. Assumptions --------------------------------------------
print(fact |>
  group_by(drug, diet) |>
  summarise(mean = mean(y), sd = sd(y), n = n(), .groups = "drop"))

# --- 5. Conduct / Fit ------------------------------------------
fit      <- lm(y ~ drug * diet, data = fact)
fit_bad  <- lm(y ~ drug * diet, data = pseudo)
print(anova(fit))
print(broom::tidy(fit_bad)  |> filter(term == "drugyes:dietmodified"))
print(broom::tidy(fit)      |> filter(term == "drugyes:dietmodified"))

# --- 6. Report -------------------------------------------------
cat("Aggregated (correct) and pseudoreplicated analyses above.\n")

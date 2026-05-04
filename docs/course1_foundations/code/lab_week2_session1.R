# ============================================================
# Biostatistics Courses
# Course 1 — Week 2, Session 1: Descriptives and Table 1
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(palmerpenguins)
library(gtsummary)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Produce a Table 1 for penguins, stratified by species.

# --- 2. Data ---------------------------------------------------
dat <- penguins |>
  drop_na(species, sex, bill_length_mm, bill_depth_mm,
          flipper_length_mm, body_mass_g)

# --- 3. Visualise ----------------------------------------------
p <- dat |>
  pivot_longer(c(bill_length_mm, bill_depth_mm,
                 flipper_length_mm, body_mass_g),
               names_to = "variable", values_to = "value") |>
  ggplot(aes(value, fill = species)) +
  geom_histogram(bins = 20, alpha = 0.6, colour = "grey30",
                 position = "identity") +
  facet_wrap(~ variable, scales = "free") +
  labs(x = NULL, y = "Count")
print(p)

# --- 4. Assumptions --------------------------------------------
# Symmetric continuous -> mean (SD); skewed -> median (IQR).

# --- 5. Conduct / Fit ------------------------------------------
t1 <- dat |>
  select(species, sex, bill_length_mm, bill_depth_mm,
         flipper_length_mm, body_mass_g) |>
  tbl_summary(
    by = species,
    statistic = list(
      all_continuous() ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits = all_continuous() ~ 1
  ) |>
  add_overall() |>
  add_p()
print(t1)

# --- 6. Report -------------------------------------------------
hand <- dat |>
  group_by(species) |>
  summarise(n = n(),
            mean_mass = mean(body_mass_g),
            sd_mass = sd(body_mass_g),
            .groups = "drop")
print(hand)

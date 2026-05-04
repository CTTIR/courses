# ============================================================
# Biostatistics Courses
# Course 1 — Week 1, Session 4: Import, joins, missingness with dplyr
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(palmerpenguins)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Practise dplyr verbs, joins, and missingness handling on penguins.

# --- 2. Data ---------------------------------------------------
islands <- tibble(
  island = c("Biscoe", "Dream", "Torgersen"),
  lat    = c(-65.43, -64.73, -64.77),
  researcher = c("Anna", "Ben", "Carla")
)

penguins_aug <- penguins |>
  left_join(islands, by = "island")

# --- 3. Visualise ----------------------------------------------
missingness <- penguins |>
  summarise(across(everything(), ~ mean(is.na(.)))) |>
  pivot_longer(everything(),
               names_to = "variable",
               values_to = "frac_missing") |>
  arrange(desc(frac_missing))

p <- missingness |>
  ggplot(aes(frac_missing, reorder(variable, frac_missing))) +
  geom_col(fill = "grey60") +
  labs(x = "Fraction missing", y = NULL)
print(p)

# --- 4. Assumptions --------------------------------------------
# Joins need a shared key; missingness needs explicit handling.
n <- nrow(penguins)
inj <- penguins |>
  mutate(body_mass_g = if_else(runif(n) < 0.1, NA_real_, body_mass_g))

cat("Mean without na.rm: ", mean(inj$body_mass_g), "\n")
cat("Mean with na.rm:    ", mean(inj$body_mass_g, na.rm = TRUE), "\n")

# --- 5. Conduct / Fit ------------------------------------------
species_summary <- penguins |>
  group_by(species, sex) |>
  summarise(
    n    = n(),
    mean_mass = mean(body_mass_g, na.rm = TRUE),
    sd_mass   = sd(body_mass_g,   na.rm = TRUE),
    .groups = "drop"
  )
print(species_summary)

# --- 6. Report -------------------------------------------------
cat(sprintf("%d rows, %d missing sex, %d missing mass\n",
            nrow(penguins),
            sum(is.na(penguins$sex)),
            sum(is.na(penguins$body_mass_g))))

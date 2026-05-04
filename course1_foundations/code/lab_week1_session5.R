# ============================================================
# Biostatistics Courses
# Course 1 — Week 1, Session 5: ggplot2 grammar and patchwork
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(palmerpenguins)
library(patchwork)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Build a three-panel publication-style figure on penguins.

# --- 2. Data ---------------------------------------------------
p <- penguins |>
  drop_na(bill_length_mm, bill_depth_mm, body_mass_g, species, sex)

# --- 3. Visualise ----------------------------------------------
p1 <- p |>
  ggplot(aes(bill_length_mm, bill_depth_mm, colour = species)) +
  geom_point(alpha = 0.7) +
  labs(x = "Bill length (mm)",
       y = "Bill depth (mm)",
       colour = NULL)

p2 <- p |>
  ggplot(aes(species, body_mass_g, fill = species)) +
  geom_boxplot(alpha = 0.6, colour = "grey30") +
  labs(x = NULL, y = "Body mass (g)") +
  theme(legend.position = "none")

p3 <- p |>
  ggplot(aes(bill_length_mm, body_mass_g, colour = sex)) +
  geom_point(alpha = 0.6) +
  facet_wrap(~ species) +
  labs(x = "Bill length (mm)",
       y = "Body mass (g)",
       colour = NULL)

# --- 4. Assumptions --------------------------------------------
# Grammar: data + aesthetics + geom; faceting for within-group variation.

# --- 5. Conduct / Fit ------------------------------------------
combined <- (p1 | p2) / p3 +
  plot_annotation(
    title = "Palmer penguins: bill morphology and body mass",
    tag_levels = "A"
  )
print(combined)

# --- 6. Report -------------------------------------------------
cat("Figure built from", nrow(p), "complete-case penguins.\n")

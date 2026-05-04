# ============================================================
# Biostatistics Courses
# Course 1 — Week 3, Session 2: Bootstrap and permutation tests
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(palmerpenguins)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Bootstrap CI for Gentoo median body mass; permutation test for
# flipper length, Gentoo vs Adelie.

# --- 2. Data ---------------------------------------------------
dat <- penguins |>
  filter(species %in% c("Gentoo", "Adelie")) |>
  drop_na(body_mass_g, flipper_length_mm)
gen <- dat |> filter(species == "Gentoo") |> pull(body_mass_g)

# --- 3. Visualise ----------------------------------------------
p <- dat |>
  ggplot(aes(species, flipper_length_mm, fill = species)) +
  geom_boxplot(alpha = 0.6, colour = "grey30") +
  labs(x = NULL, y = "Flipper length (mm)") +
  theme(legend.position = "none")
print(p)

# --- 4. Assumptions --------------------------------------------
# Bootstrap: exchangeable observations. Permutation: exchangeable
# labels under H0.

# --- 5. Conduct / Fit ------------------------------------------
B <- 2000
boot_meds <- replicate(B, median(sample(gen, replace = TRUE)))
ci_med <- quantile(boot_meds, c(0.025, 0.975))
obs_med <- median(gen)

g <- dat$species
x <- dat$flipper_length_mm
observed_diff <- mean(x[g == "Gentoo"]) - mean(x[g == "Adelie"])
perm_diff <- replicate(5000, {
  gp <- sample(g)
  mean(x[gp == "Gentoo"]) - mean(x[gp == "Adelie"])
})
p_perm <- mean(abs(perm_diff) >= abs(observed_diff))

# --- 6. Report -------------------------------------------------
cat(sprintf("Median Gentoo body mass: %g (95%% CI %g, %g)\n",
            obs_med, ci_med[1], ci_med[2]))
cat(sprintf("Flipper Gentoo-Adelie diff = %.1f mm, perm p = %g\n",
            observed_diff, p_perm))

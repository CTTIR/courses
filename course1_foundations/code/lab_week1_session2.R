# ============================================================
# Biostatistics Courses
# Course 1 — Week 1, Session 2: R, RStudio, Quarto, renv toolchain
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Demonstrate the minimum toolchain: reproducible project layout,
# renv lockfile, Quarto render, sessionInfo reporting.

# --- 2. Data ---------------------------------------------------
lab <- tibble(
  subject = seq_len(30),
  group   = rep(c("A", "B"), each = 15),
  value   = c(rnorm(15, mean = 10, sd = 2),
              rnorm(15, mean = 12, sd = 2))
)

# --- 3. Visualise ----------------------------------------------
p <- lab |>
  ggplot(aes(group, value, fill = group)) +
  geom_boxplot(alpha = 0.6, colour = "grey30") +
  labs(x = "Group", y = "Measured value") +
  theme(legend.position = "none")
print(p)

# --- 4. Assumptions --------------------------------------------
# Reproducibility assumptions: locked package versions, explicit seed,
# no external file dependencies.
cat("R version:", R.version.string, "\n")

installed_versions <- tibble(
  package = c("tidyverse", "ggplot2", "dplyr"),
  version = sapply(c("tidyverse", "ggplot2", "dplyr"),
                   function(p) as.character(packageVersion(p)))
)
print(installed_versions)

# --- 5. Conduct / Fit ------------------------------------------
# renv in three commands — do not run inside a course chunk; here for
# reference only.
# renv::init()       # create lockfile
# renv::snapshot()   # refresh after installing a package
# renv::restore()    # restore on another machine

# --- 6. Report -------------------------------------------------
cat(sprintf(
  "Toolchain rendered OK. n = %d, groups = %s\n",
  nrow(lab), paste(unique(lab$group), collapse = ", ")
))
sessionInfo()

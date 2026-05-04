# ============================================================
# Biostatistics Courses
# Course 3 — Week 4, Session 5: Pre-registration and SAPs
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Goal ---------------------------------------------------
# Walk through the minimal sections of a pre-registration and SAP.

# --- 2. Data ---------------------------------------------------
# None; this lab is a template exercise.

# --- 3. Visualise ----------------------------------------------
sections <- tibble(
  doc    = c(rep("Pre-registration", 4), rep("SAP", 4)),
  item   = c("Question & H0/H1", "Design", "Primary analysis",
             "Sample size",
             "Secondary analyses", "Missing data",
             "Subgroups", "Sensitivity analyses")
)
print(sections)

# --- 4. Assumptions --------------------------------------------
# Pre-registration assumes you can specify the primary analysis before
# looking at the outcome data.

# --- 5. Conduct / Fit ------------------------------------------
# Example sample-size check for a confirmatory analysis:
pwr::pwr.t.test(n = 200, d = 0.3, sig.level = 0.05, type = "two.sample")

# --- 6. Report -------------------------------------------------
cat("Deposit on OSF (https://osf.io) and cite the DOI in the manuscript.\n")

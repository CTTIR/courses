# ============================================================
# Biostatistics Courses
# Course 3 — Week 4, Session 1: Systematic reviews and PRISMA
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Goal ---------------------------------------------------
# Frame a PICO question and render a PRISMA flow diagram from
# simulated screening counts.

# --- 2. Data ---------------------------------------------------
prisma <- tibble(
  stage = c("Identified (PubMed)", "Identified (Embase)",
            "After deduplication",
            "Title/abstract screened", "Full-text assessed",
            "Included in qualitative synthesis",
            "Included in meta-analysis"),
  n = c(812, 640, 1098, 1098, 84, 22, 18)
)

# --- 3. Visualise ----------------------------------------------
print(
  prisma |>
    mutate(stage = factor(stage, levels = rev(stage))) |>
    ggplot(aes(n, stage)) +
    geom_col(fill = "#1a73e8", alpha = 0.8) +
    geom_text(aes(label = n), hjust = -0.1, size = 3.5) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.15))) +
    labs(x = "n", y = NULL)
)

# --- 4. Assumptions --------------------------------------------
# A reproducible search strategy requires an explicit date of last
# search and an unambiguous syntax for each database.

# --- 5. Conduct / Fit ------------------------------------------
print(prisma)

# --- 6. Report -------------------------------------------------
cat("Flow: ",
    paste(prisma$n, prisma$stage, sep = " = ", collapse = "; "),
    "\n")

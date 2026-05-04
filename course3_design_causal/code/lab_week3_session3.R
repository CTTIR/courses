# ============================================================
# Biostatistics Courses
# Course 3 — Week 3, Session 3: DAGs with dagitty and ggdag
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(dagitty)
library(ggdag)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Distinguish confounders, mediators, and colliders and identify
# adjustment sets using dagitty.

# --- 2. Data ---------------------------------------------------
n  <- 2000
c_ <- rnorm(n)
x  <- 0.6 * c_ + rnorm(n)
y  <- 0.4 * x + 0.7 * c_ + rnorm(n)
df <- tibble(c_, x, y)

dag1 <- dagitty('dag { X -> Y; C -> X; C -> Y;
                     X [exposure]; Y [outcome] }')
dag2 <- dagitty('dag { X -> M -> Y; X -> Y;
                     X [exposure]; Y [outcome] }')
dag3 <- dagitty('dag { X -> Z; Y -> Z; X -> Y;
                     X [exposure]; Y [outcome] }')

# --- 3. Visualise ----------------------------------------------
print(ggdag(dag1) + theme_dag())
print(ggdag(dag2) + theme_dag())
print(ggdag(dag3) + theme_dag())

# --- 4. Assumptions --------------------------------------------
# The DAGs faithfully represent all direct causal relations.

# --- 5. Conduct / Fit ------------------------------------------
print(adjustmentSets(dag1, effect = "total"))
print(adjustmentSets(dag2, effect = "total"))
print(adjustmentSets(dag2, effect = "direct"))
print(adjustmentSets(dag3))

cat(sprintf("Unadjusted b_x: %.2f; adjusted for C: %.2f\n",
            coef(lm(y ~ x,      data = df))["x"],
            coef(lm(y ~ x + c_, data = df))["x"]))

# --- 6. Report -------------------------------------------------
cat("Adjustment sets and simulation printed above.\n")

# ============================================================
# Biostatistics Courses
# Course 3 — Week 4, Session 3: Network meta-analysis
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(netmeta)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis ---------------------------------------------
# H0: all treatments have equal efficacy.

# --- 2. Data ---------------------------------------------------
data(Senn2013)

# --- 3. Visualise ----------------------------------------------
net <- netmeta(TE, seTE, treat1, treat2, studlab,
               data = Senn2013, sm = "MD",
               common = FALSE, random = TRUE,
               reference.group = "plac")
netgraph(net, plastic = FALSE, thickness = "number.of.studies",
         points = TRUE, cex.points = 2, cex = 0.8)

# --- 4. Assumptions --------------------------------------------
print(decomp.design(net))

# --- 5. Conduct / Fit ------------------------------------------
print(summary(net))
rank_df <- netrank(net, small.values = "good")
print(rank_df)

# --- 6. Report -------------------------------------------------
cat("Top ranked treatment by SUCRA:\n")
print(sort(rank_df$ranking.random, decreasing = TRUE)[1])

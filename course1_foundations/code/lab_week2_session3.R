# ============================================================
# Biostatistics Courses
# Course 1 — Week 2, Session 3: Diagnostic testing
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Characterise a continuous biomarker as a diagnostic test.

# --- 2. Data ---------------------------------------------------
N <- 500
prev <- 0.2
pop <- tibble(
  id = seq_len(N),
  disease = rbinom(N, 1, prev),
  biomarker = rnorm(N, mean = if_else(disease == 1, 7, 5), sd = 1)
)
cutoff <- 6
pop <- pop |> mutate(test = as.integer(biomarker > cutoff))

# --- 3. Visualise ----------------------------------------------
p_hist <- pop |>
  mutate(status = if_else(disease == 1, "disease", "no disease")) |>
  ggplot(aes(biomarker, fill = status)) +
  geom_density(alpha = 0.5, colour = NA) +
  geom_vline(xintercept = cutoff, linetype = 2) +
  labs(x = "Biomarker level", y = "Density", fill = NULL)
print(p_hist)

# --- 4. Assumptions --------------------------------------------
tab <- table(disease = pop$disease, test = pop$test)

# --- 5. Conduct / Fit ------------------------------------------
TP <- tab["1", "1"]; FN <- tab["1", "0"]
FP <- tab["0", "1"]; TN <- tab["0", "0"]
sens <- TP / (TP + FN)
spec <- TN / (TN + FP)
ppv  <- TP / (TP + FP)
npv  <- TN / (TN + FN)
lrp  <- sens / (1 - spec)
lrn  <- (1 - sens) / spec

roc <- tibble(
  cut = seq(min(pop$biomarker), max(pop$biomarker), length.out = 200)
) |>
  rowwise() |>
  mutate(
    tp = sum(pop$biomarker > cut & pop$disease == 1),
    fn = sum(pop$biomarker <= cut & pop$disease == 1),
    fp = sum(pop$biomarker > cut & pop$disease == 0),
    tn = sum(pop$biomarker <= cut & pop$disease == 0),
    sens = tp / (tp + fn),
    fpr  = fp / (fp + tn)
  ) |>
  ungroup()

p_roc <- ggplot(roc, aes(fpr, sens)) +
  geom_path(linewidth = 1) +
  geom_abline(linetype = 2, colour = "grey50") +
  coord_equal() +
  labs(x = "FPR", y = "Sensitivity")
print(p_roc)

# --- 6. Report -------------------------------------------------
cat(sprintf("Se=%.2f Sp=%.2f PPV=%.2f NPV=%.2f LR+=%.2f LR-=%.2f\n",
            sens, spec, ppv, npv, lrp, lrn))

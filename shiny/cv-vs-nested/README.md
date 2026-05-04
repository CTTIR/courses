# cv-vs-nested

Companion to **Course 4, Week 1, Session 1 — Cross-validation, nested
CV, bootstrap.** All p predictors are pure noise. Naive CV picks the
"best" predictor on the full data and re-uses the same folds —
producing optimistic CV error far below the true MSE of 1. Nested CV
selects within an inner loop and evaluates on the outer loop, recovering
the honest MSE.

Packages: `shiny`, `ggplot2`.

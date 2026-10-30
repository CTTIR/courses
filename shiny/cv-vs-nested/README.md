# cv-vs-nested

Companion to **Course 4, Week 1, Session 1 — Cross-validation, nested
CV, bootstrap.** Each replicate uses the same independent normal predictors
and response for both estimates. The naive estimate selects the univariate
model with the lowest CV error and reports that same minimum. Nested CV
selects by inner CV and evaluates on untouched outer folds, weighting each
held-out observation equally. The third box shows the exact future MSE of
the fitted outer models under this simulation: `1 + intercept^2 + slope^2`.
The dashed line at 1 is the irreducible noise variance. Finite replicates
need not put either estimate above or below another on every run.

Packages: `shiny`, `ggplot2`.

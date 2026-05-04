# regularization-path

Companion to **Course 4, Week 1, Session 2 — Regularisation: ridge,
lasso, elastic net.** Pick n, p, the number of truly non-zero
coefficients, the signal-to-noise ratio, and the elastic-net alpha
(0 = ridge, 1 = lasso). The app plots the full coefficient path with
the "truly non-zero" predictors highlighted, and the CV-MSE curve
with `lambda.min` and `lambda.1se` marked.

Packages: `shiny`, `ggplot2`, `glmnet`, `tidyr`.

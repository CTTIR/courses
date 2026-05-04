# ============================================================
# Biostatistics Courses — setup_check.R
# Run once after cloning to verify your R environment.
# Usage:
#   Rscript setup_check.R
# ============================================================

cat("\n-- R environment check -----------------------------------\n")
cat("R version: ", R.version.string, "\n", sep = "")
cat("Platform : ", R.version$platform, "\n", sep = "")
cat("Locale   : ", Sys.getlocale("LC_CTYPE"), "\n\n", sep = "")

required <- c(
  "tidyverse", "gtsummary", "patchwork", "broom", "broom.mixed",
  "knitr", "rmarkdown", "quarto", "here", "MASS", "survival",
  "survminer", "palmerpenguins", "datasauRus", "lme4", "glmmTMB",
  "geepack", "mgcv", "gratia", "emmeans", "car", "nlme", "VGAM",
  "nnet", "pROC", "rms", "performance", "effectsize", "DHARMa",
  "mice", "MatchIt", "cobalt", "survey", "dagitty", "ggdag", "pwr",
  "WebPower", "simr", "metafor", "netmeta", "tidycmprsk",
  "ggsurvfit", "cmprsk", "mstate", "forecast", "changepoint",
  "glmnet", "tidymodels", "ranger", "xgboost", "lightgbm",
  "FactoMineR", "factoextra", "mclust", "uwot", "DALEX", "iml",
  "brms", "deSolve", "targets", "tarchetypes"
)

installed_now <- rownames(installed.packages())
already  <- intersect(required, installed_now)
missing  <- setdiff(required, installed_now)

cat("Already installed: ", length(already), " / ", length(required), "\n", sep = "")
if (length(missing) > 0) {
  cat("Missing packages : ", length(missing), "\n", sep = "")
  cat("Attempting install from CRAN...\n\n")
  installed_ok <- character(0)
  failed       <- character(0)
  for (pkg in missing) {
    ok <- tryCatch(
      {
        install.packages(pkg, repos = "https://cloud.r-project.org",
                         quiet = TRUE, dependencies = TRUE)
        requireNamespace(pkg, quietly = TRUE)
      },
      error   = function(e) FALSE,
      warning = function(w) requireNamespace(pkg, quietly = TRUE)
    )
    if (isTRUE(ok)) {
      installed_ok <- c(installed_ok, pkg)
      cat("  ok      ", pkg, "\n", sep = "")
    } else {
      failed <- c(failed, pkg)
      cat("  FAILED  ", pkg, "\n", sep = "")
    }
  }
  cat("\n--- Summary ------------------------------------------------\n")
  cat("Already       : ", length(already), "\n", sep = "")
  cat("Newly installed: ", length(installed_ok), "\n", sep = "")
  cat("Failed        : ", length(failed), "\n", sep = "")
  if (length(failed) > 0) {
    cat("\nPackages that failed to install:\n")
    cat(paste("  -", failed, collapse = "\n"), "\n")
    cat("\nTry installing them manually or check system dependencies",
        "(e.g. libcurl, libssl, libxml2).\n")
  }
} else {
  cat("All required packages are already installed.\n")
}

cat("\nQuarto check:\n")
qv <- tryCatch(system("quarto --version", intern = TRUE),
               error = function(e) NA_character_)
if (is.na(qv[1])) {
  cat("  Quarto not on PATH. Install from https://quarto.org\n")
} else {
  cat("  Quarto version: ", qv[1], "\n", sep = "")
}

cat("\nSetup check complete.\n")

# ============================================================
# Biostatistics Courses
# Course 3 — Week 2, Session 5: Time series basics
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(forecast)
library(changepoint)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Hypothesis / Goal --------------------------------------
# Decompose a simulated monthly series, fit ARIMA, and detect a
# mean shift.

# --- 2. Data ---------------------------------------------------
months <- 144
t  <- seq_len(months)
trend <- 0.08 * t
season <- 4 * sin(2 * pi * t / 12)
shift  <- if_else(t >= 80, 5, 0)
y      <- 20 + trend + season + shift + rnorm(months, 0, 1.5)
ts_y   <- ts(y, frequency = 12, start = c(2014, 1))

# --- 3. Visualise ----------------------------------------------
print(autoplot(ts_y) + labs(x = "Year", y = "Simulated rate"))

# --- 4. Assumptions --------------------------------------------
# Fixed-period seasonality; approximately constant variance; time-
# invariant AR/MA structure.

# --- 5. Conduct / Fit ------------------------------------------
decomp    <- stl(ts_y, s.window = "periodic")
fit_arima <- auto.arima(ts_y)
cpt       <- cpt.mean(as.numeric(ts_y), method = "PELT")
print(fit_arima)
print(cpts(cpt))

# --- 6. Report -------------------------------------------------
cat(sprintf("ARIMA order summary printed above; change-points at: %s\n",
            paste(cpts(cpt), collapse = ", ")))

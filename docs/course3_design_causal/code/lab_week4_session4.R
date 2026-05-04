# ============================================================
# Biostatistics Courses
# Course 3 — Week 4, Session 4: SIR / SEIR with deSolve
# ============================================================

# --- 0. Setup --------------------------------------------------
library(tidyverse)
library(deSolve)
set.seed(42)
theme_set(theme_minimal(base_size = 12))

# --- 1. Goal ---------------------------------------------------
# Simulate SIR outbreaks in a population of 1M for three R0 values.

# --- 2. Data ---------------------------------------------------
sir <- function(time, state, params) {
  with(as.list(c(state, params)), {
    N  <- S + I + R
    dS <- -beta * S * I / N
    dI <-  beta * S * I / N - gamma * I
    dR <-  gamma * I
    list(c(dS, dI, dR))
  })
}

run_sir <- function(R0, gamma = 1/7, days = 180, N = 1e6, I0 = 10) {
  params <- c(beta = R0 * gamma, gamma = gamma)
  state  <- c(S = N - I0, I = I0, R = 0)
  times  <- seq(0, days, by = 1)
  out <- as.data.frame(ode(state, times, sir, params))
  out$R0 <- R0
  out
}

trajectories <- bind_rows(
  run_sir(1.5), run_sir(2.5), run_sir(4.0)
) |>
  pivot_longer(c(S, I, R), names_to = "compartment", values_to = "n")

# --- 3. Visualise ----------------------------------------------
print(
  ggplot(trajectories, aes(time, n, colour = compartment)) +
    geom_line(linewidth = 0.8) +
    facet_wrap(~ R0, labeller = labeller(R0 = \(x) paste0("R0 = ", x))) +
    labs(x = "Day", y = "People")
)

# --- 4. Assumptions --------------------------------------------
# Closed, homogeneously mixing population; constant beta and gamma.

# --- 5. Conduct / Fit ------------------------------------------
peak <- trajectories |>
  filter(compartment == "I") |>
  group_by(R0) |>
  summarise(peak_I = max(n), peak_day = time[which.max(n)])
print(peak)

# --- 6. Report -------------------------------------------------
cat("Peak prevalence scales strongly with R0.\n")

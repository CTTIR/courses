# sir-simulator

Companion to **Course 3, Week 4, Session 4 — SIR / SEIR with deSolve.**
Pick model (SIR or SEIR), R0, mean infectious period (and latent
period for SEIR), population size N, and initial infected count I0.
The app integrates the ODEs with `deSolve` and plots the trajectories,
plus peak prevalence and final attack rate.

Packages: `shiny`, `ggplot2`, `deSolve`, `tidyr`.

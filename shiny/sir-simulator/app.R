# =============================================================
# SIR / SEIR compartmental-model simulator
# Pairs with: Course 3, Week 4, Session 4.
# =============================================================
library(shiny)
library(ggplot2)
library(deSolve)
library(tidyr)

ACCENT <- "#1a73e8"

ui <- fluidPage(
  titlePanel("SIR / SEIR compartmental model"),
  sidebarLayout(
    sidebarPanel(
      selectInput("model", "Model",
                  c("SIR" = "sir", "SEIR" = "seir")),
      sliderInput("R0", "Basic reproduction number R0",
                  0.5, 6, 2.5, step = 0.1),
      sliderInput("inf_period", "Mean infectious period (days)",
                  1, 21, 7, step = 1),
      conditionalPanel(
        "input.model == 'seir'",
        sliderInput("lat_period", "Mean latent period (days)",
                    1, 14, 4, step = 1)),
      sliderInput("N",  "Population size N",
                  1e3, 1e7, 1e6, step = 1e3),
      sliderInput("I0", "Initial infectious I0",
                  1, 1000, 10, step = 1),
      sliderInput("days", "Simulation length (days)",
                  30, 360, 180, step = 10)
    ),
    mainPanel(
      plotOutput("traj_plot", height = "380px"),
      verbatimTextOutput("summary_text")
    )
  )
)

sir_eq <- function(t, y, p) {
  with(as.list(c(y, p)), {
    N  <- S + I + R
    dS <- -beta * S * I / N
    dI <-  beta * S * I / N - gamma * I
    dR <-  gamma * I
    list(c(dS, dI, dR))
  })
}

seir_eq <- function(t, y, p) {
  with(as.list(c(y, p)), {
    N  <- S + E + I + R
    dS <- -beta * S * I / N
    dE <-  beta * S * I / N - sigma * E
    dI <-  sigma * E - gamma * I
    dR <-  gamma * I
    list(c(dS, dE, dI, dR))
  })
}

server <- function(input, output, session) {
  out_df <- reactive({
    gamma <- 1 / input$inf_period
    beta  <- input$R0 * gamma
    times <- seq(0, input$days, by = 1)

    if (input$model == "sir") {
      state  <- c(S = input$N - input$I0, I = input$I0, R = 0)
      params <- c(beta = beta, gamma = gamma)
      out <- as.data.frame(ode(state, times, sir_eq, params))
    } else {
      sigma  <- 1 / input$lat_period
      state  <- c(S = input$N - input$I0, E = 0,
                  I = input$I0, R = 0)
      params <- c(beta = beta, gamma = gamma, sigma = sigma)
      out <- as.data.frame(ode(state, times, seir_eq, params))
    }
    out
  })

  output$traj_plot <- renderPlot({
    df <- out_df()
    long <- pivot_longer(df, -time, names_to = "compartment",
                         values_to = "n")
    ggplot(long, aes(time, n, colour = compartment)) +
      geom_line(linewidth = 0.9) +
      labs(x = "Day", y = "People", colour = NULL,
           title = sprintf("%s, R0 = %.1f, infectious period = %d days",
                           toupper(input$model), input$R0,
                           input$inf_period)) +
      theme_minimal(base_size = 12)
  })

  output$summary_text <- renderPrint({
    df <- out_df()
    if ("I" %in% names(df)) {
      i_peak <- which.max(df$I)
      cat(sprintf("Peak infectious : %.0f on day %d\n",
                  df$I[i_peak], df$time[i_peak]))
    }
    cat(sprintf("Final attack rate (R/N) at end: %.1f%%\n",
                100 * df$R[nrow(df)] / input$N))
  })
}

shinyApp(ui, server)

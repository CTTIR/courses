# =============================================================
# Missing-data mechanism explorer
# Pairs with: Course 3, Week 2, Session 1.
# =============================================================
library(shiny)
library(ggplot2)

ACCENT <- "#1a73e8"

ui <- fluidPage(
  titlePanel("MCAR / MAR / MNAR — bias of complete-case analysis"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n", "Sample size n", 100, 5000, 1000, step = 100),
      sliderInput("rho", "Cor(X, Y)", 0, 0.9, 0.5, step = 0.05),
      sliderInput("p_miss", "Overall fraction missing in Y",
                  0.05, 0.6, 0.3, step = 0.05),
      selectInput("mech", "Missingness mechanism",
                  c("MCAR" = "mcar",
                    "MAR (depends on X)" = "mar",
                    "MNAR (depends on Y)" = "mnar")),
      sliderInput("reps", "Replications", 50, 1000, 200, step = 50),
      actionButton("go", "Re-simulate", class = "btn-primary")
    ),
    mainPanel(
      plotOutput("compare_plot", height = "320px"),
      verbatimTextOutput("metrics"),
      h4("Single example"),
      plotOutput("scatter_plot", height = "320px")
    )
  )
)

simulate_one <- function(n, rho, mech, p_miss) {
  X <- rnorm(n)
  Y <- rho * X + sqrt(1 - rho^2) * rnorm(n)
  miss <- switch(mech,
    mcar = rbinom(n, 1, p_miss),
    mar  = rbinom(n, 1, plogis(qlogis(p_miss) + 1.0 * X)),
    mnar = rbinom(n, 1, plogis(qlogis(p_miss) + 1.0 * Y))
  )
  list(X = X, Y = Y, miss = as.logical(miss))
}

server <- function(input, output, session) {
  trigger <- reactive({ input$go; Sys.time() })

  sim_runs <- reactive({
    invisible(trigger())
    out <- replicate(input$reps, {
      d <- simulate_one(input$n, input$rho, input$mech, input$p_miss)
      mean_full <- mean(d$Y)
      mean_obs  <- mean(d$Y[!d$miss])
      c(full = mean_full, obs = mean_obs)
    })
    data.frame(t(out))
  })

  output$compare_plot <- renderPlot({
    df <- sim_runs()
    df_long <- data.frame(
      method = rep(c("True (full data)", "Complete-case"),
                   each = nrow(df)),
      value  = c(df$full, df$obs)
    )
    ggplot(df_long, aes(value, fill = method)) +
      geom_histogram(bins = 30, alpha = 0.6, position = "identity") +
      labs(x = "Estimated mean of Y", y = "Count", fill = NULL) +
      scale_fill_manual(values = c(ACCENT, "grey60")) +
      theme_minimal(base_size = 12)
  })

  output$metrics <- renderPrint({
    df <- sim_runs()
    cat(sprintf("True mean of Y               : %.4f\n",
                mean(df$full)))
    cat(sprintf("Mean of complete-case estimate: %.4f\n",
                mean(df$obs)))
    cat(sprintf("Bias (CC - true)             : %.4f\n",
                mean(df$obs - df$full)))
    cat(sprintf("SE of complete-case estimate : %.4f\n", sd(df$obs)))
  })

  output$scatter_plot <- renderPlot({
    set.seed(123)
    d <- simulate_one(min(input$n, 800), input$rho,
                      input$mech, input$p_miss)
    df <- data.frame(X = d$X, Y = d$Y, observed = !d$miss)
    ggplot(df, aes(X, Y, colour = observed, alpha = observed)) +
      geom_point(size = 1.6) +
      scale_colour_manual(values = c("FALSE" = "grey60",
                                     "TRUE"  = ACCENT)) +
      scale_alpha_manual(values = c("FALSE" = 0.25, "TRUE" = 0.9)) +
      labs(x = "X", y = "Y", colour = "Y observed",
           alpha = "Y observed") +
      theme_minimal(base_size = 12)
  })
}

shinyApp(ui, server)

# =============================================================
# Decision-curve analysis explorer
# Pairs with: Course 2, Week 4, Session 4 (also Course 4 W3S5).
# =============================================================
library(shiny)
library(ggplot2)
library(tidyr)

ACCENT <- "#1a73e8"

ui <- fluidPage(
  titlePanel("Decision curves — net benefit of two prediction models"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n",  "Sample size n", 200, 5000, 1000, step = 100),
      sliderInput("prev", "Outcome prevalence",
                  0.05, 0.5, 0.2, step = 0.05),
      sliderInput("auc_base", "Baseline model AUC",
                  0.5, 0.95, 0.65, step = 0.01),
      sliderInput("auc_new",  "New model AUC",
                  0.5, 0.95, 0.78, step = 0.01),
      actionButton("go", "Re-simulate", class = "btn-primary"),
      hr(),
      helpText("Models are simulated to have the chosen AUC under ",
              "the binormal model. Net benefit at each threshold = ",
              "TP/n - FP/n * threshold/(1-threshold).")
    ),
    mainPanel(
      plotOutput("dca_plot", height = "400px"),
      verbatimTextOutput("summary_text")
    )
  )
)

# Simulate predicted probabilities to hit a target AUC under binormal
simulate_pred <- function(y, target_auc) {
  delta <- sqrt(2) * qnorm(target_auc)
  z <- ifelse(y == 1, rnorm(length(y), delta, 1), rnorm(length(y)))
  pnorm(z - delta / 2)  # rough mapping to [0, 1]
}

net_benefit <- function(y, p, thr) {
  pos <- p >= thr
  tp <- sum(pos & y == 1)
  fp <- sum(pos & y == 0)
  tp / length(y) - fp / length(y) * (thr / (1 - thr))
}

server <- function(input, output, session) {
  trigger <- reactive({ input$go; Sys.time() })

  d <- reactive({
    invisible(trigger())
    y     <- rbinom(input$n, 1, input$prev)
    p_base <- simulate_pred(y, input$auc_base)
    p_new  <- simulate_pred(y, input$auc_new)
    list(y = y, p_base = p_base, p_new = p_new)
  })

  curves <- reactive({
    a <- d()
    thr <- seq(0.01, min(0.6, 5 * input$prev), length.out = 100)
    nb_base <- sapply(thr, function(t) net_benefit(a$y, a$p_base, t))
    nb_new  <- sapply(thr, function(t) net_benefit(a$y, a$p_new, t))
    nb_all  <- mean(a$y) - (1 - mean(a$y)) * thr / (1 - thr)
    data.frame(threshold = thr,
               base_model = nb_base,
               new_model  = nb_new,
               treat_all  = nb_all,
               treat_none = 0)
  })

  output$dca_plot <- renderPlot({
    df  <- curves()
    long <- pivot_longer(df, -threshold, names_to = "strategy",
                         values_to = "nb")
    ggplot(long, aes(threshold, nb, colour = strategy)) +
      geom_line(linewidth = 0.9) +
      labs(x = "Threshold probability", y = "Net benefit",
           colour = NULL) +
      theme_minimal(base_size = 12)
  })

  output$summary_text <- renderPrint({
    df <- curves()
    diff <- mean(df$new_model - df$base_model)
    cat(sprintf("Mean net-benefit gain (new - base): %.4f\n", diff))
    cat(sprintf("Outcome prevalence in sample      : %.3f\n",
                mean(d()$y)))
  })
}

shinyApp(ui, server)

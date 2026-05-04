# =============================================================
# CLT explorer
# Pairs with: Course 1, Week 3, Session 1.
# =============================================================
library(shiny)
library(ggplot2)

ACCENT <- "#1a73e8"

ui <- fluidPage(
  titlePanel("Central Limit Theorem — by simulation"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dist", "Parent distribution",
                  c("Uniform(0, 1)" = "unif",
                    "Exponential(rate = 1)" = "exp",
                    "Lognormal(meanlog = 0, sdlog = 1)" = "lnorm",
                    "Bernoulli(p = 0.2)" = "bern")),
      sliderInput("n", "Sample size n", min = 1, max = 200,
                  value = 30, step = 1),
      sliderInput("m", "Number of samples (replications)",
                  min = 100, max = 5000, value = 1000, step = 100),
      actionButton("go", "Resample", class = "btn-primary"),
      hr(),
      helpText("Each replication draws n observations from the parent ",
              "distribution and records the mean. The histogram shows ",
              "the resulting sampling distribution of the mean.")
    ),
    mainPanel(
      plotOutput("parent_plot", height = "240px"),
      plotOutput("sampling_plot", height = "320px"),
      verbatimTextOutput("summary_text")
    )
  )
)

draw_one <- function(dist, n) {
  switch(dist,
    unif  = runif(n),
    exp   = rexp(n, rate = 1),
    lnorm = rlnorm(n, 0, 1),
    bern  = rbinom(n, 1, 0.2)
  )
}

theory_mean <- function(dist) {
  switch(dist, unif = 0.5, exp = 1, lnorm = exp(0.5), bern = 0.2)
}
theory_sd <- function(dist) {
  switch(dist,
    unif  = sqrt(1/12),
    exp   = 1,
    lnorm = sqrt((exp(1) - 1) * exp(1)),
    bern  = sqrt(0.2 * 0.8)
  )
}

server <- function(input, output, session) {
  trigger <- reactive({ input$go; Sys.time() })

  parent_sample <- reactive({
    invisible(trigger())
    draw_one(input$dist, 5000)
  })

  means <- reactive({
    invisible(trigger())
    replicate(input$m, mean(draw_one(input$dist, input$n)))
  })

  output$parent_plot <- renderPlot({
    df <- data.frame(x = parent_sample())
    ggplot(df, aes(x)) +
      geom_histogram(bins = 40, fill = ACCENT, alpha = 0.7,
                     colour = "white") +
      labs(title = "Parent distribution (5,000 draws)",
           x = NULL, y = "Count") +
      theme_minimal(base_size = 12)
  })

  output$sampling_plot <- renderPlot({
    df <- data.frame(xbar = means())
    mu  <- theory_mean(input$dist)
    se  <- theory_sd(input$dist) / sqrt(input$n)
    ggplot(df, aes(xbar)) +
      geom_histogram(aes(y = after_stat(density)), bins = 40,
                     fill = ACCENT, alpha = 0.7, colour = "white") +
      stat_function(fun = dnorm, args = list(mean = mu, sd = se),
                    colour = "grey20", linewidth = 0.8) +
      labs(title = sprintf(
             "Sampling distribution of the mean (n = %d, %d reps)",
             input$n, input$m),
           subtitle = "Black curve: Normal(mu, sigma/sqrt(n))",
           x = expression(bar(x)), y = "Density") +
      theme_minimal(base_size = 12)
  })

  output$summary_text <- renderPrint({
    m <- means()
    cat(sprintf("Empirical mean of x-bar     : %.4f\n", mean(m)))
    cat(sprintf("Theoretical mean (mu)       : %.4f\n",
                theory_mean(input$dist)))
    cat(sprintf("Empirical SD of x-bar       : %.4f\n", sd(m)))
    cat(sprintf("Theoretical SE (sigma/sqrt n): %.4f\n",
                theory_sd(input$dist) / sqrt(input$n)))
  })
}

shinyApp(ui, server)

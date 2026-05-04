# =============================================================
# Bootstrap CI explorer
# Pairs with: Course 1, Week 3, Session 2.
# =============================================================
library(shiny)
library(ggplot2)

ACCENT <- "#1a73e8"

ui <- fluidPage(
  titlePanel("Bootstrap confidence intervals"),
  sidebarLayout(
    sidebarPanel(
      selectInput("stat", "Statistic of interest",
                  c("Mean" = "mean",
                    "Median" = "median",
                    "Trimmed mean (10%)" = "tmean",
                    "Standard deviation" = "sd")),
      selectInput("dist", "Population", c(
        "Normal(0, 1)" = "norm",
        "Lognormal(0, 1)" = "lnorm",
        "Exponential(1)" = "exp",
        "Mixture (90% N(0,1), 10% N(5,1))" = "mix")),
      sliderInput("n", "Sample size n", min = 10, max = 500,
                  value = 50, step = 5),
      sliderInput("B", "Bootstrap replications B",
                  min = 200, max = 5000, value = 2000, step = 100),
      sliderInput("conf", "Confidence level",
                  min = 0.80, max = 0.99, value = 0.95, step = 0.01),
      actionButton("go", "Resample", class = "btn-primary")
    ),
    mainPanel(
      plotOutput("sample_plot", height = "240px"),
      plotOutput("boot_plot",   height = "320px"),
      verbatimTextOutput("ci_text")
    )
  )
)

draw <- function(dist, n) {
  switch(dist,
    norm  = rnorm(n),
    lnorm = rlnorm(n, 0, 1),
    exp   = rexp(n),
    mix   = c(rnorm(round(0.9 * n)), rnorm(n - round(0.9 * n), 5, 1)))
}

stat_fun <- function(stat) {
  switch(stat,
    mean   = mean,
    median = median,
    tmean  = function(x) mean(x, trim = 0.10),
    sd     = sd)
}

server <- function(input, output, session) {
  trigger <- reactive({ input$go; Sys.time() })

  sample_data <- reactive({
    invisible(trigger())
    draw(input$dist, input$n)
  })

  boot <- reactive({
    f <- stat_fun(input$stat)
    x <- sample_data()
    replicate(input$B, f(sample(x, replace = TRUE)))
  })

  output$sample_plot <- renderPlot({
    df <- data.frame(x = sample_data())
    ggplot(df, aes(x)) +
      geom_histogram(bins = 30, fill = ACCENT, alpha = 0.7,
                     colour = "white") +
      labs(title = sprintf("Observed sample (n = %d)", input$n),
           x = NULL, y = "Count") +
      theme_minimal(base_size = 12)
  })

  output$boot_plot <- renderPlot({
    b  <- boot()
    p  <- (1 - input$conf) / 2
    ci <- quantile(b, c(p, 1 - p))
    df <- data.frame(stat = b)
    ggplot(df, aes(stat)) +
      geom_histogram(bins = 40, fill = ACCENT, alpha = 0.7,
                     colour = "white") +
      geom_vline(xintercept = ci, colour = "grey20",
                 linewidth = 0.7) +
      labs(title = sprintf("Bootstrap distribution of the %s (B = %d)",
                           input$stat, input$B),
           subtitle = "Vertical lines: percentile CI",
           x = NULL, y = "Count") +
      theme_minimal(base_size = 12)
  })

  output$ci_text <- renderPrint({
    b  <- boot()
    f  <- stat_fun(input$stat)
    p  <- (1 - input$conf) / 2
    ci <- quantile(b, c(p, 1 - p))
    cat(sprintf("Point estimate: %.4f\n", f(sample_data())))
    cat(sprintf("Bootstrap SE  : %.4f\n", sd(b)))
    cat(sprintf("%.0f%% percentile CI: (%.4f, %.4f)\n",
                100 * input$conf, ci[1], ci[2]))
  })
}

shinyApp(ui, server)

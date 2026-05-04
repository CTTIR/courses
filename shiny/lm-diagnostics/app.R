# =============================================================
# Linear-model diagnostics explorer
# Pairs with: Course 2, Week 1, Session 4.
# =============================================================
library(shiny)
library(ggplot2)
library(broom)

ACCENT <- "#1a73e8"

ui <- fluidPage(
  titlePanel("Linear-model diagnostics — what does each plot tell you?"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n", "Sample size n", 20, 500, 100, step = 10),
      sliderInput("slope", "True slope beta_1", -2, 2, 0.7, step = 0.1),
      sliderInput("noise", "Residual SD", 0.1, 5, 1, step = 0.1),
      checkboxInput("hetero", "Add heteroscedasticity", FALSE),
      checkboxInput("outlier", "Inject one high-leverage outlier",
                    FALSE),
      actionButton("go", "Resample", class = "btn-primary")
    ),
    mainPanel(
      plotOutput("scatter", height = "260px"),
      fluidRow(
        column(6, plotOutput("resid_fitted", height = "260px")),
        column(6, plotOutput("qq_plot",      height = "260px"))
      ),
      fluidRow(
        column(6, plotOutput("scale_loc",    height = "260px")),
        column(6, plotOutput("leverage",     height = "260px"))
      ),
      verbatimTextOutput("model_summary")
    )
  )
)

server <- function(input, output, session) {
  trigger <- reactive({ input$go; Sys.time() })

  data_fit <- reactive({
    invisible(trigger())
    n <- input$n
    x <- runif(n, 0, 10)
    sd_x <- if (input$hetero) (0.2 + 0.3 * x) * input$noise
            else rep(input$noise, n)
    y <- 2 + input$slope * x + rnorm(n, 0, sd_x)
    if (input$outlier) {
      x[1] <- 12
      y[1] <- 2 + input$slope * 12 + 6 * input$noise
    }
    df  <- data.frame(x = x, y = y)
    fit <- lm(y ~ x, data = df)
    aug <- augment(fit)
    list(df = df, fit = fit, aug = aug)
  })

  output$scatter <- renderPlot({
    a <- data_fit()
    ggplot(a$df, aes(x, y)) +
      geom_point(colour = ACCENT, alpha = 0.7) +
      geom_smooth(method = "lm", se = FALSE, colour = "grey20",
                  formula = y ~ x) +
      labs(title = "Data + fitted line") +
      theme_minimal(base_size = 12)
  })

  output$resid_fitted <- renderPlot({
    a <- data_fit()$aug
    ggplot(a, aes(.fitted, .resid)) +
      geom_point(alpha = 0.7) +
      geom_hline(yintercept = 0, linetype = 2) +
      geom_smooth(se = FALSE, colour = ACCENT, formula = y ~ x) +
      labs(title = "Residuals vs fitted",
           x = "Fitted", y = "Residual") +
      theme_minimal(base_size = 12)
  })

  output$qq_plot <- renderPlot({
    a <- data_fit()$aug
    ggplot(a, aes(sample = .std.resid)) +
      stat_qq() + stat_qq_line(colour = ACCENT) +
      labs(title = "Normal Q-Q",
           x = "Theoretical", y = "Standardised residual") +
      theme_minimal(base_size = 12)
  })

  output$scale_loc <- renderPlot({
    a <- data_fit()$aug
    ggplot(a, aes(.fitted, sqrt(abs(.std.resid)))) +
      geom_point(alpha = 0.7) +
      geom_smooth(se = FALSE, colour = ACCENT, formula = y ~ x) +
      labs(title = "Scale-location", x = "Fitted",
           y = expression(sqrt(abs("std. resid")))) +
      theme_minimal(base_size = 12)
  })

  output$leverage <- renderPlot({
    a <- data_fit()$aug
    ggplot(a, aes(.hat, .std.resid)) +
      geom_point(aes(size = .cooksd), alpha = 0.7,
                 colour = ACCENT) +
      geom_hline(yintercept = 0, linetype = 2) +
      labs(title = "Residuals vs leverage",
           x = "Leverage", y = "Standardised residual",
           size = "Cook") +
      theme_minimal(base_size = 12)
  })

  output$model_summary <- renderPrint({
    print(summary(data_fit()$fit)$coef)
  })
}

shinyApp(ui, server)

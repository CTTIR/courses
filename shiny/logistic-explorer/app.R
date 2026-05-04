# =============================================================
# Logistic regression explorer
# Pairs with: Course 2, Week 3, Session 1 and Session 5.
# =============================================================
library(shiny)
library(ggplot2)
library(pROC)

ACCENT <- "#1a73e8"

ui <- fluidPage(
  titlePanel("Logistic regression: curve, ROC, calibration"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n",   "Sample size n", 50, 2000, 500, step = 50),
      sliderInput("b0",  "Intercept beta_0", -3, 3, -1, step = 0.1),
      sliderInput("b1",  "Slope beta_1", 0, 3, 1.0, step = 0.1),
      sliderInput("noise_sd", "X spread (SD)", 0.5, 3, 1, step = 0.1),
      actionButton("go", "Resample", class = "btn-primary")
    ),
    mainPanel(
      plotOutput("logistic_curve", height = "260px"),
      fluidRow(
        column(6, plotOutput("roc_plot",         height = "300px")),
        column(6, plotOutput("calibration_plot", height = "300px"))
      ),
      verbatimTextOutput("metrics")
    )
  )
)

server <- function(input, output, session) {
  trigger <- reactive({ input$go; Sys.time() })

  d <- reactive({
    invisible(trigger())
    x <- rnorm(input$n, 0, input$noise_sd)
    p <- plogis(input$b0 + input$b1 * x)
    y <- rbinom(input$n, 1, p)
    fit <- glm(y ~ x, family = binomial)
    phat <- fitted(fit)
    list(x = x, y = y, phat = phat, fit = fit)
  })

  output$logistic_curve <- renderPlot({
    a <- d()
    grid <- seq(min(a$x), max(a$x), length.out = 200)
    pred <- predict(a$fit, newdata = data.frame(x = grid),
                    type = "response")
    df_pts <- data.frame(x = a$x, y = a$y)
    df_curve <- data.frame(x = grid, p = pred)
    ggplot(df_pts, aes(x, y)) +
      geom_jitter(height = 0.04, alpha = 0.4) +
      geom_line(data = df_curve, aes(x, p),
                colour = ACCENT, linewidth = 0.9) +
      labs(title = "Fitted logistic curve",
           x = "x", y = "P(y = 1)") +
      theme_minimal(base_size = 12)
  })

  output$roc_plot <- renderPlot({
    a   <- d()
    rc  <- pROC::roc(a$y, a$phat, quiet = TRUE)
    dfr <- data.frame(spec = rev(rc$specificities),
                      sens = rev(rc$sensitivities))
    ggplot(dfr, aes(1 - spec, sens)) +
      geom_step(colour = ACCENT, linewidth = 0.9) +
      geom_abline(slope = 1, linetype = 2, colour = "grey60") +
      labs(title = sprintf("ROC (AUC = %.3f)", as.numeric(rc$auc)),
           x = "1 - specificity", y = "Sensitivity") +
      coord_equal() + theme_minimal(base_size = 12)
  })

  output$calibration_plot <- renderPlot({
    a <- d()
    dfc <- data.frame(phat = a$phat, y = a$y)
    dfc$bin <- cut(dfc$phat, seq(0, 1, by = 0.1),
                   include.lowest = TRUE)
    cal <- aggregate(cbind(phat, y) ~ bin, data = dfc, FUN = mean)
    ggplot(cal, aes(phat, y)) +
      geom_abline(slope = 1, linetype = 2, colour = "grey60") +
      geom_point(colour = ACCENT, size = 3) +
      geom_line(colour = ACCENT) +
      coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
      labs(title = "Calibration (decile bins)",
           x = "Predicted P(y = 1)",
           y = "Observed P(y = 1)") +
      theme_minimal(base_size = 12)
  })

  output$metrics <- renderPrint({
    a    <- d()
    rc   <- pROC::roc(a$y, a$phat, quiet = TRUE)
    brier <- mean((a$phat - a$y)^2)
    cat(sprintf("AUC          = %.3f\n", as.numeric(rc$auc)))
    cat(sprintf("Brier score  = %.3f\n", brier))
    cat(sprintf("Mean(p|y=1)  = %.3f\n", mean(a$phat[a$y == 1])))
    cat(sprintf("Mean(p|y=0)  = %.3f\n", mean(a$phat[a$y == 0])))
    cat("\nCoefficients:\n")
    print(summary(a$fit)$coef)
  })
}

shinyApp(ui, server)

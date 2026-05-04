# =============================================================
# Regularisation path explorer (ridge / lasso / elastic net)
# Pairs with: Course 4, Week 1, Session 2.
# =============================================================
library(shiny)
library(ggplot2)
library(glmnet)
library(tidyr)

ACCENT <- "#1a73e8"

ui <- fluidPage(
  titlePanel("Regularisation path — ridge, lasso, elastic net"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n", "Sample size n", 30, 500, 100, step = 10),
      sliderInput("p", "Number of predictors p",
                  10, 500, 50, step = 10),
      sliderInput("s", "Number of truly non-zero coefficients",
                  1, 50, 5, step = 1),
      sliderInput("snr", "Signal-to-noise ratio", 0.1, 5, 2,
                  step = 0.1),
      sliderInput("alpha", "Elastic-net alpha (0 = ridge, 1 = lasso)",
                  0, 1, 1, step = 0.05),
      actionButton("go", "Re-simulate", class = "btn-primary")
    ),
    mainPanel(
      plotOutput("path_plot", height = "320px"),
      plotOutput("cv_plot",   height = "260px"),
      verbatimTextOutput("summary_text")
    )
  )
)

server <- function(input, output, session) {
  trigger <- reactive({ input$go; Sys.time() })

  d <- reactive({
    invisible(trigger())
    n <- input$n; p <- input$p; s <- input$s
    X <- matrix(rnorm(n * p), nrow = n)
    beta <- numeric(p)
    beta[seq_len(s)] <- runif(s, 0.5, 1.5) *
      sample(c(-1, 1), s, replace = TRUE)
    sd_eps <- sqrt(sum((X %*% beta)^2) / (n * input$snr))
    y <- X %*% beta + rnorm(n, 0, sd_eps)
    fit  <- glmnet(X, y, alpha = input$alpha)
    cvfit <- cv.glmnet(X, y, alpha = input$alpha)
    list(X = X, y = y, beta = beta, fit = fit, cvfit = cvfit)
  })

  output$path_plot <- renderPlot({
    a <- d()
    coefs <- as.matrix(coef(a$fit))[-1, ]
    long <- as.data.frame(coefs)
    long$var <- factor(seq_len(nrow(long)))
    long_l <- pivot_longer(long, -var, names_to = "step",
                           values_to = "coef")
    long_l$lambda <- a$fit$lambda[as.integer(long_l$step) + 1]
    long_l$true_nonzero <- long_l$var %in%
      as.character(seq_len(input$s))
    ggplot(long_l, aes(log(lambda), coef,
                       group = var,
                       colour = true_nonzero)) +
      geom_line(alpha = 0.8) +
      scale_colour_manual(values = c("FALSE" = "grey70",
                                     "TRUE"  = ACCENT)) +
      labs(x = expression(log(lambda)),
           y = expression(beta[j]),
           colour = "Truly non-zero") +
      theme_minimal(base_size = 12)
  })

  output$cv_plot <- renderPlot({
    a <- d()
    df <- data.frame(loglam = log(a$cvfit$lambda),
                     mean_cv = a$cvfit$cvm,
                     low = a$cvfit$cvlo, hi = a$cvfit$cvup)
    ggplot(df, aes(loglam, mean_cv)) +
      geom_ribbon(aes(ymin = low, ymax = hi), alpha = 0.3,
                  fill = ACCENT) +
      geom_line(colour = ACCENT, linewidth = 0.9) +
      geom_vline(xintercept = log(a$cvfit$lambda.min),
                 linetype = 2) +
      geom_vline(xintercept = log(a$cvfit$lambda.1se),
                 linetype = 3) +
      labs(x = expression(log(lambda)), y = "CV MSE") +
      theme_minimal(base_size = 12)
  })

  output$summary_text <- renderPrint({
    a <- d()
    cat(sprintf("alpha            = %.2f\n", input$alpha))
    cat(sprintf("lambda.min       = %.4f\n", a$cvfit$lambda.min))
    cat(sprintf("lambda.1se       = %.4f\n", a$cvfit$lambda.1se))
    nz <- sum(coef(a$cvfit, s = "lambda.min")[-1] != 0)
    cat(sprintf("# non-zero @ min : %d (true s = %d)\n",
                nz, input$s))
  })
}

shinyApp(ui, server)

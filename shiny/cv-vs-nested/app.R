# =============================================================
# Cross-validation vs nested CV — selection bias illustrator
# Pairs with: Course 4, Week 1, Session 1.
# =============================================================
library(shiny)
library(ggplot2)

ACCENT <- "#1a73e8"

ui <- fluidPage(
  titlePanel("Cross-validation vs nested CV — the selection-bias trap"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n", "Sample size n", 30, 500, 100, step = 10),
      sliderInput("p", "Number of candidate predictors p",
                  10, 1000, 200, step = 10),
      sliderInput("k", "Outer / inner CV folds k", 3, 10, 5,
                  step = 1),
      sliderInput("reps", "Replications", 5, 50, 20, step = 5),
      actionButton("go", "Re-simulate", class = "btn-primary"),
      hr(),
      helpText("All p predictors are pure noise — there is NO real ",
              "signal. Naive CV picks the 'best' from many candidates ",
              "and re-uses the same folds, producing optimistic CV ",
              "error. Nested CV picks within an inner loop and ",
              "evaluates on the outer.")
    ),
    mainPanel(
      plotOutput("cv_plot", height = "360px"),
      verbatimTextOutput("summary_text")
    )
  )
)

cv_naive <- function(n, p, k) {
  X <- matrix(rnorm(n * p), nrow = n)
  y <- rnorm(n)
  cors <- abs(cor(X, y))
  best <- which.max(cors)
  folds <- sample(rep(1:k, length.out = n))
  errs <- sapply(1:k, function(i) {
    tr <- folds != i; te <- folds == i
    fit <- lm(y[tr] ~ X[tr, best])
    pred <- coef(fit)[1] + coef(fit)[2] * X[te, best]
    mean((y[te] - pred)^2)
  })
  mean(errs)
}

cv_nested <- function(n, p, k) {
  X <- matrix(rnorm(n * p), nrow = n)
  y <- rnorm(n)
  outer <- sample(rep(1:k, length.out = n))
  errs <- sapply(1:k, function(i) {
    tr_idx <- which(outer != i); te_idx <- which(outer == i)
    cors_in <- abs(cor(X[tr_idx, ], y[tr_idx]))
    best <- which.max(cors_in)
    fit  <- lm(y[tr_idx] ~ X[tr_idx, best])
    pred <- coef(fit)[1] + coef(fit)[2] * X[te_idx, best]
    mean((y[te_idx] - pred)^2)
  })
  mean(errs)
}

server <- function(input, output, session) {
  trigger <- reactive({ input$go; Sys.time() })

  res <- reactive({
    invisible(trigger())
    n <- input$n; p <- input$p; k <- input$k
    naive_v  <- replicate(input$reps, cv_naive(n, p, k))
    nested_v <- replicate(input$reps, cv_nested(n, p, k))
    data.frame(
      method = rep(c("Naive CV (selection on full data)",
                     "Nested CV"),
                   each = input$reps),
      mse = c(naive_v, nested_v)
    )
  })

  output$cv_plot <- renderPlot({
    df <- res()
    ggplot(df, aes(method, mse, fill = method)) +
      geom_boxplot(alpha = 0.7, colour = "grey30") +
      geom_hline(yintercept = 1, linetype = 2, colour = "grey50") +
      scale_fill_manual(values = c(ACCENT, "grey60")) +
      labs(x = NULL, y = "Estimated MSE",
           subtitle = "Dashed line: true MSE (= Var(y) = 1) under no signal") +
      theme_minimal(base_size = 12) +
      theme(legend.position = "none")
  })

  output$summary_text <- renderPrint({
    df <- res()
    cat(sprintf("Mean naive CV MSE  : %.3f\n",
                mean(df$mse[df$method ==
                              "Naive CV (selection on full data)"])))
    cat(sprintf("Mean nested CV MSE : %.3f\n",
                mean(df$mse[df$method == "Nested CV"])))
    cat("True MSE under no signal : 1.000\n")
  })
}

shinyApp(ui, server)

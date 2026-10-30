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

# Fit every univariate candidate on training rows, then predict held-out rows.
# This is vectorised ordinary least squares with an intercept.
candidate_predictions <- function(X, y, newx) {
  xbar <- colMeans(X)
  centered <- sweep(X, 2, xbar)
  variance <- colSums(centered^2)
  slope <- as.numeric(crossprod(centered, y - mean(y))) /
    ifelse(variance > 0, variance, Inf)
  sweep(sweep(newx, 2, xbar), 2, slope, "*") + mean(y)
}

candidate_cv <- function(X, y, folds) {
  errors <- matrix(NA_real_, nrow(X), ncol(X))
  for (i in sort(unique(folds))) {
    tr <- folds != i; te <- !tr
    pred <- candidate_predictions(X[tr, , drop = FALSE], y[tr],
                                  X[te, , drop = FALSE])
    errors[te, ] <- (y[te] - pred)^2
  }
  colMeans(errors)
}

compare_cv <- function(X, y, k) {
  folds <- sample(rep(seq_len(k), length.out = nrow(X)))
  # Choosing and reporting the minimum from these same folds leaks selection.
  naive <- min(candidate_cv(X, y, folds))
  squared_error <- numeric(length(y))
  oracle_error <- numeric(length(y))
  for (i in seq_len(k)) {
    tr <- folds != i; te <- !tr
    inner <- sample(rep(seq_len(k), length.out = sum(tr)))
    best <- which.min(candidate_cv(X[tr, , drop = FALSE], y[tr], inner))
    fit <- lm(y[tr] ~ X[tr, best])
    pred <- coef(fit)[1] + coef(fit)[2] * X[te, best]
    squared_error[te] <- (y[te] - pred)^2
    # Exact future MSE under independent N(0,1) predictors and responses.
    oracle_error[te] <- 1 + sum(coef(fit)^2)
  }
  c(naive = naive, nested = mean(squared_error), oracle = mean(oracle_error))
}

server <- function(input, output, session) {
  trigger <- reactive({ input$go; Sys.time() })

  res <- reactive({
    invisible(trigger())
    n <- input$n; p <- input$p; k <- input$k
    results <- replicate(input$reps, {
      X <- matrix(rnorm(n * p), nrow = n)
      y <- rnorm(n)
      compare_cv(X, y, k)
    })
    data.frame(
      method = rep(c("CV minimum (selection and evaluation together)",
                     "Nested CV", "True error of outer fitted models"),
                   each = input$reps),
      mse = c(results["naive", ], results["nested", ], results["oracle", ])
    )
  })

  output$cv_plot <- renderPlot({
    df <- res()
    ggplot(df, aes(method, mse, fill = method)) +
      geom_boxplot(alpha = 0.7, colour = "grey30") +
      geom_hline(yintercept = 1, linetype = 2, colour = "grey50") +
      scale_fill_manual(values = c(ACCENT, "grey60", "#238b45")) +
      labs(x = NULL, y = "Estimated MSE",
           subtitle = "Dashed line: irreducible noise variance = 1 (not fitted-model error)") +
      theme_minimal(base_size = 12) +
      theme(legend.position = "none")
  })

  output$summary_text <- renderPrint({
    df <- res()
    cat(sprintf("Mean naive CV MSE  : %.3f\n",
                mean(df$mse[df$method ==
                              "CV minimum (selection and evaluation together)"])))
    cat(sprintf("Mean nested CV MSE : %.3f\n",
                mean(df$mse[df$method == "Nested CV"])))
    cat(sprintf("Mean true error of outer fits: %.3f\n",
                mean(df$mse[df$method == "True error of outer fitted models"])))
    cat("Irreducible noise variance: 1.000\n")
  })
}

shinyApp(ui, server)

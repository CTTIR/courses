# =============================================================
# Diagnostic test calculator (Bayes for medical tests)
# Pairs with: Course 1, Week 2, Session 3.
# =============================================================
library(shiny)
library(ggplot2)

ACCENT <- "#1a73e8"

ui <- fluidPage(
  titlePanel("Diagnostic test — sensitivity, specificity, PPV, NPV"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("sens", "Sensitivity (Se)",
                  min = 0.5, max = 1, value = 0.90, step = 0.01),
      sliderInput("spec", "Specificity (Sp)",
                  min = 0.5, max = 1, value = 0.95, step = 0.01),
      sliderInput("prev", "Disease prevalence",
                  min = 0.001, max = 0.5, value = 0.05,
                  step = 0.001),
      hr(),
      helpText("Bayes' theorem on a 2x2 outcome table. ",
              "PPV = P(disease | test+); NPV = P(no disease | test-).")
    ),
    mainPanel(
      h4("Per-1000 outcome table"),
      tableOutput("table"),
      h4("Predictive values"),
      verbatimTextOutput("vals"),
      h4("PPV vs prevalence"),
      plotOutput("ppv_plot", height = "320px")
    )
  )
)

server <- function(input, output, session) {
  vals <- reactive({
    Se <- input$sens; Sp <- input$spec; pi <- input$prev
    PPV <- Se * pi / (Se * pi + (1 - Sp) * (1 - pi))
    NPV <- Sp * (1 - pi) / (Sp * (1 - pi) + (1 - Se) * pi)
    list(PPV = PPV, NPV = NPV,
         LRp = Se / (1 - Sp), LRn = (1 - Se) / Sp)
  })

  output$table <- renderTable({
    Se <- input$sens; Sp <- input$spec; pi <- input$prev
    N <- 1000
    D  <- N * pi;       ND <- N - D
    TP <- D * Se;       FN <- D - TP
    FP <- ND * (1 - Sp); TN <- ND - FP
    data.frame(
      ` ` = c("Test +", "Test -", "Total"),
      Disease = round(c(TP, FN, D)),
      `No disease` = round(c(FP, TN, ND)),
      Total = round(c(TP + FP, FN + TN, N)),
      check.names = FALSE
    )
  }, digits = 0)

  output$vals <- renderPrint({
    v <- vals()
    cat(sprintf("PPV = %.3f\n", v$PPV))
    cat(sprintf("NPV = %.3f\n", v$NPV))
    cat(sprintf("LR+ = %.2f\n", v$LRp))
    cat(sprintf("LR- = %.2f\n", v$LRn))
  })

  output$ppv_plot <- renderPlot({
    Se <- input$sens; Sp <- input$spec
    p  <- seq(0.001, 0.5, length.out = 200)
    ppv <- Se * p / (Se * p + (1 - Sp) * (1 - p))
    df <- data.frame(p = p, ppv = ppv)
    ggplot(df, aes(p, ppv)) +
      geom_line(colour = ACCENT, linewidth = 0.9) +
      geom_vline(xintercept = input$prev, linetype = 2,
                 colour = "grey50") +
      labs(x = "Prevalence", y = "PPV") +
      theme_minimal(base_size = 12) +
      ylim(0, 1)
  })
}

shinyApp(ui, server)

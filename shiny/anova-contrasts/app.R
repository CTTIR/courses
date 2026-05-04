# =============================================================
# One-way ANOVA + contrasts explorer
# Pairs with: Course 2, Week 2, Session 1.
# =============================================================
library(shiny)
library(ggplot2)
library(broom)

ACCENT <- "#1a73e8"

ui <- fluidPage(
  titlePanel("One-way ANOVA — group means and Tukey HSD"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("k", "Number of groups", 2, 6, 4, step = 1),
      sliderInput("n_per", "n per group", 5, 100, 30, step = 5),
      sliderInput("effect", "Spread of true group means",
                  0, 3, 1, step = 0.1),
      sliderInput("noise", "Within-group SD", 0.2, 3, 1, step = 0.1),
      actionButton("go", "Resample", class = "btn-primary"),
      hr(),
      helpText("True means equally spaced from -effect to +effect ",
              "across the k groups. Noise is normal.")
    ),
    mainPanel(
      plotOutput("box_plot", height = "320px"),
      h4("ANOVA table"),
      tableOutput("aov_table"),
      h4("Tukey HSD pairwise comparisons"),
      tableOutput("tukey_table")
    )
  )
)

server <- function(input, output, session) {
  trigger <- reactive({ input$go; Sys.time() })

  d <- reactive({
    invisible(trigger())
    k     <- input$k
    means <- seq(-input$effect, input$effect, length.out = k)
    df <- data.frame(
      group = factor(rep(LETTERS[1:k], each = input$n_per)),
      y = unlist(lapply(seq_len(k), function(i) {
        rnorm(input$n_per, means[i], input$noise)
      }))
    )
    df
  })

  output$box_plot <- renderPlot({
    df <- d()
    ggplot(df, aes(group, y, fill = group)) +
      geom_boxplot(alpha = 0.6, colour = "grey30") +
      geom_jitter(width = 0.1, alpha = 0.4) +
      scale_fill_manual(values = rep(ACCENT, length(unique(df$group)))) +
      theme_minimal(base_size = 12) +
      theme(legend.position = "none") +
      labs(x = NULL, y = "y")
  })

  output$aov_table <- renderTable({
    df <- d()
    fit <- aov(y ~ group, data = df)
    tab <- broom::tidy(fit)
    tab[, c("term", "df", "sumsq", "meansq", "statistic", "p.value")]
  }, digits = 4)

  output$tukey_table <- renderTable({
    df <- d()
    fit <- aov(y ~ group, data = df)
    tukey <- TukeyHSD(fit)$group
    out <- as.data.frame(tukey)
    out$comparison <- rownames(out)
    out[, c("comparison", "diff", "lwr", "upr", "p adj")]
  }, digits = 4)
}

shinyApp(ui, server)

# =============================================================
# DAG explorer — adjustment sets via dagitty
# Pairs with: Course 3, Week 3, Session 3.
# =============================================================
library(shiny)
library(dagitty)
library(ggdag)
library(ggplot2)

ACCENT <- "#1a73e8"

ui <- fluidPage(
  titlePanel("DAG explorer — adjustment sets"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dag_choice", "Pre-built DAG",
                  c("Confounder" = "confounder",
                    "Mediator" = "mediator",
                    "Collider" = "collider",
                    "M-bias" = "mbias",
                    "Custom (edit text)" = "custom")),
      conditionalPanel(
        "input.dag_choice == 'custom'",
        textAreaInput("dag_text",
                      "DAG (dagitty syntax)",
                      "dag { X -> Y; Z -> X; Z -> Y }",
                      width = "100%", rows = 5)
      ),
      textInput("exposure", "Exposure", value = "X"),
      textInput("outcome",  "Outcome",  value = "Y"),
      hr(),
      helpText("Adjustment sets are computed under Pearl's ",
              "back-door criterion via dagitty.")
    ),
    mainPanel(
      plotOutput("dag_plot", height = "360px"),
      h4("Minimal sufficient adjustment sets"),
      verbatimTextOutput("adj_sets"),
      h4("Implied conditional independencies"),
      verbatimTextOutput("indep")
    )
  )
)

dag_text <- function(choice) {
  switch(choice,
    confounder = "dag { X -> Y; Z -> X; Z -> Y }",
    mediator   = "dag { X -> M -> Y; X -> Y }",
    collider   = "dag { X -> C; Y -> C }",
    mbias      = "dag { U1 -> X; U1 -> Z; U2 -> Z; U2 -> Y; X -> Y }"
  )
}

server <- function(input, output, session) {
  observeEvent(input$dag_choice, {
    if (input$dag_choice != "custom") {
      updateTextAreaInput(session, "dag_text",
                          value = dag_text(input$dag_choice))
    }
  })

  dag <- reactive({
    txt <- if (input$dag_choice == "custom") input$dag_text
           else dag_text(input$dag_choice)
    tryCatch(dagitty(txt), error = function(e) NULL)
  })

  output$dag_plot <- renderPlot({
    g <- dag(); req(g)
    ggdag(tidy_dagitty(g), node_size = 16, text_size = 4) +
      theme_dag()
  })

  output$adj_sets <- renderPrint({
    g <- dag(); req(g)
    sets <- adjustmentSets(g, exposure = input$exposure,
                           outcome = input$outcome)
    if (length(sets) == 0) {
      cat("No adjustment set required, or the effect is not ",
          "identifiable from the DAG.\n", sep = "")
    } else {
      print(sets)
    }
  })

  output$indep <- renderPrint({
    g <- dag(); req(g)
    print(impliedConditionalIndependencies(g))
  })
}

shinyApp(ui, server)

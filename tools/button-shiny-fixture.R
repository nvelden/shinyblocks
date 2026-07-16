#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
port <- if (length(args)) as.integer(args[[1]]) else 4328L

devtools::load_all(".", quiet = TRUE)

ui <- shiny::fluidPage(
  block_button(
    "Run",
    id = "run",
    class = "author-class",
    style = "width: 100px;",
    title = "Run title",
    name = "run-name",
    `aria-label` = "Run action",
    `data-test-button` = "preserved",
    `data-slot` = "custom-slot",
    type = "submit"
  ),
  shiny::actionButton("resize", "Resize"),
  shiny::actionButton("clear_style", "Clear style"),
  shiny::verbatimTextOutput("click_value")
)

server <- function(input, output, session) {
  output$click_value <- shiny::renderText(input$run %||% 0L)
  shiny::observeEvent(input$resize, {
    update_block_button(session, "run", style = list(width = "200px"))
  })
  shiny::observeEvent(input$clear_style, {
    update_block_button(session, "run", style = NULL)
  })
}

shiny::runApp(shiny::shinyApp(ui, server), host = "127.0.0.1", port = port)

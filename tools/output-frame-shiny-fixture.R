#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
port <- if (length(args)) as.integer(args[[1]]) else 4327L

devtools::load_all(".", quiet = TRUE)

ui <- shiny::fluidPage(
  block_theme(
    border = "rgb(11, 22, 33)",
    `muted-foreground` = "rgb(77, 88, 99)",
    scope = "#output-host"
  ),
  shiny::tags$section(
    id = "output-host",
    bslib::card(
      style = "width: 320px;",
      block_plot_output(
        "standalone_plot",
        aspect = "16/9",
        border = TRUE,
        rounded = TRUE,
        caption = "Standalone reactive plot",
        click = "standalone_plot_click",
        class = "standalone-plot-fixture"
      )
    ),
    shiny::actionButton("redraw", "Redraw"),
    shiny::textOutput("version")
  )
)

server <- function(input, output, session) {
  version <- shiny::reactiveVal(1L)
  shiny::observeEvent(input$redraw, version(version() + 1L))
  output$standalone_plot <- shiny::renderPlot({
    current <- version()
    graphics::plot(1:3, c(1, current, 3), type = "b")
  })
  output$version <- shiny::renderText(version())
}

shiny::runApp(shiny::shinyApp(ui, server), host = "127.0.0.1", port = port)

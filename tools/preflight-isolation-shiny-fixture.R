#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
port <- if (length(args)) as.integer(args[[1]]) else 4329L

devtools::load_all(".", quiet = TRUE)

compatibility_fixture <- function(prefix) {
  shiny::tags$section(
    id = paste0(prefix, "-fixture"),
    class = "compat-fixture",
    shiny::tags$h2(id = paste0(prefix, "-heading"), "Host heading"),
    shiny::tags$ul(
      id = paste0(prefix, "-list"),
      shiny::tags$li("First"),
      shiny::tags$li("Second")
    ),
    shiny::tags$table(
      id = paste0(prefix, "-table"),
      shiny::tags$tbody(shiny::tags$tr(shiny::tags$td("Cell")))
    ),
    shiny::tags$button(id = paste0(prefix, "-button"), class = "compat-focus", "Host button"),
    shiny::tags$input(id = paste0(prefix, "-input"), class = "compat-focus", value = "Host input"),
    shiny::tags$select(
      id = paste0(prefix, "-select"),
      class = "compat-focus",
      shiny::tags$option("One")
    ),
    shiny::tags$textarea(id = paste0(prefix, "-textarea"), class = "compat-focus", "Host textarea"),
    shiny::tags$svg(
      id = paste0(prefix, "-svg"),
      width = "10",
      height = "10",
      shiny::tags$circle(cx = "5", cy = "5", r = "4")
    ),
    shiny::tags$iframe(id = paste0(prefix, "-iframe"), title = "Host iframe"),
    shiny::tags$div(id = paste0(prefix, "-selectize"), class = "selectize-control", "Selectize-style host"),
    shiny::tags$div(id = paste0(prefix, "-card"), class = "card", "bslib-style host card"),
    shiny::tags$div(id = paste0(prefix, "-widget"), class = "html-widget", "htmlwidget-style host")
  )
}

host_css <- shiny::tags$style(shiny::HTML("\n.compat-fixture { font-family: Georgia, serif; color: rgb(20, 30, 40); }\n.compat-focus:focus { outline: 5px solid rgb(90, 10, 20); outline-offset: 2px; }\n.selectize-control { box-sizing: content-box; padding: 7px; border: 2px solid rgb(10, 20, 30); }\n.card { box-sizing: content-box; margin: 11px; padding: 9px; border: 3px solid rgb(30, 40, 50); border-radius: 13px; }\n.html-widget { box-sizing: content-box; position: relative; margin: 6px; border: 4px solid rgb(50, 60, 70); }\n"))

ui <- htmltools::tagList(
  block_page(
    host_css,
    compatibility_fixture("inside"),
    block_card(
      block_card_header(block_card_title("Owned card")),
      block_card_content("Owned content"),
      class = "owned-card-check"
    ),
    title = "Preflight isolation"
  ),
  compatibility_fixture("outside")
)

shiny::runApp(shiny::shinyApp(ui, function(...) {}), host = "127.0.0.1", port = port)

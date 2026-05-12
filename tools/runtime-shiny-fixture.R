#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
port <- if (length(args) > 0) as.integer(args[[1]]) else 4325L

devtools::load_all(".", quiet = TRUE)
runtime <- asNamespace("shinyblocks")

dynamic_visible <- shiny::reactiveVal(FALSE)

module_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::div(
    id = ns("root"),
    runtime$runtime_component(
      component = "fixture",
      input_id = ns("choice"),
      state = list(value = "m0"),
      binding = list(input = TRUE),
      mount_id = ns("runtime-choice")
    ),
    shiny::actionButton(ns("set"), "Set module"),
    shiny::verbatimTextOutput(ns("value"))
  )
}

ui <- shiny::fluidPage(
  runtime$runtime_component(
    component = "fixture",
    input_id = "choice",
    state = list(value = "a"),
    binding = list(input = TRUE),
    mount_id = "runtime-choice",
    children = list(
      shiny::textOutput("child_text"),
      shiny::textInput("nested", "Nested", value = "n0")
    )
  ),
  shiny::verbatimTextOutput("choice_value"),
  shiny::verbatimTextOutput("nested_value"),
  shiny::actionButton("set_b", "Set B"),
  shiny::actionButton("clear_choice", "Clear"),
  shiny::actionButton("disable_choice", "Disable"),
  shiny::actionButton("enable_choice", "Enable"),
  shiny::actionButton("toggle_dynamic", "Toggle dynamic"),
  shiny::actionButton("insert_runtime", "Insert runtime"),
  shiny::actionButton("remove_runtime", "Remove runtime"),
  shiny::uiOutput("dynamic_mount"),
  shiny::verbatimTextOutput("dynamic_value"),
  shiny::div(id = "insert_target"),
  shiny::verbatimTextOutput("inserted_value"),
  module_ui("mod")
)

server <- function(input, output, session) {
  output$child_text <- shiny::renderText("child-ready")
  output$choice_value <- shiny::renderText(input$choice %||% "<NULL>")
  output$nested_value <- shiny::renderText(input$nested %||% "<NULL>")
  output$dynamic_value <- shiny::renderText(input$dynamic %||% "<NULL>")
  output$inserted_value <- shiny::renderText(input$inserted %||% "<NULL>")

  shiny::observeEvent(input$set_b, {
    runtime$runtime_update(
      session = session,
      input_id = "choice",
      component = "fixture",
      value = "b",
      notify = TRUE,
      clearable = "value"
    )
  })

  shiny::observeEvent(input$clear_choice, {
    runtime$runtime_update(
      session = session,
      input_id = "choice",
      component = "fixture",
      value = NULL,
      notify = TRUE,
      clearable = "value"
    )
  })

  shiny::observeEvent(input$disable_choice, {
    runtime$runtime_update(
      session = session,
      input_id = "choice",
      component = "fixture",
      disabled = TRUE
    )
  })

  shiny::observeEvent(input$enable_choice, {
    runtime$runtime_update(
      session = session,
      input_id = "choice",
      component = "fixture",
      disabled = FALSE
    )
  })

  shiny::observeEvent(input$toggle_dynamic, {
    dynamic_visible(!isTRUE(dynamic_visible()))
  })

  output$dynamic_mount <- shiny::renderUI({
    if (!isTRUE(dynamic_visible())) {
      return(NULL)
    }

    runtime$runtime_component(
      component = "fixture",
      input_id = "dynamic",
      state = list(value = "x"),
      binding = list(input = TRUE),
      mount_id = "runtime-dynamic",
      children = list(shiny::textOutput("dynamic_child"))
    )
  })

  output$dynamic_child <- shiny::renderText("dynamic-child-ready")

  shiny::observeEvent(input$insert_runtime, {
    shiny::insertUI(
      selector = "#insert_target",
      where = "beforeEnd",
      ui = shiny::div(
        id = "inserted_host",
        runtime$runtime_component(
          component = "fixture",
          input_id = "inserted",
          state = list(value = "y"),
          binding = list(input = TRUE),
          mount_id = "runtime-inserted",
          children = list(shiny::textOutput("inserted_child"))
        )
      )
    )
  })

  shiny::observeEvent(input$remove_runtime, {
    shiny::removeUI(selector = "#inserted_host", immediate = TRUE)
  })

  output$inserted_child <- shiny::renderText("inserted-child-ready")

  shiny::moduleServer("mod", function(input, output, session) {
    output$value <- shiny::renderText(input$choice %||% "<NULL>")

    shiny::observeEvent(input$set, {
      runtime$runtime_update(
        session = session,
        input_id = "choice",
        component = "fixture",
        value = "m1",
        notify = TRUE,
        clearable = "value"
      )
    })
  })
}

shiny::runApp(
  shiny::shinyApp(ui = ui, server = server),
  host = "127.0.0.1",
  port = port,
  launch.browser = FALSE
)

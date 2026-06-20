#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
port <- if (length(args) > 0) as.integer(args[[1]]) else 4325L

devtools::load_all(".", quiet = TRUE)
runtime <- asNamespace("shinyblocks")

dynamic_visible <- shiny::reactiveVal(FALSE)

htmlwidget_fixture <- function() {
  htmlwidgets::createWidget(
    name = "runtimeFixture",
    x = list(text = "widget-ready"),
    width = "220px",
    height = "40px",
    package = "shinyblocks",
    elementId = "fixture-widget",
    dependencies = list(
      htmltools::htmlDependency(
        name = "runtime-fixture-widget",
        version = "1.0.0",
        src = c(file = normalizePath("tools", mustWork = TRUE)),
        script = "runtime-fixture-widget.js"
      )
    )
  )
}

module_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::div(
    id = ns("root"),
    runtime$runtime_component(
      component = "fixture", .validate = FALSE,
      input_id = ns("choice"),
      state = list(value = "m0"),
      binding = list(input = TRUE),
      mount_id = ns("runtime-choice")
    ),
    block_file_input(ns("upload"), button_label = "Module upload"),
    block_date_picker(ns("date"), value = "2026-06-15", class = "runtime-mod-date-fixture"),
    block_progress(ns("progress"), value = 0.1, show_value = TRUE, class = "runtime-mod-progress-fixture"),
    shiny::actionButton(ns("set_progress_60"), "Set module progress 60"),
    shiny::verbatimTextOutput(ns("value")),
    shiny::verbatimTextOutput(ns("upload_value")),
    shiny::verbatimTextOutput(ns("date_value")),
    shiny::verbatimTextOutput(ns("progress_value"))
  )
}

ui <- shiny::fluidPage(
  shiny::tags$style(shiny::HTML(
    "
    #host-button.btn {
      border-radius: 13px;
      box-sizing: content-box;
      color: rgb(1, 2, 3);
    }
    #host-nav.nav-link {
      color: rgb(4, 5, 6);
      text-decoration-line: underline;
    }
    #host-selectize.selectize-control {
      box-sizing: content-box;
      min-height: 17px;
    }
    #host-bslib-card.card {
      box-sizing: content-box;
      border-radius: 19px;
    }
    #host-plotly.js-plotly-plot {
      box-sizing: content-box;
      position: relative;
    }
    #portal-host-button.btn {
      border-radius: 17px;
      box-sizing: content-box;
    }
    #fixture-widget.html-widget {
      box-sizing: content-box;
    }
    #host-token-probe {
      --background: rgb(7, 8, 9);
      color: var(--background);
    }
    "
  )),
  shiny::tags$button(id = "host-button", class = "btn", "Host button"),
  shiny::tags$a(id = "host-nav", class = "nav-link", href = "#", "Host nav"),
  shiny::tags$div(
    id = "host-selectize",
    class = "selectize-control",
    "Host selectize"
  ),
  shiny::tags$div(id = "host-token-probe", "Host token probe"),
  bslib::card(
    id = "host-bslib-card",
    class = "host-bslib-card",
    "Host bslib card"
  ),
  shiny::tags$div(
    id = "host-plotly",
    class = "js-plotly-plot plotly html-widget",
    "Host plotly-style widget"
  ),
  shiny::tags$div(
    `data-shinyblocks-portal-root` = "",
    shiny::tags$button(
      id = "portal-host-button",
      class = "btn",
      "Portal host button"
    )
  ),
  runtime$runtime_component(
    component = "fixture", .validate = FALSE,
    input_id = "choice",
    state = list(value = "a"),
    binding = list(input = TRUE),
    mount_id = "runtime-choice",
    children = list(
      shiny::textOutput("child_text"),
      shiny::textInput("nested", "Nested", value = "n0"),
      shiny::plotOutput("nested_plot", height = "120px"),
      DT::dataTableOutput("nested_table"),
      htmlwidget_fixture()
    )
  ),
  block_select(
    "runtime_select",
    choices = c(Free = "free", Pro = "pro"),
    selected = "free",
    placeholder = "Choose plan",
    size = "lg",
    class = "runtime-select-fixture"
  ),
  block_select(
    "runtime_multi_select",
    choices = c(One = "one", Two = "two", Three = "three"),
    selected = c("one"),
    placeholder = "Choose options",
    multiple = TRUE,
    max_items = 2,
    class = "runtime-multi-select-fixture"
  ),
  block_checkbox(
    "runtime_checkbox",
    "Runtime checkbox",
    value = FALSE,
    class = "runtime-checkbox-fixture"
  ),
  block_switch(
    "runtime_switch",
    "Runtime switch",
    value = FALSE,
    class = "runtime-switch-fixture"
  ),
  block_slider(
    "runtime_slider",
    value = 50,
    min = 0,
    max = 100,
    step = 5,
    class = "runtime-slider-fixture"
  ),
  block_button(
    "Runtime button",
    id = "runtime_button",
    class = "runtime-button-fixture"
  ),
  block_date_picker(
    "runtime_date",
    value = "2026-06-15",
    min = "2026-06-10",
    max = "2026-06-20",
    class = "runtime-date-fixture"
  ),
  block_date_range_picker(
    "runtime_range",
    start = "2026-06-12",
    end = "2026-06-18",
    min = "2026-06-10",
    max = "2026-06-20",
    separator = " to ",
    class = "runtime-range-fixture"
  ),
  block_progress(
    "runtime_progress",
    value = 0.25,
    message = "Importing",
    show_value = TRUE,
    class = "runtime-progress-fixture"
  ),
  block_file_input(
    "runtime_file_input",
    accept = c(".txt", "text/plain"),
    button_label = "Upload fixture",
    placeholder = "No fixture selected",
    class = "runtime-file-input-fixture"
  ),
  block_file_input(
    "runtime_file_disabled",
    button_label = "Disabled upload",
    disabled = TRUE,
    class = "runtime-file-disabled-fixture"
  ),
  block_file_input(
    "runtime_file_dropzone",
    variant = "dropzone",
    accept = c(".txt", "text/plain"),
    dropzone_label = "Drop fixture",
    class = "runtime-file-dropzone-fixture"
  ),
  block_file_input(
    "runtime_file_dropzone_disabled",
    variant = "dropzone",
    disabled = TRUE,
    dropzone_label = "Disabled dropzone",
    class = "runtime-file-dropzone-disabled-fixture"
  ),
  block_file_input(
    "runtime_file_dropzone_custom",
    variant = "dropzone",
    accept = c(".txt", "text/plain"),
    dropzone_content = htmltools::tagList(
      htmltools::tags$strong("Upload your files"),
      htmltools::tags$button(
        id = "runtime_file_dropzone_custom_trigger",
        type = "button",
        class = "sb-file-dropzone-trigger",
        `data-dropzone-trigger` = NA,
        "Select files"
      )
    ),
    class = "runtime-file-dropzone-custom-fixture"
  ),
  block_table(
    data.frame(name = "alpha", value = 1, stringsAsFactors = FALSE),
    id = "runtime_table",
    class = "runtime-table-fixture"
  ),
  block_table(
    data.frame(name = c("one", "two"), value = c(1, 2), stringsAsFactors = FALSE),
    id = "runtime_table_sel",
    selection = "multiple",
    class = "runtime-table-sel-fixture"
  ),
  block_popover(
    id = "runtime_popover",
    trigger = "Open popover",
    side = "bottom",
    align = "center",
    htmltools::tags$p("Popover body"),
    htmltools::tags$button(
      id = "runtime_popover_inner",
      type = "button",
      "Inner action"
    )
  ),
  block_toaster("runtime_toaster", position = "bottom-right"),
  shiny::verbatimTextOutput("runtime_toaster_value"),
  shiny::actionButton("fire_toast", "Fire toast"),
  shiny::actionButton("dismiss_toasts", "Dismiss toasts"),
  shiny::actionButton("move_toaster", "Move toaster"),
  shiny::verbatimTextOutput("choice_value"),
  shiny::verbatimTextOutput("nested_value"),
  shiny::verbatimTextOutput("runtime_select_value"),
  shiny::verbatimTextOutput("runtime_multi_select_value"),
  shiny::verbatimTextOutput("runtime_multi_select_length"),
  shiny::verbatimTextOutput("runtime_checkbox_value"),
  shiny::verbatimTextOutput("runtime_switch_value"),
  shiny::verbatimTextOutput("runtime_slider_value"),
  shiny::verbatimTextOutput("runtime_button_value"),
  shiny::verbatimTextOutput("runtime_button_class"),
  shiny::verbatimTextOutput("runtime_date_value"),
  shiny::verbatimTextOutput("runtime_date_class"),
  shiny::verbatimTextOutput("runtime_range_value"),
  shiny::verbatimTextOutput("runtime_range_class"),
  shiny::verbatimTextOutput("runtime_range_length"),
  shiny::verbatimTextOutput("runtime_file_input_value"),
  shiny::verbatimTextOutput("runtime_file_dropzone_value"),
  shiny::verbatimTextOutput("runtime_file_dropzone_custom_value"),
  shiny::verbatimTextOutput("runtime_popover_value"),
  shiny::verbatimTextOutput("runtime_progress_value"),
  shiny::actionButton("set_progress_75", "Set progress 75"),
  shiny::actionButton("inc_progress", "Inc progress"),
  shiny::actionButton("reset_progress", "Reset progress"),
  shiny::actionButton("indeterminate_progress", "Indeterminate progress"),
  shiny::actionButton("insert_late_progress", "Insert + immediately update progress"),
  shiny::div(id = "late_progress_target"),
  shiny::verbatimTextOutput("runtime_table_sel_value"),
  shiny::actionButton("update_table", "Update table"),
  shiny::actionButton("shrink_select_table", "Shrink select table"),
  shiny::actionButton("set_select_pro", "Set select Pro"),
  shiny::actionButton("clear_select", "Clear select"),
  shiny::actionButton("disable_select", "Disable select"),
  shiny::actionButton("enable_select", "Enable select"),
  shiny::actionButton("set_multi_select", "Set multi select"),
  shiny::actionButton("clear_multi_select", "Clear multi select"),
  shiny::actionButton("disable_multi_select", "Disable multi select"),
  shiny::actionButton("enable_multi_select", "Enable multi select"),
  shiny::actionButton("update_multi_choices", "Update multi choices"),
  shiny::actionButton("set_switch_on", "Set switch on"),
  shiny::actionButton("set_switch_off", "Set switch off"),
  shiny::actionButton("disable_switch", "Disable switch"),
  shiny::actionButton("enable_switch", "Enable switch"),
  shiny::actionButton("set_slider_75", "Set slider 75"),
  shiny::actionButton("disable_slider", "Disable slider"),
  shiny::actionButton("enable_slider", "Enable slider"),
  shiny::actionButton("disable_button", "Disable button"),
  shiny::actionButton("enable_button", "Enable button"),
  shiny::actionButton("set_date", "Set date"),
  shiny::actionButton("clear_date", "Clear date"),
  shiny::actionButton("disable_date", "Disable date"),
  shiny::actionButton("enable_date", "Enable date"),
  shiny::actionButton("set_range", "Set range"),
  shiny::actionButton("clear_range", "Clear range"),
  shiny::actionButton("disable_range", "Disable range"),
  shiny::actionButton("enable_range", "Enable range"),
  shiny::actionButton("open_popover", "Open popover"),
  shiny::actionButton("close_popover", "Close popover"),
  shiny::actionButton("update_popover_body", "Update popover body"),
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
  output$nested_plot <- shiny::renderPlot({
    graphics::par(mar = c(1, 1, 1, 1))
    graphics::plot(1:3, 1:3, type = "b", xlab = "", ylab = "")
  })
  output$nested_table <- DT::renderDT(
    data.frame(label = "table-ready"),
    options = list(dom = "t"),
    rownames = FALSE
  )
  output$choice_value <- shiny::renderText(input$choice %||% "<NULL>")
  output$nested_value <- shiny::renderText(input$nested %||% "<NULL>")
  output$runtime_select_value <- shiny::renderText({
    value <- input$runtime_select
    if (is.null(value)) {
      return("<NULL>")
    }
    if (identical(value, "")) {
      return("<EMPTY>")
    }
    value
  })
  output$runtime_multi_select_value <- shiny::renderText({
    value <- input$runtime_multi_select
    if (is.null(value)) {
      return("<NULL>")
    }
    if (length(value) == 0) {
      return("<EMPTY>")
    }
    paste(value, collapse = ",")
  })
  output$runtime_multi_select_length <- shiny::renderText({
    as.character(length(input$runtime_multi_select))
  })
  output$runtime_checkbox_value <- shiny::renderText({
    value <- input$runtime_checkbox
    if (is.null(value)) {
      return("<NULL>")
    }
    if (isTRUE(value)) {
      return("TRUE")
    }
    "FALSE"
  })
  output$runtime_switch_value <- shiny::renderText({
    value <- input$runtime_switch
    if (is.null(value)) {
      return("<NULL>")
    }
    if (isTRUE(value)) {
      return("TRUE")
    }
    "FALSE"
  })
  output$runtime_slider_value <- shiny::renderText({
    value <- input$runtime_slider
    if (is.null(value)) {
      return("<NULL>")
    }
    paste(value, collapse = ",")
  })
  output$runtime_button_value <- shiny::renderText({
    value <- input$runtime_button
    if (is.null(value)) {
      return("<NULL>")
    }
    as.character(value)
  })
  output$runtime_button_class <- shiny::renderText({
    value <- input$runtime_button
    if (is.null(value)) {
      return("<NULL>")
    }
    paste(class(value), collapse = ",")
  })
  output$runtime_date_value <- shiny::renderText({
    value <- input$runtime_date
    if (is.null(value) || length(value) == 0) {
      return("<NULL>")
    }
    as.character(value)
  })
  output$runtime_date_class <- shiny::renderText({
    value <- input$runtime_date
    if (is.null(value) || length(value) == 0) {
      return("<NULL>")
    }
    paste(class(value), collapse = ",")
  })
  output$runtime_range_value <- shiny::renderText({
    value <- input$runtime_range
    if (is.null(value) || length(value) == 0) {
      return("<NULL>")
    }
    paste(as.character(value), collapse = "/")
  })
  output$runtime_range_class <- shiny::renderText({
    value <- input$runtime_range
    if (is.null(value) || length(value) == 0) {
      return("<NULL>")
    }
    paste(class(value), collapse = ",")
  })
  output$runtime_range_length <- shiny::renderText({
    value <- input$runtime_range
    as.character(length(value))
  })
  output$runtime_file_input_value <- shiny::renderText({
    value <- input$runtime_file_input
    if (is.null(value)) {
      return("<NULL>")
    }
    sprintf(
      "name=%s cols=%s rows=%s",
      paste(value$name, collapse = ","),
      paste(names(value), collapse = ","),
      nrow(value)
    )
  })
  output$runtime_file_dropzone_value <- shiny::renderText({
    value <- input$runtime_file_dropzone
    if (is.null(value)) {
      return("<NULL>")
    }
    sprintf(
      "name=%s cols=%s rows=%s",
      paste(value$name, collapse = ","),
      paste(names(value), collapse = ","),
      nrow(value)
    )
  })
  output$runtime_file_dropzone_custom_value <- shiny::renderText({
    value <- input$runtime_file_dropzone_custom
    if (is.null(value)) {
      return("<NULL>")
    }
    sprintf(
      "name=%s cols=%s rows=%s",
      paste(value$name, collapse = ","),
      paste(names(value), collapse = ","),
      nrow(value)
    )
  })
  output$runtime_popover_value <- shiny::renderText({
    value <- input$runtime_popover
    if (is.null(value)) {
      return("<NULL>")
    }
    if (isTRUE(value)) {
      return("TRUE")
    }
    "FALSE"
  })
  output$runtime_table_sel_value <- shiny::renderText({
    rows <- input$runtime_table_sel_rows_selected
    bare <- input$runtime_table_sel
    last <- input$runtime_table_sel_row_last_clicked
    sprintf(
      "rows=%s bare=%s last=%s",
      if (length(rows)) paste(rows, collapse = ",") else "-",
      if (length(bare)) paste(bare, collapse = ",") else "-",
      if (is.null(last)) "-" else as.character(last)
    )
  })
  output$runtime_toaster_value <- shiny::renderText({
    value <- input$runtime_toaster
    if (is.null(value)) {
      return("<NULL>")
    }
    sprintf(
      "%s:%s:%s",
      value$action %||% "",
      value$id %||% "-",
      value$seq %||% 0
    )
  })
  shiny::observeEvent(input$fire_toast, {
    show_toast(
      session,
      "runtime_toaster",
      title = "Saved",
      description = "All changes stored.",
      variant = "success",
      duration = 0,
      id = paste0("smoke-", input$fire_toast)
    )
  })
  shiny::observeEvent(input$dismiss_toasts, {
    dismiss_toast(session, "runtime_toaster")
  })
  shiny::observeEvent(input$move_toaster, {
    update_block_toaster(session, "runtime_toaster", position = "top-left")
  })

  output$dynamic_value <- shiny::renderText(input$dynamic %||% "<NULL>")
  output$inserted_value <- shiny::renderText(input$inserted %||% "<NULL>")

  shiny::observeEvent(input$update_table, {
    update_block_table(
      session = session,
      id = "runtime_table",
      data = data.frame(name = "beta", value = 2, stringsAsFactors = FALSE)
    )
  })

  # Pushes new data with fewer rows but deliberately omits `selected`, exercising
  # the runtime's stale-selection reconciliation: a previously selected row that
  # no longer exists must be dropped.
  shiny::observeEvent(input$shrink_select_table, {
    update_block_table(
      session = session,
      id = "runtime_table_sel",
      data = data.frame(name = "only", value = 9, stringsAsFactors = FALSE)
    )
  })

  shiny::observeEvent(input$set_select_pro, {
    update_block_select(
      session = session,
      input_id = "runtime_select",
      selected = "pro",
      notify = TRUE
    )
  })

  shiny::observeEvent(input$clear_select, {
    update_block_select(
      session = session,
      input_id = "runtime_select",
      selected = NULL,
      notify = TRUE
    )
  })

  shiny::observeEvent(input$disable_select, {
    update_block_select(
      session = session,
      input_id = "runtime_select",
      disabled = TRUE
    )
  })

  shiny::observeEvent(input$enable_select, {
    update_block_select(
      session = session,
      input_id = "runtime_select",
      disabled = FALSE
    )
  })

  shiny::observeEvent(input$set_multi_select, {
    update_block_select(
      session = session,
      input_id = "runtime_multi_select",
      selected = c("two", "three"),
      notify = TRUE
    )
  })

  shiny::observeEvent(input$clear_multi_select, {
    update_block_select(
      session = session,
      input_id = "runtime_multi_select",
      selected = character(0),
      notify = TRUE
    )
  })

  shiny::observeEvent(input$disable_multi_select, {
    update_block_select(
      session = session,
      input_id = "runtime_multi_select",
      disabled = TRUE
    )
  })

  shiny::observeEvent(input$enable_multi_select, {
    update_block_select(
      session = session,
      input_id = "runtime_multi_select",
      disabled = FALSE
    )
  })

  # Push new choices that drop a previously selected value ("three"), exercising
  # the multi-select stale-selection reconciliation: the surviving "two" stays,
  # the removed value is dropped from both chips and the reported vector.
  shiny::observeEvent(input$update_multi_choices, {
    update_block_select(
      session = session,
      input_id = "runtime_multi_select",
      choices = c(Two = "two", Four = "four", Five = "five")
    )
  })

  shiny::observeEvent(input$set_switch_on, {
    update_block_switch(
      session = session,
      input_id = "runtime_switch",
      checked = TRUE,
      notify = TRUE
    )
  })

  shiny::observeEvent(input$set_switch_off, {
    update_block_switch(
      session = session,
      input_id = "runtime_switch",
      checked = FALSE,
      notify = TRUE
    )
  })

  shiny::observeEvent(input$disable_switch, {
    update_block_switch(
      session = session,
      input_id = "runtime_switch",
      disabled = TRUE
    )
  })

  shiny::observeEvent(input$enable_switch, {
    update_block_switch(
      session = session,
      input_id = "runtime_switch",
      disabled = FALSE
    )
  })

  shiny::observeEvent(input$set_slider_75, {
    update_block_slider(
      session = session,
      input_id = "runtime_slider",
      value = 75,
      notify = TRUE
    )
  })

  shiny::observeEvent(input$disable_slider, {
    update_block_slider(
      session = session,
      input_id = "runtime_slider",
      disabled = TRUE
    )
  })

  shiny::observeEvent(input$enable_slider, {
    update_block_slider(
      session = session,
      input_id = "runtime_slider",
      disabled = FALSE
    )
  })

  shiny::observeEvent(input$disable_button, {
    update_block_button(
      session = session,
      input_id = "runtime_button",
      disabled = TRUE
    )
  })

  shiny::observeEvent(input$enable_button, {
    update_block_button(
      session = session,
      input_id = "runtime_button",
      disabled = FALSE
    )
  })

  shiny::observeEvent(input$set_date, {
    update_block_date_picker(
      session = session,
      input_id = "runtime_date",
      value = "2026-06-18",
      notify = TRUE
    )
  })

  shiny::observeEvent(input$clear_date, {
    update_block_date_picker(
      session = session,
      input_id = "runtime_date",
      clear = TRUE,
      notify = TRUE
    )
  })

  shiny::observeEvent(input$disable_date, {
    update_block_date_picker(
      session = session,
      input_id = "runtime_date",
      disabled = TRUE
    )
  })

  shiny::observeEvent(input$enable_date, {
    update_block_date_picker(
      session = session,
      input_id = "runtime_date",
      disabled = FALSE
    )
  })

  shiny::observeEvent(input$set_range, {
    update_block_date_range_picker(
      session = session,
      input_id = "runtime_range",
      start = "2026-06-13",
      end = "2026-06-17",
      notify = TRUE
    )
  })

  shiny::observeEvent(input$clear_range, {
    update_block_date_range_picker(
      session = session,
      input_id = "runtime_range",
      clear = TRUE,
      notify = TRUE
    )
  })

  shiny::observeEvent(input$disable_range, {
    update_block_date_range_picker(
      session = session,
      input_id = "runtime_range",
      disabled = TRUE
    )
  })

  shiny::observeEvent(input$enable_range, {
    update_block_date_range_picker(
      session = session,
      input_id = "runtime_range",
      disabled = FALSE
    )
  })

  shiny::observeEvent(input$open_popover, {
    update_block_popover(
      session = session,
      input_id = "runtime_popover",
      open = TRUE
    )
  })

  shiny::observeEvent(input$close_popover, {
    update_block_popover(
      session = session,
      input_id = "runtime_popover",
      open = FALSE
    )
  })

  shiny::observeEvent(input$update_popover_body, {
    update_block_popover(
      session = session,
      input_id = "runtime_popover",
      open = TRUE,
      body = htmltools::tags$p("Updated from server")
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
      component = "fixture", .validate = FALSE,
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
          component = "fixture", .validate = FALSE,
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

  # Progress is receive-only: `input$runtime_progress` should stay NULL even as
  # the server drives the bar.
  output$runtime_progress_value <- shiny::renderText(input$runtime_progress %||% "<NULL>")
  shiny::observeEvent(input$set_progress_75, {
    update_block_progress(session, "runtime_progress", value = 0.75, message = "Three quarters")
  })
  shiny::observeEvent(input$inc_progress, {
    inc_block_progress(session, "runtime_progress", amount = 0.1)
  })
  shiny::observeEvent(input$reset_progress, {
    update_block_progress(session, "runtime_progress", value = 0, message = NULL)
  })
  shiny::observeEvent(input$indeterminate_progress, {
    update_block_progress(session, "runtime_progress", indeterminate = TRUE)
  })

  # Race regression: insert a fresh progress bar and, in the SAME flush, send an
  # update before the React mount effect can install `__sbProgressReceive`. The
  # binding's queued fallback must drain the message so the bar lands at 60%
  # instead of silently dropping it.
  shiny::observeEvent(input$insert_late_progress, {
    shiny::insertUI(
      selector = "#late_progress_target",
      where = "beforeEnd",
      ui = shiny::div(
        id = "late_progress_host",
        block_progress(
          "late_progress",
          value = 0,
          show_value = TRUE,
          class = "runtime-late-progress-fixture"
        )
      ),
      immediate = TRUE
    )
    update_block_progress(session, "late_progress", value = 0.6, message = "Late update")
  })

  output$inserted_child <- shiny::renderText("inserted-child-ready")

  shiny::moduleServer("mod", function(input, output, session) {
    output$value <- shiny::renderText(input$choice %||% "<NULL>")
    output$upload_value <- shiny::renderText({
      value <- input$upload
      if (is.null(value)) {
        return("<NULL>")
      }
      paste(value$name, collapse = ",")
    })
    output$date_value <- shiny::renderText({
      value <- input$date
      if (is.null(value) || length(value) == 0) {
        return("<NULL>")
      }
      as.character(value)
    })
    output$progress_value <- shiny::renderText(input$progress %||% "<NULL>")

    # Server-driven update from inside the module: routes via the root session
    # so the ns-baked mount target is not double-namespaced (issue #63).
    shiny::observeEvent(input$set_progress_60, {
      update_block_progress(session, "progress", value = 0.6)
    })
  })
}

shiny::runApp(
  shiny::shinyApp(ui = ui, server = server),
  host = "127.0.0.1",
  port = port,
  launch.browser = FALSE
)

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

# A minimal module that exposes a task button under a *local* id of "task". Two
# instances mounted with different module ids ("tbmodA", "tbmodB") therefore
# share the same local id while staying independent — the isolation case the
# session-local manual-reset map must satisfy.
task_module_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::div(
    id = ns("task_root"),
    block_task_button(
      ns("task"),
      "Module run",
      label_busy = "Module busy",
      auto_reset = FALSE
    ),
    shiny::verbatimTextOutput(ns("task_value"))
  )
}

task_module_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    output$task_value <- shiny::renderText(input$task %||% "<NULL>")
  })
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
  block_value_box(
    title = "Slot value",
    value = shiny::textOutput("runtime_slot_value", inline = TRUE),
    description = "Rendered through a runtime HTML slot",
    icon = "hash",
    class = "runtime-slot-value-fixture"
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
  block_combobox(
    "runtime_combobox",
    choices = c(Apple = "apple", Apricot = "apricot", Banana = "banana", Cherry = "cherry"),
    selected = "apple",
    placeholder = "Choose fruit",
    class = "runtime-combobox-fixture"
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
  block_toggle_group(
    "runtime_toggle",
    choices = c(List = "list", Grid = "grid", Board = "board"),
    selected = "list",
    class = "runtime-toggle-fixture"
  ),
  block_toggle_group(
    "runtime_toggle_multi",
    choices = c(Bold = "bold", Italic = "italic", Underline = "underline"),
    selected = "bold",
    type = "multiple",
    variant = "outline",
    disabled = "underline",
    class = "runtime-toggle-multi-fixture"
  ),
  block_button(
    "Runtime button",
    id = "runtime_button",
    class = "runtime-button-fixture"
  ),
  block_task_button(
    "runtime_task_button",
    "Run task",
    # ASCII label keeps the assertion locale-independent (the smoke spawns
    # Rscript without forcing a UTF-8 locale).
    label_busy = "Working",
    class = "runtime-task-button-fixture",
    # Author passthrough: `title` must reach the button; the reserved
    # `data-slot` / `type` must NOT override the runtime's own values; and
    # `aria-labelledby` must be suppressed while busy and restored when ready.
    title = "Run the task",
    `aria-labelledby` = "tb_extlabel",
    `data-slot` = "author-should-not-win",
    type = "submit"
  ),
  shiny::span(id = "tb_extlabel", "External label"),
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
    htmltools::tags$p(shiny::textOutput("runtime_popover_slot_value", inline = TRUE)),
    htmltools::tags$button(
      id = "runtime_popover_inner",
      type = "button",
      "Inner action"
    )
  ),
  block_dropdown_menu(
    "Open dropdown",
    id = "runtime_dropdown_menu",
    dropdown_menu_label("Account"),
    dropdown_menu_item("profile", "Profile"),
    dropdown_menu_item("billing", "Billing", disabled = TRUE),
    dropdown_menu_separator(),
    dropdown_menu_item("logout", "Log out", variant = "destructive")
  ),
  shiny::verbatimTextOutput("runtime_dropdown_menu_value"),
  shiny::actionButton("open_dropdown_menu", "Open dropdown (server)"),
  shiny::actionButton("replace_dropdown_menu", "Replace dropdown items"),
  block_toaster("runtime_toaster", position = "bottom-right"),
  shiny::verbatimTextOutput("runtime_toaster_value"),
  shiny::actionButton("fire_toast", "Fire toast"),
  shiny::actionButton("dismiss_toasts", "Dismiss toasts"),
  shiny::actionButton("move_toaster", "Move toaster"),
  shiny::verbatimTextOutput("choice_value"),
  shiny::verbatimTextOutput("nested_value"),
  shiny::verbatimTextOutput("runtime_select_value"),
  shiny::verbatimTextOutput("runtime_combobox_value"),
  shiny::verbatimTextOutput("runtime_multi_select_value"),
  shiny::verbatimTextOutput("runtime_multi_select_length"),
  shiny::verbatimTextOutput("runtime_checkbox_value"),
  shiny::verbatimTextOutput("runtime_switch_value"),
  shiny::verbatimTextOutput("runtime_slider_value"),
  shiny::verbatimTextOutput("runtime_toggle_value"),
  shiny::verbatimTextOutput("runtime_toggle_multi_value"),
  shiny::verbatimTextOutput("runtime_button_value"),
  shiny::verbatimTextOutput("runtime_button_class"),
  shiny::verbatimTextOutput("runtime_task_button_value"),
  shiny::verbatimTextOutput("runtime_task_button_class"),
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
  shiny::actionButton("set_select_vector", "Set select vector"),
  shiny::actionButton("clear_select", "Clear select"),
  shiny::actionButton("disable_select", "Disable select"),
  shiny::actionButton("enable_select", "Enable select"),
  shiny::actionButton("set_combobox_cherry", "Set combobox Cherry"),
  shiny::actionButton("disable_combobox", "Disable combobox"),
  shiny::actionButton("enable_combobox", "Enable combobox"),
  shiny::actionButton("set_multi_select", "Set multi select"),
  shiny::actionButton("clear_multi_select", "Clear multi select"),
  shiny::actionButton("disable_multi_select", "Disable multi select"),
  shiny::actionButton("enable_multi_select", "Enable multi select"),
  shiny::actionButton("update_multi_choices", "Update multi choices"),
  shiny::actionButton("overflow_multi_select", "Overflow multi select"),
  shiny::actionButton("set_switch_on", "Set switch on"),
  shiny::actionButton("set_switch_off", "Set switch off"),
  shiny::actionButton("disable_switch", "Disable switch"),
  shiny::actionButton("enable_switch", "Enable switch"),
  shiny::actionButton("set_slider_75", "Set slider 75"),
  shiny::actionButton("set_toggle_grid", "Set toggle grid"),
  shiny::actionButton("clear_toggle", "Clear toggle"),
  shiny::actionButton("disable_toggle", "Disable toggle"),
  shiny::actionButton("enable_toggle", "Enable toggle"),
  shiny::actionButton("set_toggle_multi", "Set toggle multi"),
  shiny::actionButton("swap_toggle_choices", "Swap toggle choices"),
  shiny::actionButton("disable_slider", "Disable slider"),
  shiny::actionButton("enable_slider", "Enable slider"),
  shiny::actionButton("disable_button", "Disable button"),
  shiny::actionButton("enable_button", "Enable button"),
  shiny::actionButton("tb_hold_on", "Hold task busy on click"),
  shiny::actionButton("tb_hold_off", "Stop holding task busy"),
  shiny::actionButton("tb_ready", "Release task"),
  shiny::actionButton("tb_disable", "Disable task"),
  shiny::actionButton("tb_enable", "Enable task"),
  shiny::actionButton("tb_combined", "Busy + enable (combined)"),
  shiny::actionButton("tb_busy_icon", "Set busy icon"),
  shiny::actionButton("tb_icon_end", "Busy icon inline-end"),
  shiny::actionButton("tb_icon_start", "Busy icon inline-start"),
  shiny::actionButton("tb_set_label", "Set task label"),
  shiny::actionButton("tb_set_variant", "Set task variant"),
  shiny::actionButton("tb_set_size", "Set task size"),
  shiny::actionButton("tb_set_icon", "Set task ready icon"),
  shiny::actionButton("tb_set_style", "Set task style"),
  shiny::actionButton("tb_set_class", "Set task class"),
  shiny::actionButton("tb_set_label_busy", "Set task busy label"),
  shiny::actionButton("tb_clear_icon", "Clear task ready icon"),
  shiny::actionButton("tb_clear_icon_busy", "Clear task busy icon"),
  shiny::actionButton("tb_clear_style", "Clear task style"),
  shiny::actionButton("tb_clear_class", "Clear task class"),
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
  shiny::actionButton("toggle_task_dynamic", "Toggle dynamic task"),
  shiny::uiOutput("task_dynamic_mount"),
  shiny::verbatimTextOutput("task_dynamic_value"),
  shiny::actionButton("insert_task", "Insert task button"),
  shiny::actionButton("remove_task", "Remove task button"),
  shiny::div(id = "task_insert_target"),
  shiny::verbatimTextOutput("task_inserted_value"),
  shiny::actionButton("toggle_ar_task", "Toggle auto-reset task"),
  shiny::uiOutput("ar_task_mount"),
  shiny::verbatimTextOutput("ar_task_value"),
  shiny::actionButton("ar_task_busy", "Manual busy AR task"),
  module_ui("mod"),
  task_module_ui("tbmodA"),
  task_module_ui("tbmodB")
)

server <- function(input, output, session) {
  output$child_text <- shiny::renderText("child-ready")
  output$runtime_slot_value <- shiny::renderText("slot-ready")
  output$runtime_popover_slot_value <- shiny::renderText("popover-slot-ready")
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
  output$runtime_combobox_value <- shiny::renderText({
    value <- input$runtime_combobox
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
  output$runtime_toggle_value <- shiny::renderText({
    value <- input$runtime_toggle
    if (is.null(value)) {
      return("<NULL>")
    }
    paste(value, collapse = ",")
  })
  output$runtime_toggle_multi_value <- shiny::renderText({
    value <- input$runtime_toggle_multi
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
  output$runtime_task_button_value <- shiny::renderText({
    value <- input$runtime_task_button
    if (is.null(value)) {
      return("<NULL>")
    }
    as.character(value)
  })
  output$runtime_task_button_class <- shiny::renderText({
    value <- input$runtime_task_button
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
  output$runtime_dropdown_menu_value <- shiny::renderText({
    value <- input$runtime_dropdown_menu
    if (is.null(value)) "<NULL>" else as.character(value)
  })
  shiny::observeEvent(input$open_dropdown_menu, {
    update_block_dropdown_menu(session, "runtime_dropdown_menu", open = TRUE)
  })
  shiny::observeEvent(input$replace_dropdown_menu, {
    update_block_dropdown_menu(
      session,
      "runtime_dropdown_menu",
      items = list(
        dropdown_menu_item("invite", "Invite members"),
        dropdown_menu_item("new_team", "New team")
      )
    )
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

  shiny::observeEvent(input$set_combobox_cherry, {
    update_block_combobox(
      session = session,
      input_id = "runtime_combobox",
      selected = "cherry",
      notify = TRUE
    )
  })

  shiny::observeEvent(input$disable_combobox, {
    update_block_combobox(
      session = session,
      input_id = "runtime_combobox",
      disabled = TRUE
    )
  })

  shiny::observeEvent(input$enable_combobox, {
    update_block_combobox(
      session = session,
      input_id = "runtime_combobox",
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

  # Defensive coercion: a vector `selected` reaching the single select collapses
  # to its first element instead of stringifying to "free,pro".
  shiny::observeEvent(input$set_select_vector, {
    update_block_select(
      session = session,
      input_id = "runtime_select",
      selected = c("free", "pro"),
      notify = TRUE
    )
  })

  # Server overflow: send more values than `max_items` (2) — the runtime clamps
  # to the leading two (choice order) rather than exceeding the visible cap.
  # Uses the post-`update_multi_choices` set (two/four/five) so the smoke can run
  # it after that step without reintroducing dropped choices.
  shiny::observeEvent(input$overflow_multi_select, {
    update_block_select(
      session = session,
      input_id = "runtime_multi_select",
      selected = c("two", "four", "five"),
      notify = TRUE
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

  shiny::observeEvent(input$set_toggle_grid, {
    update_block_toggle_group(
      session = session,
      input_id = "runtime_toggle",
      selected = "grid",
      notify = TRUE
    )
  })

  shiny::observeEvent(input$clear_toggle, {
    update_block_toggle_group(
      session = session,
      input_id = "runtime_toggle",
      selected = NULL,
      notify = TRUE
    )
  })

  shiny::observeEvent(input$disable_toggle, {
    update_block_toggle_group(
      session = session,
      input_id = "runtime_toggle",
      disabled = TRUE
    )
  })

  shiny::observeEvent(input$enable_toggle, {
    update_block_toggle_group(
      session = session,
      input_id = "runtime_toggle",
      disabled = FALSE
    )
  })

  shiny::observeEvent(input$set_toggle_multi, {
    update_block_toggle_group(
      session = session,
      input_id = "runtime_toggle_multi",
      selected = c("bold", "italic"),
      notify = TRUE
    )
  })

  shiny::observeEvent(input$swap_toggle_choices, {
    update_block_toggle_group(
      session = session,
      input_id = "runtime_toggle",
      choices = c(Day = "day", Week = "week"),
      selected = "week",
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

  tb_hold <- shiny::reactiveVal(FALSE)
  shiny::observeEvent(input$tb_hold_on, tb_hold(TRUE))
  shiny::observeEvent(input$tb_hold_off, tb_hold(FALSE))

  # Manual-suppression race: while "hold" is on, the click's reactive flush sets
  # the task busy. Because that runs before the auto-reset onFlush callback, the
  # manual-reset map suppresses the automatic ready reset and the button stays
  # busy until released.
  shiny::observeEvent(input$runtime_task_button, {
    if (isTRUE(tb_hold())) {
      update_block_task_button(
        session = session,
        input_id = "runtime_task_button",
        state = "busy"
      )
    }
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$tb_ready, {
    update_block_task_button(
      session = session,
      input_id = "runtime_task_button",
      state = "ready"
    )
  })

  shiny::observeEvent(input$tb_disable, {
    update_block_task_button(
      session = session,
      input_id = "runtime_task_button",
      disabled = TRUE
    )
  })

  shiny::observeEvent(input$tb_enable, {
    update_block_task_button(
      session = session,
      input_id = "runtime_task_button",
      disabled = FALSE
    )
  })

  # Combined update: busy must win even though disabled = FALSE is also sent, and
  # the merged next state must be computed before the DOM is touched (no stale
  # field-by-field re-enable).
  shiny::observeEvent(input$tb_combined, {
    update_block_task_button(
      session = session,
      input_id = "runtime_task_button",
      state = "busy",
      disabled = FALSE
    )
  })

  shiny::observeEvent(input$tb_busy_icon, {
    update_block_task_button(
      session = session,
      input_id = "runtime_task_button",
      icon_busy = "check"
    )
  })

  shiny::observeEvent(input$tb_icon_end, {
    update_block_task_button(
      session = session,
      input_id = "runtime_task_button",
      icon_position = "inline-end"
    )
  })

  shiny::observeEvent(input$tb_icon_start, {
    update_block_task_button(
      session = session,
      input_id = "runtime_task_button",
      icon_position = "inline-start"
    )
  })

  # Full update coverage: label, variant, size, ready icon, style, and class all
  # reach the runtime through update_block_task_button().
  shiny::observeEvent(input$tb_set_label, {
    update_block_task_button(session, "runtime_task_button", label = "Relabeled")
  })
  shiny::observeEvent(input$tb_set_variant, {
    update_block_task_button(session, "runtime_task_button", variant = "secondary")
  })
  shiny::observeEvent(input$tb_set_size, {
    update_block_task_button(session, "runtime_task_button", size = "lg")
  })
  shiny::observeEvent(input$tb_set_icon, {
    update_block_task_button(session, "runtime_task_button", icon = "check")
  })
  shiny::observeEvent(input$tb_set_style, {
    update_block_task_button(session, "runtime_task_button", style = "min-width: 22rem;")
  })
  shiny::observeEvent(input$tb_set_class, {
    update_block_task_button(session, "runtime_task_button", class = "tb-updated-class")
  })
  shiny::observeEvent(input$tb_set_label_busy, {
    update_block_task_button(session, "runtime_task_button", label_busy = "New busy label")
  })
  # Clear semantics: NULL clears the ready icon, busy icon (back to the spinner),
  # style, and class.
  shiny::observeEvent(input$tb_clear_icon, {
    update_block_task_button(session, "runtime_task_button", icon = NULL)
  })
  shiny::observeEvent(input$tb_clear_icon_busy, {
    update_block_task_button(session, "runtime_task_button", icon_busy = NULL)
  })
  shiny::observeEvent(input$tb_clear_style, {
    update_block_task_button(session, "runtime_task_button", style = NULL)
  })
  shiny::observeEvent(input$tb_clear_class, {
    update_block_task_button(session, "runtime_task_button", class = NULL)
  })

  # Dynamic remount + rebind: a renderUI mount that toggles on/off. After a
  # remount the fresh binding must report clicks and re-install the synchronous
  # lock. auto_reset = FALSE so a click stays busy and is observable.
  task_dynamic_visible <- shiny::reactiveVal(FALSE)
  shiny::observeEvent(input$toggle_task_dynamic, {
    task_dynamic_visible(!isTRUE(task_dynamic_visible()))
  })
  output$task_dynamic_mount <- shiny::renderUI({
    if (!isTRUE(task_dynamic_visible())) {
      return(NULL)
    }
    block_task_button(
      "dyn_task",
      "Dynamic run",
      label_busy = "Dynamic busy",
      auto_reset = FALSE
    )
  })
  output$task_dynamic_value <- shiny::renderText(input$dyn_task %||% "<NULL>")

  # insertUI / removeUI lifecycle: a task button inserted into a target, then
  # removed and reinserted. Each insertion must rebind so clicks report and the
  # synchronous lock re-installs. auto_reset = FALSE so a click stays busy.
  shiny::observeEvent(input$insert_task, {
    shiny::insertUI(
      selector = "#task_insert_target",
      where = "beforeEnd",
      ui = shiny::div(
        id = "task_inserted_host",
        block_task_button(
          "inserted_task",
          "Inserted run",
          label_busy = "Inserted busy",
          auto_reset = FALSE
        )
      ),
      immediate = TRUE
    )
  })
  shiny::observeEvent(input$remove_task, {
    shiny::removeUI(selector = "#task_inserted_host", immediate = TRUE)
  })
  output$task_inserted_value <- shiny::renderText(input$inserted_task %||% "<NULL>")

  # Regression (#69 review): stale manual state must not survive a remount. An
  # auto_reset = TRUE button is set to manual busy, removed, then recreated with
  # the same id. The fresh instance must auto-reset on click — the input handler
  # clears the stale manual flag when the new instance reports its initial value.
  ar_task_visible <- shiny::reactiveVal(FALSE)
  shiny::observeEvent(input$toggle_ar_task, {
    ar_task_visible(!isTRUE(ar_task_visible()))
  })
  output$ar_task_mount <- shiny::renderUI({
    if (!isTRUE(ar_task_visible())) {
      return(NULL)
    }
    block_task_button(
      "ar_task",
      "AR run",
      label_busy = "AR busy",
      auto_reset = TRUE
    )
  })
  output$ar_task_value <- shiny::renderText(input$ar_task %||% "<NULL>")
  shiny::observeEvent(input$ar_task_busy, {
    update_block_task_button(session, "ar_task", state = "busy")
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

  # Two task-button modules sharing the local id "task": clicks and busy state
  # must stay independent across the namespaced sessions.
  task_module_server("tbmodA")
  task_module_server("tbmodB")
}

shiny::runApp(
  shiny::shinyApp(ui = ui, server = server),
  host = "127.0.0.1",
  port = port,
  launch.browser = FALSE
)

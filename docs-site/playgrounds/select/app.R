if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)
  webr::mount("/packages", "library.data.gz")
  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
library(shinyblocks)

`%||%` <- function(a, b) if (is.null(a)) b else a

showcase_render_code <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    value <- eval(quoted, envir = env)
    if (is.null(value) || !length(value)) value <- ""
    block_code(
      code = paste(as.character(value), collapse = "\n"),
      language = "r",
      copyable = TRUE,
      line_numbers = TRUE
    )
  })
}

showcase_action_button <- function(input_id, label) {
  actionButton(
    input_id,
    label,
    class = "showcase-action-button showcase-action-button-outline showcase-action-button-size-sm action-button"
  )
}

ui <- block_page(
  title = "shinyblocks · Select playground",
  block_body(
    htmltools::tags$div(
      style = "padding: 1.5rem; max-width: 1200px; margin: 0 auto;",
      htmltools::tagList(
        block_field_set(
          block_field_legend("Interactive Playground"),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1.5rem;",
            htmltools::div(
              style = "display: flex; gap: 2rem; flex-wrap: wrap; align-items: flex-start;",
              htmltools::div(
                style = "flex: 1; min-width: 300px; display: flex; flex-direction: column; gap: 1.5rem;",
                block_field(
                  block_field_label("Preview", `for` = "showcase_select_preview"),
                  uiOutput("showcase_select_preview_ui")
                ),
                uiOutput("showcase_select_preview_value"),
                htmltools::tags$div(
                  style = "display: flex; flex-direction: column; gap: 1rem;",
                  htmltools::tags$div(
                    htmltools::tags$div(
                      style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
                      "UI Definition"
                    ),
                    uiOutput("showcase_select_preview_code")
                  ),
                  htmltools::tags$div(
                    htmltools::tags$div(
                      style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
                      "Server Action"
                    ),
                    uiOutput("showcase_select_reactive_code")
                  )
                )
              ),
              htmltools::div(
                style = paste(
                  "flex: 2; display: grid;",
                  "grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));",
                  "gap: 1.5rem; background: var(--muted); padding: 1.5rem;",
                  "border-radius: 0.5rem;"
                ),
                htmltools::div(
                  style = "display: flex; flex-direction: column; gap: 1rem;",
                  htmltools::tags$h3(
                    style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);",
                    "Content"
                  ),
                  block_field(
                    block_field_label("choices", `for` = "showcase_select_doc_choices"),
                    block_select(
                      "showcase_select_doc_choices",
                      choices = c("Plans" = "plans", "Frameworks" = "frameworks", "Fruits" = "fruits"),
                      selected = "plans"
                    )
                  ),
                  block_field(
                    block_field_label("selected", `for` = "showcase_select_doc_selected"),
                    block_select(
                      "showcase_select_doc_selected",
                      choices = c(Free = "free", Pro = "pro", Team = "team"),
                      selected = "free"
                    )
                  ),
                  block_field(
                    block_field_label("placeholder", `for` = "showcase_select_doc_placeholder"),
                    block_textarea("showcase_select_doc_placeholder", value = "Choose a plan", rows = 1)
                  )
                ),
                htmltools::div(
                  style = "display: flex; flex-direction: column; gap: 2rem;",
                  htmltools::div(
                    style = "display: flex; flex-direction: column; gap: 1rem;",
                    htmltools::tags$h3(
                      style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);",
                      "State"
                    ),
                    block_field(
                      block_field_label("disabled", `for` = "showcase_select_doc_disabled"),
                      block_checkbox("showcase_select_doc_disabled", "Disabled", value = FALSE)
                    ),
                    block_field(
                      block_field_label("invalid", `for` = "showcase_select_doc_invalid"),
                      block_checkbox("showcase_select_doc_invalid", "Invalid", value = FALSE)
                    )
                  ),
                  htmltools::div(
                    style = "display: flex; flex-direction: column; gap: 1rem;",
                    htmltools::tags$h3(
                      style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);",
                      "Actions (Server Update)"
                    ),
                    htmltools::div(
                      style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
                      showcase_action_button("showcase_select_set_pro", "Set Pro"),
                      showcase_action_button("showcase_select_clear", "Clear"),
                      showcase_action_button("showcase_select_disable", "Disable"),
                      showcase_action_button("showcase_select_enable", "Enable"),
                      showcase_action_button("showcase_select_replace_choices", "Replace choices")
                    )
                  )
                ),
                htmltools::div(
                  style = "display: flex; flex-direction: column; gap: 1rem;",
                  htmltools::tags$h3(
                    style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);",
                    "Styling"
                  ),
                  block_field(
                    block_field_label("size", `for` = "showcase_select_doc_size"),
                    block_select(
                      "showcase_select_doc_size",
                      choices = c("default", "sm", "lg"),
                      selected = "default"
                    )
                  ),
                  block_field(
                    block_field_label("width", `for` = "showcase_select_doc_width"),
                    block_textarea("showcase_select_doc_width", value = "100%", rows = 1)
                  ),
                  block_field(
                    block_field_label("style", `for` = "showcase_select_doc_style"),
                    block_textarea(
                      "showcase_select_doc_style",
                      value = "",
                      rows = 1,
                      placeholder = "e.g., border: 2px dashed red;"
                    )
                  ),
                  block_field(
                    block_field_label("class", `for` = "showcase_select_doc_class"),
                    block_checkbox(
                      "showcase_select_doc_class",
                      "Use custom dashed-border class",
                      value = FALSE
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  select_doc_choices <- function(key) {
    switch(
      key %||% "plans",
      frameworks = c(React = "react", Vue = "vue", Svelte = "svelte", Angular = "angular"),
      fruits = c(Apple = "apple", Banana = "banana", Blueberry = "blueberry", Grapes = "grapes"),
      c(Free = "free", Pro = "pro", Team = "team")
    )
  }

  output$showcase_select_preview_value <- showcase_render_code({
    value <- input$showcase_select_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (identical(value, "")) {
      "<EMPTY>"
    } else {
      paste0('"', value, '"')
    }
    paste0("input$showcase_select_preview = ", val_str)
  })
  outputOptions(output, "showcase_select_preview_value", suspendWhenHidden = FALSE)

  observeEvent(input$showcase_select_doc_choices, {
    choices <- select_doc_choices(input$showcase_select_doc_choices)
    update_block_select(
      session,
      "showcase_select_doc_selected",
      choices = choices,
      selected = unname(choices[[1]])
    )
  }, ignoreInit = TRUE)

  observeEvent(input$showcase_select_doc_class, {
    update_block_select(
      session,
      "showcase_select_preview",
      class = if (isTRUE(input$showcase_select_doc_class)) "showcase-select-preview-custom" else NULL
    )
  }, ignoreInit = TRUE)

  output$showcase_select_preview_ui <- renderUI({
    choices <- select_doc_choices(input$showcase_select_doc_choices)
    selected <- input$showcase_select_doc_selected
    if (identical(selected, "")) {
      selected <- NULL
    } else if (is.null(selected) || !selected %in% unname(choices)) {
      selected <- unname(choices[[1]])
    }

    placeholder <- input$showcase_select_doc_placeholder %||% ""
    if (!nzchar(placeholder)) placeholder <- NULL

    width <- input$showcase_select_doc_width %||% "100%"
    if (!nzchar(width)) width <- "100%"

    style <- input$showcase_select_doc_style %||% ""
    if (!nzchar(style)) style <- NULL

    block_select(
      input_id = "showcase_select_preview",
      choices = choices,
      selected = selected,
      placeholder = placeholder,
      disabled = isTRUE(input$showcase_select_doc_disabled),
      width = width,
      style = style,
      class = if (isTRUE(input$showcase_select_doc_class)) "showcase-select-preview-custom" else NULL,
      size = input$showcase_select_doc_size %||% "default",
      invalid = isTRUE(input$showcase_select_doc_invalid)
    )
  })
  outputOptions(output, "showcase_select_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_select_preview_code <- showcase_render_code({
    choices_val <- input$showcase_select_doc_choices %||% "plans"
    choices_str <- switch(
      choices_val,
      frameworks = 'c(React = "react", Vue = "vue", Svelte = "svelte", Angular = "angular")',
      fruits = 'c(Apple = "apple", Banana = "banana", Blueberry = "blueberry", Grapes = "grapes")',
      'c(Free = "free", Pro = "pro", Team = "team")'
    )

    selected_val <- input$showcase_select_doc_selected
    placeholder_val <- input$showcase_select_doc_placeholder
    width_val <- input$showcase_select_doc_width
    style_val <- input$showcase_select_doc_style
    class_val <- input$showcase_select_doc_class
    size_val <- input$showcase_select_doc_size
    disabled_val <- input$showcase_select_doc_disabled
    invalid_val <- input$showcase_select_doc_invalid

    args <- c(
      'input_id = "showcase_select_preview"',
      paste0("choices = ", choices_str)
    )
    if (!is.null(selected_val) && selected_val != "") {
      args <- c(args, paste0('selected = "', selected_val, '"'))
    }
    if (!is.null(placeholder_val) && nzchar(placeholder_val)) {
      args <- c(args, paste0('placeholder = "', placeholder_val, '"'))
    }
    if (isTRUE(disabled_val)) args <- c(args, "disabled = TRUE")
    if (!is.null(width_val) && nzchar(width_val) && width_val != "100%") {
      args <- c(args, paste0('width = "', width_val, '"'))
    }
    if (!is.null(style_val) && nzchar(style_val)) {
      args <- c(args, paste0('style = "', style_val, '"'))
    }
    if (isTRUE(class_val)) args <- c(args, 'class = "showcase-select-preview-custom"')
    if (!is.null(size_val) && size_val != "default") {
      args <- c(args, paste0('size = "', size_val, '"'))
    }
    if (isTRUE(invalid_val)) args <- c(args, "invalid = TRUE")

    paste0("block_select(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_select_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_select() code here."
  ))
  output$showcase_select_reactive_code <- showcase_render_code({ reactive_code() })
  outputOptions(output, "showcase_select_reactive_code", suspendWhenHidden = FALSE)

  observeEvent(input$showcase_select_set_pro, {
    update_block_select(session, "showcase_select_preview", selected = "pro")
    reactive_code('update_block_select(\n  session = session,\n  input_id = "showcase_select_preview",\n  selected = "pro"\n)')
  })
  observeEvent(input$showcase_select_clear, {
    update_block_select(session, "showcase_select_preview", selected = NULL)
    reactive_code('update_block_select(\n  session = session,\n  input_id = "showcase_select_preview",\n  selected = NULL\n)')
  })
  observeEvent(input$showcase_select_disable, {
    update_block_select(session, "showcase_select_preview", disabled = TRUE)
    reactive_code('update_block_select(\n  session = session,\n  input_id = "showcase_select_preview",\n  disabled = TRUE\n)')
  })
  observeEvent(input$showcase_select_enable, {
    update_block_select(session, "showcase_select_preview", disabled = FALSE)
    reactive_code('update_block_select(\n  session = session,\n  input_id = "showcase_select_preview",\n  disabled = FALSE\n)')
  })
  observeEvent(input$showcase_select_replace_choices, {
    update_block_select(
      session,
      "showcase_select_preview",
      choices = c(Starter = "starter", Growth = "growth", Scale = "scale"),
      selected = "growth",
      placeholder = "Choose a package",
      disabled = FALSE
    )
    reactive_code('update_block_select(\n  session = session,\n  input_id = "showcase_select_preview",\n  choices = c(Starter = "starter", Growth = "growth", Scale = "scale"),\n  selected = "growth",\n  placeholder = "Choose a package",\n  disabled = FALSE\n)')
  })
}

shinyApp(ui, server)

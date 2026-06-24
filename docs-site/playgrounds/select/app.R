if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)
  
  # Try mounting from relative paths. In some environments (e.g. standard workers),
  # paths resolve relative to the worker script context. In others (e.g. blob workers/proxied environments),
  # they resolve relative to the main document base URL. We try both to be fully resilient.
  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch({
      webr::mount("/packages", path)
      if ("shinyblocks" %in% installed.packages(lib.loc = "/packages")[, "Package"]) {
        mounted <- TRUE
        break
      }
    }, error = function(e) {
      # Ignore and try the next path
    })
  }
  
  if (!mounted) {
    # If both relative paths fail, try absolute path as a last resort fallback
    # (works on the default nvelden.github.io/shinyblocks deployment)
    tryCatch({
      webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
    }, error = function(e) {
      stop("Failed to mount shinyblocks WASM package library: ", e$message)
    })
  }
  
  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
do.call(library, list("shinyblocks", character.only = TRUE))

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

showcase_render_value <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    value <- eval(quoted, envir = env)
    htmltools::tags$pre(
      class = "sb-code-block sb-code-block-default",
      style = "margin: 0; padding: 0.75rem 1rem; font-size: 0.8125rem;",
      htmltools::tags$code(paste(as.character(value), collapse = "\n"))
    )
  })
}

showcase_action_button <- function(input_id, label) {
  block_button(
    label,
    id = input_id,
    variant = "outline",
    size = "sm"
  )
}

ui <- block_page(
  title = "shinyblocks · Select playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      "
      [data-shinyblocks-root] .showcase-select-preview-custom .sb-select-trigger,
      [data-shinyblocks-root].showcase-select-preview-custom .sb-select-trigger {
        border: 2px dashed red;
      }
      "
    ))
  ),
  htmltools::tags$div(
      `data-shinyblocks-root` = "",
      style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
      htmltools::div(
        class = "showcase-playground",
    block_cluster(
      gap = "lg",
      align = "start",
      class = "showcase-playground__split",
        
        # Left Column: Controls Panel
        block_card(
                  title = "Controls",
                  class = "showcase-playground__controls",
# Content Controls Group
          block_stack(
            gap = "sm",
            class = "showcase-controls-group showcase-controls-group--first",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Content"),
            block_field(
              block_field_label("choices", `for` = "showcase_select_doc_choices"),
              block_select(
                "showcase_select_doc_choices",
                choices = c("Plans" = "plans", "Frameworks" = "frameworks", "Fruits" = "fruits"),
                selected = "plans",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("selected", `for` = "showcase_select_doc_selected"),
              uiOutput("showcase_select_doc_selected_ui")
            ),
            block_field(
              block_field_label("placeholder", `for` = "showcase_select_doc_placeholder"),
              block_textarea("showcase_select_doc_placeholder", value = "Choose a plan", rows = 1, resize = "none")
            )
          ),
          
          # State Controls Group
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "State"),
            block_field(
              block_field_label("multiple", `for` = "showcase_select_doc_multiple"),
              block_checkbox("showcase_select_doc_multiple", "Allow multiple values", value = FALSE)
            ),
            block_field(
              block_field_label("max_items", `for` = "showcase_select_doc_max_items"),
              block_select(
                "showcase_select_doc_max_items",
                choices = c("No cap" = "none", "1" = "1", "2" = "2", "3" = "3"),
                selected = "none",
                size = "sm"
              )
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
          
          # Styling Controls Group
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Styling"),
            block_field(
              block_field_label("size", `for` = "showcase_select_doc_size"),
              block_select(
                "showcase_select_doc_size",
                choices = c("default", "sm", "lg"),
                selected = "default",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("width", `for` = "showcase_select_doc_width"),
              block_textarea("showcase_select_doc_width", value = "100%", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("style", `for` = "showcase_select_doc_style"),
              block_textarea(
                "showcase_select_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., border: 2px dashed red;",
                resize = "none"
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
          ),
          
          # Actions (Server Update) Group
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Actions (Server Update)"),
            block_cluster(
              gap = "sm",
              showcase_action_button("showcase_select_set_pro", "Set Pro"),
              showcase_action_button("showcase_select_set_two", "Select two"),
              showcase_action_button("showcase_select_clear", "Clear"),
              showcase_action_button("showcase_select_disable", "Disable"),
              showcase_action_button("showcase_select_enable", "Enable"),
              showcase_action_button("showcase_select_replace_choices", "Replace choices")
            )
          )
        ),
        
        # Right Column: Preview & Reactive Output Code Blocks
        block_stack(
          gap = "lg",
          class = "showcase-playground__main",
          
          # Preview Section
          block_stack(
            gap = "sm",
            htmltools::tags$div(class = "showcase-playground__label", "Preview"),
            # Interactive Preview Canvas
            htmltools::tags$div(
              class = "showcase-preview-canvas",
              uiOutput("showcase_select_preview_ui")
            )
          ),
          
          # Reactive Value Readout Indicator
          uiOutput("showcase_select_preview_value"),
          
          # Code Blocks Panel
          block_stack(
            gap = "md",
            htmltools::tags$div(
              htmltools::tags$div(
                style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
                "UI Definition"
              ),
              uiOutput("showcase_select_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(
                style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
                "Server Action"
              ),
              uiOutput("showcase_select_reactive_code")
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

  select_doc_max_items <- function(key) {
    key <- key %||% "none"
    if (identical(key, "none")) NULL else as.integer(key)
  }

  # `multiple` is mount-time identity, so single and multiple modes render the
  # `selected` control under distinct input ids (forcing a real remount when the
  # checkbox flips). This reader returns whichever id is currently active.
  select_doc_selected <- function() {
    if (isTRUE(input$showcase_select_doc_multiple)) {
      input$showcase_select_doc_selected_multi
    } else {
      input$showcase_select_doc_selected_single
    }
  }

  output$showcase_select_preview_value <- showcase_render_value({
    value <- input$showcase_select_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (length(value) == 0) {
      "character(0)"
    } else if (length(value) == 1 && identical(value, "")) {
      "<EMPTY>"
    } else if (length(value) == 1) {
      paste0('"', value, '"')
    } else {
      paste0("c(", paste0('"', value, '"', collapse = ", "), ")")
    }
    paste0("input$showcase_select_preview = ", val_str)
  })
  outputOptions(output, "showcase_select_preview_value", suspendWhenHidden = FALSE)

  # The `selected` control mirrors the `multiple` checkbox: single mode renders a
  # single-value select, multiple mode renders a chip multi-select. Re-render on
  # checkbox or choices change; default to the first choice so it is never empty.
  output$showcase_select_doc_selected_ui <- renderUI({
    choices <- select_doc_choices(input$showcase_select_doc_choices)
    multiple <- isTRUE(input$showcase_select_doc_multiple)
    block_select(
      if (multiple) "showcase_select_doc_selected_multi" else "showcase_select_doc_selected_single",
      choices = choices,
      selected = unname(choices[[1]]),
      multiple = multiple,
      placeholder = if (multiple) "Select default value(s)" else NULL,
      size = "sm"
    )
  })
  outputOptions(output, "showcase_select_doc_selected_ui", suspendWhenHidden = FALSE)

  observeEvent(input$showcase_select_doc_class, {
    update_block_select(
      session,
      "showcase_select_preview",
      class = if (isTRUE(input$showcase_select_doc_class)) "showcase-select-preview-custom" else NULL
    )
  }, ignoreInit = TRUE)

  output$showcase_select_preview_ui <- renderUI({
    choices <- select_doc_choices(input$showcase_select_doc_choices)
    multiple <- isTRUE(input$showcase_select_doc_multiple)
    max_items <- select_doc_max_items(input$showcase_select_doc_max_items)

    # The `selected` control reports a (possibly empty) vector; keep only valid
    # values. Multiple mode passes the whole vector; single mode takes the first,
    # falling back to the first choice so the preview is never empty.
    chosen <- select_doc_selected()
    chosen <- chosen[chosen %in% unname(choices)]
    if (multiple) {
      selected <- chosen
      if (!is.null(max_items) && length(selected) > max_items) {
        selected <- selected[seq_len(max_items)]
      }
    } else {
      selected <- if (length(chosen)) chosen[[1]] else unname(choices[[1]])
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
      invalid = isTRUE(input$showcase_select_doc_invalid),
      multiple = multiple,
      max_items = if (multiple) max_items else NULL
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

    choices <- select_doc_choices(choices_val)
    multiple_val <- isTRUE(input$showcase_select_doc_multiple)
    max_items_val <- select_doc_max_items(input$showcase_select_doc_max_items)
    selected_val <- select_doc_selected()
    selected_val <- selected_val[selected_val %in% unname(choices)]
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
    if (multiple_val) {
      sel <- selected_val
      if (!is.null(max_items_val) && length(sel) > max_items_val) {
        sel <- sel[seq_len(max_items_val)]
      }
      if (length(sel)) {
        args <- c(args, paste0("selected = c(", paste0('"', sel, '"', collapse = ", "), ")"))
      }
    } else if (length(selected_val)) {
      args <- c(args, paste0('selected = "', selected_val[[1]], '"'))
    }
    if (!is.null(placeholder_val) && nzchar(placeholder_val)) {
      args <- c(args, paste0('placeholder = "', placeholder_val, '"'))
    }
    if (multiple_val) {
      args <- c(args, "multiple = TRUE")
      if (!is.null(max_items_val)) {
        args <- c(args, paste0("max_items = ", max_items_val))
      }
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
  observeEvent(input$showcase_select_set_two, {
    update_block_select(session, "showcase_select_preview", selected = c("free", "pro"))
    reactive_code('update_block_select(\n  session = session,\n  input_id = "showcase_select_preview",\n  selected = c("free", "pro")\n)')
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

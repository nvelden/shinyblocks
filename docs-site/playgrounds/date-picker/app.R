# Install shinyblocks (pre-built WebAssembly binary) from r-universe.
# NOTE: must be installed.packages(), not requireNamespace() - webR shims
# requireNamespace() and it returns NULL (not FALSE) for packages missing
# from the default webR repo, so negating its result errors.
if (!"shinyblocks" %in% rownames(installed.packages())) {
  install.packages(
    "shinyblocks",
    repos = c("https://nvelden.r-universe.dev", "https://repo.r-wasm.org")
  )
}

library(shiny)
library(shinyblocks)

`%||%` <- function(a, b) if (is.null(a)) b else a

valid_iso <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }
  x <- trimws(x)
  if (!nzchar(x)) {
    return(NULL)
  }
  parsed <- suppressWarnings(as.Date(x, format = "%Y-%m-%d"))
  if (is.na(parsed) || !identical(format(parsed, "%Y-%m-%d"), x)) {
    return(NULL)
  }
  x
}

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
  title = "shinyblocks <U+00B7> Date Picker playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      "
      [data-shinyblocks-root] .showcase-date-picker-preview-custom .sb-date-picker-trigger,
      [data-shinyblocks-root].showcase-date-picker-preview-custom .sb-date-picker-trigger {
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
              block_field_label("value", `for` = "showcase_date_picker_doc_value"),
              block_textarea("showcase_date_picker_doc_value", value = "2024-01-15", rows = 1, placeholder = "yyyy-mm-dd", resize = "none")
            ),
            block_field(
              block_field_label("placeholder", `for` = "showcase_date_picker_doc_placeholder"),
              block_textarea("showcase_date_picker_doc_placeholder", value = "Pick a date", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("format", `for` = "showcase_date_picker_doc_format"),
              block_select(
                "showcase_date_picker_doc_format",
                choices = c("yyyy-mm-dd", "M d, yyyy" = "M d, yyyy", "DD, MM d, yyyy" = "DD, MM d, yyyy", "dd/mm/yyyy" = "dd/mm/yyyy"),
                selected = "M d, yyyy",
                size = "sm"
              )
            )
          ),

          # State Controls Group
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "State"),
            block_field(
              block_field_label("min", `for` = "showcase_date_picker_doc_min"),
              block_textarea("showcase_date_picker_doc_min", value = "", rows = 1, placeholder = "yyyy-mm-dd", resize = "none")
            ),
            block_field(
              block_field_label("max", `for` = "showcase_date_picker_doc_max"),
              block_textarea("showcase_date_picker_doc_max", value = "", rows = 1, placeholder = "yyyy-mm-dd", resize = "none")
            ),
            block_field(
              block_field_label("disabled", `for` = "showcase_date_picker_doc_disabled"),
              block_checkbox("showcase_date_picker_doc_disabled", "Disabled", value = FALSE)
            ),
            block_field(
              block_field_label("invalid", `for` = "showcase_date_picker_doc_invalid"),
              block_checkbox("showcase_date_picker_doc_invalid", "Invalid", value = FALSE)
            )
          ),

          # Styling Controls Group
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Styling"),
            block_field(
              block_field_label("weekstart", `for` = "showcase_date_picker_doc_weekstart"),
              block_select(
                "showcase_date_picker_doc_weekstart",
                choices = c("Sunday" = "0", "Monday" = "1"),
                selected = "0",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("width", `for` = "showcase_date_picker_doc_width"),
              block_textarea("showcase_date_picker_doc_width", value = "240px", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("style", `for` = "showcase_date_picker_doc_style"),
              block_textarea(
                "showcase_date_picker_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., border: 2px dashed red;",
                resize = "none"
              )
            ),
            block_field(
              block_field_label("class", `for` = "showcase_date_picker_doc_class"),
              block_checkbox(
                "showcase_date_picker_doc_class",
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
              showcase_action_button("showcase_date_picker_set_today", "Set today"),
              showcase_action_button("showcase_date_picker_set_xmas", "Set 2025-12-25"),
              showcase_action_button("showcase_date_picker_clear", "Clear"),
              showcase_action_button("showcase_date_picker_disable", "Disable"),
              showcase_action_button("showcase_date_picker_enable", "Enable"),
              showcase_action_button("showcase_date_picker_set_bounds", "Bound to 2025")
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
            htmltools::tags$div(
              class = "showcase-preview-canvas",
              uiOutput("showcase_date_picker_preview_ui")
            )
          ),

          # Reactive Value Readout Indicator
          uiOutput("showcase_date_picker_preview_value"),

          # Code Blocks Panel
          block_stack(
            gap = "md",
            htmltools::tags$div(
              htmltools::tags$div(
                class = "showcase-playground__label--code",
                "UI Definition"
              ),
              uiOutput("showcase_date_picker_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(
                class = "showcase-playground__label--code",
                "Server Action"
              ),
              uiOutput("showcase_date_picker_reactive_code")
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  output$showcase_date_picker_preview_value <- showcase_render_value({
    value <- input$showcase_date_picker_preview
    val_str <- if (is.null(value) || length(value) == 0) {
      "<NULL>"
    } else {
      paste0('as.Date("', format(value, "%Y-%m-%d"), '")')
    }
    paste0("input$showcase_date_picker_preview = ", val_str)
  })
  outputOptions(output, "showcase_date_picker_preview_value", suspendWhenHidden = FALSE)

  observeEvent(input$showcase_date_picker_doc_class,
    {
      update_block_date_picker(
        session,
        "showcase_date_picker_preview",
        class = if (isTRUE(input$showcase_date_picker_doc_class)) "showcase-date-picker-preview-custom" else NULL
      )
    },
    ignoreInit = TRUE
  )

  output$showcase_date_picker_preview_ui <- renderUI({
    value <- valid_iso(input$showcase_date_picker_doc_value)
    min <- valid_iso(input$showcase_date_picker_doc_min)
    max <- valid_iso(input$showcase_date_picker_doc_max)

    if (!is.null(min) && !is.null(max) && min > max) max <- NULL
    if (!is.null(value) && !is.null(min) && value < min) value <- NULL
    if (!is.null(value) && !is.null(max) && value > max) value <- NULL

    placeholder <- input$showcase_date_picker_doc_placeholder %||% "Pick a date"
    if (!nzchar(placeholder)) placeholder <- "Pick a date"

    format <- input$showcase_date_picker_doc_format %||% "yyyy-mm-dd"
    weekstart <- as.integer(input$showcase_date_picker_doc_weekstart %||% "0")

    width <- input$showcase_date_picker_doc_width %||% "240px"
    if (!nzchar(width)) width <- NULL

    style <- input$showcase_date_picker_doc_style %||% ""
    if (!nzchar(style)) style <- NULL

    block_date_picker(
      input_id = "showcase_date_picker_preview",
      value = value,
      min = min,
      max = max,
      placeholder = placeholder,
      format = format,
      weekstart = weekstart,
      disabled = isTRUE(input$showcase_date_picker_doc_disabled),
      invalid = isTRUE(input$showcase_date_picker_doc_invalid),
      width = width,
      style = style,
      class = if (isTRUE(input$showcase_date_picker_doc_class)) "showcase-date-picker-preview-custom" else NULL
    )
  })
  outputOptions(output, "showcase_date_picker_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_date_picker_preview_code <- showcase_render_code({
    value <- valid_iso(input$showcase_date_picker_doc_value)
    min <- valid_iso(input$showcase_date_picker_doc_min)
    max <- valid_iso(input$showcase_date_picker_doc_max)
    placeholder_val <- input$showcase_date_picker_doc_placeholder
    format_val <- input$showcase_date_picker_doc_format
    weekstart_val <- input$showcase_date_picker_doc_weekstart
    width_val <- input$showcase_date_picker_doc_width
    style_val <- input$showcase_date_picker_doc_style
    class_val <- input$showcase_date_picker_doc_class
    disabled_val <- input$showcase_date_picker_doc_disabled
    invalid_val <- input$showcase_date_picker_doc_invalid

    args <- c('input_id = "showcase_date_picker_preview"')
    if (!is.null(value)) args <- c(args, paste0('value = "', value, '"'))
    if (!is.null(min)) args <- c(args, paste0('min = "', min, '"'))
    if (!is.null(max)) args <- c(args, paste0('max = "', max, '"'))
    if (!is.null(placeholder_val) && nzchar(placeholder_val) && placeholder_val != "Pick a date") {
      args <- c(args, paste0('placeholder = "', placeholder_val, '"'))
    }
    if (!is.null(format_val) && format_val != "yyyy-mm-dd") {
      args <- c(args, paste0('format = "', format_val, '"'))
    }
    if (!is.null(weekstart_val) && weekstart_val != "0") {
      args <- c(args, paste0("weekstart = ", weekstart_val))
    }
    if (isTRUE(disabled_val)) args <- c(args, "disabled = TRUE")
    if (isTRUE(invalid_val)) args <- c(args, "invalid = TRUE")
    if (!is.null(width_val) && nzchar(width_val) && width_val != "240px") {
      args <- c(args, paste0('width = "', width_val, '"'))
    }
    if (!is.null(style_val) && nzchar(style_val)) {
      args <- c(args, paste0('style = "', style_val, '"'))
    }
    if (isTRUE(class_val)) args <- c(args, 'class = "showcase-date-picker-preview-custom"')

    paste0("block_date_picker(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_date_picker_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_date_picker() code here."
  ))
  output$showcase_date_picker_reactive_code <- showcase_render_code({
    reactive_code()
  })
  outputOptions(output, "showcase_date_picker_reactive_code", suspendWhenHidden = FALSE)

  observeEvent(input$showcase_date_picker_set_today, {
    update_block_date_picker(session, "showcase_date_picker_preview", value = Sys.Date())
    reactive_code('update_block_date_picker(\n  session = session,\n  input_id = "showcase_date_picker_preview",\n  value = Sys.Date()\n)')
  })
  observeEvent(input$showcase_date_picker_set_xmas, {
    update_block_date_picker(session, "showcase_date_picker_preview", value = "2025-12-25")
    reactive_code('update_block_date_picker(\n  session = session,\n  input_id = "showcase_date_picker_preview",\n  value = "2025-12-25"\n)')
  })
  observeEvent(input$showcase_date_picker_clear, {
    update_block_date_picker(session, "showcase_date_picker_preview", clear = TRUE)
    reactive_code('update_block_date_picker(\n  session = session,\n  input_id = "showcase_date_picker_preview",\n  clear = TRUE\n)')
  })
  observeEvent(input$showcase_date_picker_disable, {
    update_block_date_picker(session, "showcase_date_picker_preview", disabled = TRUE)
    reactive_code('update_block_date_picker(\n  session = session,\n  input_id = "showcase_date_picker_preview",\n  disabled = TRUE\n)')
  })
  observeEvent(input$showcase_date_picker_enable, {
    update_block_date_picker(session, "showcase_date_picker_preview", disabled = FALSE)
    reactive_code('update_block_date_picker(\n  session = session,\n  input_id = "showcase_date_picker_preview",\n  disabled = FALSE\n)')
  })
  observeEvent(input$showcase_date_picker_set_bounds, {
    update_block_date_picker(
      session,
      "showcase_date_picker_preview",
      min = "2025-01-01",
      max = "2025-12-31",
      value = "2025-06-15"
    )
    reactive_code('update_block_date_picker(\n  session = session,\n  input_id = "showcase_date_picker_preview",\n  min = "2025-01-01",\n  max = "2025-12-31",\n  value = "2025-06-15"\n)')
  })
}

shinyApp(ui, server)

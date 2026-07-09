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

parse_accordion_items <- function(text) {
  if (is.null(text) || !nzchar(text)) {
    return(list())
  }
  lines <- strsplit(text, "\n", fixed = TRUE)[[1]]
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]
  if (!length(lines)) {
    return(list())
  }

  lapply(lines, function(line) {
    parts <- trimws(strsplit(line, "|", fixed = TRUE)[[1]])
    value <- parts[[1]]
    title <- if (length(parts) >= 2) parts[[2]] else parts[[1]]
    body <- if (length(parts) >= 3) parts[[3]] else "Panel content."
    list(value = value, title = title, body = body)
  })
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
  title = "shinyblocks · Accordion playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
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
        block_card(
          title = "Controls",
          class = "showcase-playground__controls",
          block_stack(
            gap = "sm",
            class = "showcase-controls-group showcase-controls-group--first",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Content"),
            block_field(
              block_field_label("items", `for` = "showcase_accordion_doc_items"),
              block_textarea(
                "showcase_accordion_doc_items",
                value = paste(
                  "shipping|Is it accessible?|Yes. It adheres to the WAI-ARIA design pattern.",
                  "returns|Is it styled?|It ships with sensible token-driven defaults.",
                  "billing|Is it animated?|Yes, the panel height animates by default.",
                  sep = "\n"
                ),
                rows = 4,
                resize = "none"
              )
            ),
            block_field(
              block_field_label("icons", `for` = "showcase_accordion_doc_icons"),
              block_checkbox("showcase_accordion_doc_icons", "Show leading icons", value = FALSE)
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "State"),
            block_field(
              block_field_label("type", `for` = "showcase_accordion_doc_type"),
              block_radio_group(
                "showcase_accordion_doc_type",
                choices = c(Single = "single", Multiple = "multiple"),
                selected = "single",
                orientation = "horizontal"
              )
            ),
            block_field(
              block_field_label("collapsible", `for` = "showcase_accordion_doc_collapsible"),
              block_checkbox(
                "showcase_accordion_doc_collapsible",
                "Allow the open item to collapse (single mode)",
                value = TRUE
              )
            ),
            block_field(
              block_field_label("initial open", `for` = "showcase_accordion_doc_open"),
              block_input("showcase_accordion_doc_open", value = "shipping")
            ),
            block_field(
              block_field_label("disabled", `for` = "showcase_accordion_doc_disabled"),
              block_checkbox("showcase_accordion_doc_disabled", "Disable the last item", value = FALSE)
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Styling"),
            block_field(
              block_field_label("style", `for` = "showcase_accordion_doc_style"),
              block_input(
                "showcase_accordion_doc_style",
                value = "",
                placeholder = "e.g., max-width: 28rem;"
              )
            ),
            block_field(
              block_field_label("class", `for` = "showcase_accordion_doc_class"),
              block_checkbox("showcase_accordion_doc_class", "Use custom dashed-border class", value = FALSE)
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Actions (Server Update)"),
            block_cluster(
              gap = "sm",
              showcase_action_button("showcase_accordion_open_billing", "Open billing"),
              showcase_action_button("showcase_accordion_open_all", "Open all"),
              showcase_action_button("showcase_accordion_close_all", "Close all")
            )
          )
        ),
        block_stack(
          gap = "lg",
          class = "showcase-playground__main",
          block_stack(
            gap = "sm",
            htmltools::tags$div(class = "showcase-playground__label", "Preview"),
            htmltools::tags$div(
              class = "showcase-preview-canvas",
              style = "min-height: 220px;",
              uiOutput("showcase_accordion_preview_ui")
            )
          ),
          uiOutput("showcase_accordion_preview_value"),
          block_stack(
            gap = "md",
            htmltools::tags$div(
              htmltools::tags$div(
                class = "showcase-playground__label--code",
                "UI Definition"
              ),
              uiOutput("showcase_accordion_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(
                class = "showcase-playground__label--code",
                "Server Action"
              ),
              uiOutput("showcase_accordion_reactive_code")
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  accordion_state <- reactive({
    items <- parse_accordion_items(input$showcase_accordion_doc_items %||% "")
    if (!length(items)) {
      items <- list(
        list(value = "one", title = "Item one", body = "First panel body.")
      )
    }
    type <- input$showcase_accordion_doc_type %||% "single"
    values <- vapply(items, function(i) i$value, character(1))

    open_raw <- trimws(strsplit(input$showcase_accordion_doc_open %||% "", ",", fixed = TRUE)[[1]])
    open_raw <- unique(open_raw[nzchar(open_raw) & open_raw %in% values])
    open <- if (!length(open_raw)) {
      NULL
    } else if (identical(type, "single")) {
      open_raw[[1]]
    } else {
      open_raw
    }

    disabled_value <- if (isTRUE(input$showcase_accordion_doc_disabled)) {
      values[[length(values)]]
    } else {
      NULL
    }

    list(
      items = items,
      type = type,
      collapsible = isTRUE(input$showcase_accordion_doc_collapsible),
      open = open,
      icons = isTRUE(input$showcase_accordion_doc_icons),
      disabled_value = disabled_value,
      style = {
        style_val <- input$showcase_accordion_doc_style %||% ""
        if (nzchar(style_val)) style_val else NULL
      },
      class = if (isTRUE(input$showcase_accordion_doc_class)) {
        "showcase-accordion-preview-custom"
      } else {
        NULL
      }
    )
  })

  build_accordion_items <- function(state) {
    icon_pool <- c("help-circle", "package", "dollar-sign", "settings", "star")
    lapply(seq_along(state$items), function(i) {
      item <- state$items[[i]]
      block_accordion_item(
        value = item$value,
        title = item$title,
        htmltools::tags$p(style = "margin: 0; color: var(--muted-foreground);", item$body),
        icon = if (isTRUE(state$icons)) icon_pool[[((i - 1) %% length(icon_pool)) + 1]] else NULL,
        disabled = identical(item$value, state$disabled_value)
      )
    })
  }

  output$showcase_accordion_preview_ui <- renderUI({
    state <- accordion_state()
    do.call(
      block_accordion,
      c(
        build_accordion_items(state),
        list(
          id = "showcase_accordion_preview",
          type = state$type,
          collapsible = state$collapsible,
          open = state$open,
          style = state$style,
          class = state$class
        )
      )
    )
  })

  output$showcase_accordion_preview_value <- showcase_render_value({
    value <- input$showcase_accordion_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (!length(value)) {
      "<EMPTY>"
    } else {
      paste(value, collapse = ", ")
    }
    paste0("input$showcase_accordion_preview = ", val_str)
  })

  output$showcase_accordion_preview_code <- showcase_render_code({
    state <- accordion_state()

    item_lines <- vapply(state$items, function(item) {
      disabled <- if (identical(item$value, state$disabled_value)) ", disabled = TRUE" else ""
      sprintf(
        '  block_accordion_item("%s", "%s", "%s"%s)',
        item$value, item$title, item$body, disabled
      )
    }, character(1))

    args <- paste(item_lines, collapse = ",\n")
    tail <- c('  id = "showcase_accordion_preview"')
    if (!identical(state$type, "single")) {
      tail <- c(tail, sprintf('  type = "%s"', state$type))
    }
    if (identical(state$type, "single") && !isTRUE(state$collapsible)) {
      tail <- c(tail, "  collapsible = FALSE")
    }
    if (!is.null(state$open)) {
      open_text <- if (length(state$open) > 1) {
        paste0("c(", paste(sprintf('"%s"', state$open), collapse = ", "), ")")
      } else {
        sprintf('"%s"', state$open)
      }
      tail <- c(tail, paste0("  open = ", open_text))
    }
    if (!is.null(state$style)) tail <- c(tail, sprintf('  style = "%s"', state$style))
    if (!is.null(state$class)) {
      tail <- c(tail, '  class = "showcase-accordion-preview-custom"')
    }

    paste0(
      "block_accordion(\n",
      args, ",\n",
      paste(tail, collapse = ",\n"),
      "\n)"
    )
  })

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_accordion() code here."
  ))

  output$showcase_accordion_reactive_code <- showcase_render_code({
    reactive_code()
  })

  observeEvent(input$showcase_accordion_open_billing, {
    update_block_accordion(session, "showcase_accordion_preview", open = "billing")
    reactive_code(paste0(
      "update_block_accordion(\n",
      "  session = session,\n",
      "  input_id = \"showcase_accordion_preview\",\n",
      "  open = \"billing\"\n",
      ")"
    ))
  })

  observeEvent(input$showcase_accordion_open_all, {
    values <- vapply(accordion_state()$items, function(i) i$value, character(1))
    update_block_accordion(session, "showcase_accordion_preview", open = values)
    reactive_code(paste0(
      "update_block_accordion(\n",
      "  session = session,\n",
      "  input_id = \"showcase_accordion_preview\",\n",
      "  open = c(", paste(sprintf('"%s"', values), collapse = ", "), ")\n",
      ")"
    ))
  })

  observeEvent(input$showcase_accordion_close_all, {
    update_block_accordion(session, "showcase_accordion_preview", open = NULL)
    reactive_code(paste0(
      "update_block_accordion(\n",
      "  session = session,\n",
      "  input_id = \"showcase_accordion_preview\",\n",
      "  open = NULL\n",
      ")"
    ))
  })
}

shinyApp(ui, server)

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

parse_toggle_choices <- function(text) {
  if (is.null(text) || !nzchar(text)) {
    return(list())
  }
  lines <- strsplit(text, "\n", fixed = TRUE)[[1]]
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]
  if (!length(lines)) {
    return(list())
  }

  parts <- strsplit(lines, "|", fixed = TRUE)
  labels <- vapply(parts, function(p) trimws(p[[1]]), character(1))
  values <- vapply(parts, function(p) {
    if (length(p) >= 2) trimws(p[[2]]) else trimws(p[[1]])
  }, character(1))
  setNames(values, labels)
}

parse_toggle_selected <- function(text, choices, type) {
  values <- as.character(choices)
  if (is.null(text) || !nzchar(text)) return(NULL)
  selected <- trimws(strsplit(text, ",", fixed = TRUE)[[1]])
  selected <- unique(selected[nzchar(selected) & selected %in% values])
  if (!length(selected)) return(NULL)
  if (identical(type, "single")) selected <- selected[[1]]
  selected
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

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

ui <- block_page(
  title = "shinyblocks · Toggle Group playground",
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
              block_field_label("label", `for` = "showcase_toggle_group_doc_label"),
              block_input("showcase_toggle_group_doc_label", value = "View")
            ),
            block_field(
              block_field_label("choices", `for` = "showcase_toggle_group_doc_choices"),
              block_textarea(
                "showcase_toggle_group_doc_choices",
                value = "List|list\nGrid|grid\nBoard|board",
                rows = 3,
                resize = "none"
              )
            ),
            block_field(
              block_field_label("initial selected", `for` = "showcase_toggle_group_doc_selected"),
              block_input("showcase_toggle_group_doc_selected", value = "list")
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "State"),
            block_field(
              block_field_label("type", `for` = "showcase_toggle_group_doc_type"),
              block_radio_group(
                "showcase_toggle_group_doc_type",
                choices = c(Single = "single", Multiple = "multiple"),
                selected = "single",
                orientation = "horizontal"
              )
            ),
            block_field(
              block_field_label("disabled", `for` = "showcase_toggle_group_doc_disabled"),
              block_checkbox("showcase_toggle_group_doc_disabled", "Disable whole group", value = FALSE)
            ),
            block_field(
              block_field_label("per-item disabled", `for` = "showcase_toggle_group_doc_disabled_item"),
              block_checkbox("showcase_toggle_group_doc_disabled_item", "Disable last choice only", value = FALSE)
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Styling"),
            block_field(
              block_field_label("variant", `for` = "showcase_toggle_group_doc_variant"),
              block_radio_group(
                "showcase_toggle_group_doc_variant",
                choices = c(Default = "default", Outline = "outline"),
                selected = "default",
                orientation = "horizontal"
              )
            ),
            block_field(
              block_field_label("size", `for` = "showcase_toggle_group_doc_size"),
              block_radio_group(
                "showcase_toggle_group_doc_size",
                choices = c(Default = "default", Small = "sm", Large = "lg"),
                selected = "default",
                orientation = "horizontal"
              )
            ),
            block_field(
              block_field_label("style", `for` = "showcase_toggle_group_doc_style"),
              block_textarea(
                "showcase_toggle_group_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., margin-top: 0.5rem;",
                resize = "none"
              )
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Actions (Server Update)"),
            block_cluster(
              gap = "sm",
              showcase_action_button("showcase_toggle_group_select_grid", "Select grid"),
              showcase_action_button("showcase_toggle_group_clear", "Clear"),
              showcase_action_button("showcase_toggle_group_disable", "Disable"),
              showcase_action_button("showcase_toggle_group_enable", "Enable"),
              showcase_action_button("showcase_toggle_group_swap_choices", "Swap choices")
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
              class = "showcase-preview-canvas showcase-preview-canvas--dashed",
              style = "min-height: 160px;",
              uiOutput("showcase_toggle_group_preview_ui")
            )
          ),
          uiOutput("showcase_toggle_group_preview_value"),
          block_stack(
            gap = "md",
            htmltools::tags$div(
              htmltools::tags$div(
                class = "showcase-playground__label--code",
                "UI Definition"
              ),
              uiOutput("showcase_toggle_group_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(
                class = "showcase-playground__label--code",
                "Server Action"
              ),
              uiOutput("showcase_toggle_group_reactive_code")
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    label <- input$showcase_toggle_group_doc_label %||% "View"
    if (!nzchar(label)) label <- "View"

    choices <- parse_toggle_choices(input$showcase_toggle_group_doc_choices %||% "")
    if (!length(choices)) choices <- c(List = "list", Grid = "grid", Board = "board")

    type <- input$showcase_toggle_group_doc_type %||% "single"

    disabled <- if (isTRUE(input$showcase_toggle_group_doc_disabled)) {
      TRUE
    } else if (isTRUE(input$showcase_toggle_group_doc_disabled_item)) {
      as.character(choices)[[length(choices)]]
    } else {
      FALSE
    }

    style <- input$showcase_toggle_group_doc_style %||% ""
    if (!nzchar(style)) style <- NULL

    list(
      label = label,
      choices = choices,
      selected = parse_toggle_selected(
        input$showcase_toggle_group_doc_selected %||% "",
        choices,
        type
      ),
      type = type,
      variant = input$showcase_toggle_group_doc_variant %||% "default",
      size = input$showcase_toggle_group_doc_size %||% "default",
      disabled = disabled,
      style = style
    )
  })

  output$showcase_toggle_group_preview_ui <- renderUI({
    args <- preview_args()
    block_field(
      block_field_label(args$label, `for` = "showcase_toggle_group_preview"),
      block_toggle_group(
        "showcase_toggle_group_preview",
        choices = args$choices,
        selected = args$selected,
        type = args$type,
        variant = args$variant,
        size = args$size,
        disabled = args$disabled,
        style = args$style
      )
    )
  })

  output$showcase_toggle_group_preview_value <- showcase_render_value({
    value <- input$showcase_toggle_group_preview
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (!length(value)) {
      "<EMPTY>"
    } else {
      paste(value, collapse = ", ")
    }
    paste0("input$showcase_toggle_group_preview = ", val_str)
  })

  output$showcase_toggle_group_preview_code <- showcase_render_code({
    args <- preview_args()
    choices_text <- paste(
      sprintf(
        "%s = %s",
        vapply(names(args$choices), string_literal, character(1)),
        vapply(args$choices, string_literal, character(1))
      ),
      collapse = ", "
    )
    toggle_args <- c(
      'input_id = "showcase_toggle_group_preview"',
      paste0("choices = c(", choices_text, ")")
    )
    if (!is.null(args$selected)) {
      selected_text <- if (length(args$selected) > 1) {
        paste0("c(", paste(vapply(args$selected, string_literal, character(1)), collapse = ", "), ")")
      } else {
        string_literal(args$selected)
      }
      toggle_args <- c(toggle_args, paste0("selected = ", selected_text))
    }
    if (!identical(args$type, "single")) {
      toggle_args <- c(toggle_args, paste0("type = ", string_literal(args$type)))
    }
    if (!identical(args$variant, "default")) {
      toggle_args <- c(toggle_args, paste0("variant = ", string_literal(args$variant)))
    }
    if (!identical(args$size, "default")) {
      toggle_args <- c(toggle_args, paste0("size = ", string_literal(args$size)))
    }
    if (isTRUE(args$disabled)) {
      toggle_args <- c(toggle_args, "disabled = TRUE")
    } else if (is.character(args$disabled)) {
      toggle_args <- c(toggle_args, paste0("disabled = ", string_literal(args$disabled)))
    }
    if (!is.null(args$style)) {
      toggle_args <- c(toggle_args, paste0("style = ", string_literal(args$style)))
    }

    paste0(
      "block_field(\n",
      "  block_field_label(", string_literal(args$label), "),\n",
      "  block_toggle_group(\n",
      "    ", paste(toggle_args, collapse = ",\n    "), "\n",
      "  )\n",
      ")"
    )
  })

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_toggle_group() code here."
  ))

  output$showcase_toggle_group_reactive_code <- showcase_render_code({
    reactive_code()
  })

  observeEvent(input$showcase_toggle_group_select_grid, {
    update_block_toggle_group(session, "showcase_toggle_group_preview", selected = "grid")
    reactive_code(paste0(
      "update_block_toggle_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_toggle_group_preview\",\n",
      "  selected = \"grid\"\n",
      ")"
    ))
  })

  observeEvent(input$showcase_toggle_group_clear, {
    update_block_toggle_group(session, "showcase_toggle_group_preview", selected = NULL)
    reactive_code(paste0(
      "update_block_toggle_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_toggle_group_preview\",\n",
      "  selected = NULL\n",
      ")"
    ))
  })

  observeEvent(input$showcase_toggle_group_disable, {
    update_block_toggle_group(session, "showcase_toggle_group_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_toggle_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_toggle_group_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  observeEvent(input$showcase_toggle_group_enable, {
    update_block_toggle_group(session, "showcase_toggle_group_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_toggle_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_toggle_group_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  observeEvent(input$showcase_toggle_group_swap_choices, {
    update_block_toggle_group(
      session,
      "showcase_toggle_group_preview",
      choices = c(Day = "day", Week = "week", Month = "month"),
      selected = "week"
    )
    reactive_code(paste0(
      "update_block_toggle_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_toggle_group_preview\",\n",
      "  choices = c(Day = \"day\", Week = \"week\", Month = \"month\"),\n",
      "  selected = \"week\"\n",
      ")"
    ))
  })
}

shinyApp(ui, server)

if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)

  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch({
      webr::mount("/packages", path)
      if ("shinyblocks" %in% installed.packages(lib.loc = "/packages")[, "Package"]) {
        mounted <- TRUE
        break
      }
    }, error = function(e) {
      # Try the next path; Shinylive resolves mount URLs differently by host.
    })
  }

  if (!mounted) {
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

parse_radio_choices <- function(text) {
  if (is.null(text) || !nzchar(text)) return(list())
  lines <- strsplit(text, "\n", fixed = TRUE)[[1]]
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]
  if (!length(lines)) return(list())

  parts <- strsplit(lines, "|", fixed = TRUE)
  labels <- vapply(parts, function(p) trimws(p[[1]]), character(1))
  values <- vapply(parts, function(p) {
    if (length(p) >= 2) trimws(p[[2]]) else trimws(p[[1]])
  }, character(1))
  setNames(values, labels)
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
  title = "shinyblocks · Radio Group playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      "
      [data-shinyblocks-root] .showcase-radio-group-preview-custom .sb-radio-group-control,
      [data-shinyblocks-root].showcase-radio-group-preview-custom .sb-radio-group-control {
        outline: 2px dashed red;
        outline-offset: 3px;
      }
      "
    ))
  ),
  htmltools::tags$div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
      htmltools::div(
        style = paste(
          "flex: 1; min-width: 280px; max-width: 320px;",
          "border: 1px solid var(--border); border-radius: 0.75rem;",
          "padding: 1.25rem; display: flex; flex-direction: column; gap: 1.25rem;",
          "background: color-mix(in oklab, var(--muted) 40%, transparent);"
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Content"
          ),
          block_field(
            block_field_label("label", `for` = "showcase_radio_group_doc_label"),
            block_input("showcase_radio_group_doc_label", value = "Notification preference")
          ),
          block_field(
            block_field_label("choices", `for` = "showcase_radio_group_doc_choices"),
            block_textarea(
              "showcase_radio_group_doc_choices",
              value = "All|all\nMentions|mentions\nNone|none",
              rows = 3
            )
          ),
          block_field(
            block_field_label("initial selected", `for` = "showcase_radio_group_doc_selected"),
            block_input("showcase_radio_group_doc_selected", value = "all")
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "State"
          ),
          block_field(
            block_field_label("orientation", `for` = "showcase_radio_group_doc_orientation"),
            block_radio_group(
              "showcase_radio_group_doc_orientation",
              choices = c(Vertical = "vertical", Horizontal = "horizontal"),
              selected = "vertical",
              orientation = "horizontal"
            )
          ),
          block_field(
            block_field_label("disabled", `for` = "showcase_radio_group_doc_disabled"),
            block_checkbox("showcase_radio_group_doc_disabled", "Disabled", value = FALSE)
          ),
          block_field(
            block_field_label("invalid", `for` = "showcase_radio_group_doc_invalid"),
            block_checkbox("showcase_radio_group_doc_invalid", "Invalid", value = FALSE)
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Styling"
          ),
          block_field(
            block_field_label("style", `for` = "showcase_radio_group_doc_style"),
            block_textarea(
              "showcase_radio_group_doc_style",
              value = "",
              rows = 1,
              placeholder = "e.g., padding: 0.5rem;"
            )
          ),
          block_field(
            block_field_label("class", `for` = "showcase_radio_group_doc_class"),
            block_checkbox(
              "showcase_radio_group_doc_class",
              "Use custom dashed-border class",
              value = FALSE
            )
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Actions (Server Update)"
          ),
          htmltools::tags$div(
            style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
            showcase_action_button("showcase_radio_group_select_mentions", "Select mentions"),
            showcase_action_button("showcase_radio_group_clear", "Reset"),
            showcase_action_button("showcase_radio_group_disable", "Disable"),
            showcase_action_button("showcase_radio_group_enable", "Enable"),
            showcase_action_button("showcase_radio_group_swap_choices", "Swap choices")
          )
        )
      ),
      htmltools::div(
        style = "flex: 2; min-width: 320px; display: flex; flex-direction: column; gap: 1.25rem;",
        htmltools::tags$div(
          style = "display: flex; flex-direction: column; gap: 0.5rem;",
          htmltools::tags$div(
            style = "font-size: 0.875rem; font-weight: 600; color: var(--foreground);",
            "Preview"
          ),
          htmltools::tags$div(
            style = paste(
              "position: relative; display: flex; align-items: center; justify-content: center;",
              "padding: 3rem 2rem 2.5rem 2rem; background: var(--card);",
              "border: 1px dashed var(--border); border-radius: 0.75rem;",
              "min-height: 220px; box-sizing: border-box;"
            ),
            uiOutput("showcase_radio_group_preview_ui")
          )
        ),
        uiOutput("showcase_radio_group_preview_value"),
        htmltools::tags$div(
          style = "display: flex; flex-direction: column; gap: 1rem;",
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
              "UI Definition"
            ),
            uiOutput("showcase_radio_group_preview_code")
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
              "Server Action"
            ),
            uiOutput("showcase_radio_group_reactive_code")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    label <- input$showcase_radio_group_doc_label %||% "Notification preference"
    if (!nzchar(label)) label <- "Notification preference"

    choices <- parse_radio_choices(input$showcase_radio_group_doc_choices %||% "")
    if (!length(choices)) choices <- c(All = "all", Mentions = "mentions", None = "none")

    selected <- input$showcase_radio_group_doc_selected %||% NULL
    if (is.null(selected) || !nzchar(selected) || !selected %in% as.character(choices)) {
      selected <- as.character(choices)[[1]]
    }

    style <- input$showcase_radio_group_doc_style %||% ""
    if (!nzchar(style)) style <- NULL

    list(
      label = label,
      choices = choices,
      selected = selected,
      orientation = input$showcase_radio_group_doc_orientation %||% "vertical",
      disabled = isTRUE(input$showcase_radio_group_doc_disabled),
      invalid = isTRUE(input$showcase_radio_group_doc_invalid),
      style = style,
      class = if (isTRUE(input$showcase_radio_group_doc_class)) "showcase-radio-group-preview-custom" else NULL
    )
  })

  output$showcase_radio_group_preview_ui <- renderUI({
    args <- preview_args()
    block_field(
      block_field_label(args$label, `for` = "showcase_radio_group_preview"),
      block_radio_group(
        "showcase_radio_group_preview",
        choices = args$choices,
        selected = args$selected,
        orientation = args$orientation,
        disabled = args$disabled,
        invalid = args$invalid,
        style = args$style,
        class = args$class
      )
    )
  })

  output$showcase_radio_group_preview_value <- showcase_render_code({
    value <- input$showcase_radio_group_preview
    val_str <- if (is.null(value)) "<NULL>" else if (!nzchar(value)) "<EMPTY>" else value
    paste0("input$showcase_radio_group_preview = ", val_str)
  })

  output$showcase_radio_group_preview_code <- showcase_render_code({
    args <- preview_args()
    choices_text <- paste(
      sprintf("%s = %s", vapply(names(args$choices), string_literal, character(1)), vapply(args$choices, string_literal, character(1))),
      collapse = ", "
    )
    radio_args <- c(
      'input_id = "showcase_radio_group_preview"',
      paste0("choices = c(", choices_text, ")"),
      paste0("selected = ", string_literal(args$selected)),
      paste0("orientation = ", string_literal(args$orientation))
    )
    if (args$disabled) radio_args <- c(radio_args, "disabled = TRUE")
    if (args$invalid) radio_args <- c(radio_args, "invalid = TRUE")
    if (!is.null(args$style)) radio_args <- c(radio_args, paste0("style = ", string_literal(args$style)))
    if (!is.null(args$class)) radio_args <- c(radio_args, paste0("class = ", string_literal(args$class)))

    paste0(
      "block_field(\n",
      "  block_field_label(", string_literal(args$label), "),\n",
      "  block_radio_group(\n",
      "    ", paste(radio_args, collapse = ",\n    "), "\n",
      "  )\n",
      ")"
    )
  })

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_radio_group() code here."
  ))

  output$showcase_radio_group_reactive_code <- showcase_render_code({
    reactive_code()
  })

  observeEvent(input$showcase_radio_group_select_mentions, {
    update_block_radio_group(session, "showcase_radio_group_preview", selected = "mentions")
    reactive_code(paste0(
      "update_block_radio_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_radio_group_preview\",\n",
      "  selected = \"mentions\"\n",
      ")"
    ))
  })

  observeEvent(input$showcase_radio_group_clear, {
    selected <- preview_args()$selected
    update_block_radio_group(session, "showcase_radio_group_preview", selected = selected)
    reactive_code(paste0(
      "update_block_radio_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_radio_group_preview\",\n",
      "  selected = \"", selected, "\"\n",
      ")"
    ))
  })

  observeEvent(input$showcase_radio_group_disable, {
    update_block_radio_group(session, "showcase_radio_group_preview", disabled = TRUE)
    reactive_code(paste0(
      "update_block_radio_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_radio_group_preview\",\n",
      "  disabled = TRUE\n",
      ")"
    ))
  })

  observeEvent(input$showcase_radio_group_enable, {
    update_block_radio_group(session, "showcase_radio_group_preview", disabled = FALSE)
    reactive_code(paste0(
      "update_block_radio_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_radio_group_preview\",\n",
      "  disabled = FALSE\n",
      ")"
    ))
  })

  observeEvent(input$showcase_radio_group_swap_choices, {
    update_block_radio_group(
      session,
      "showcase_radio_group_preview",
      choices = c(Daily = "daily", Weekly = "weekly", Monthly = "monthly"),
      selected = "weekly"
    )
    reactive_code(paste0(
      "update_block_radio_group(\n",
      "  session = session,\n",
      "  input_id = \"showcase_radio_group_preview\",\n",
      "  choices = c(Daily = \"daily\", Weekly = \"weekly\", Monthly = \"monthly\"),\n",
      "  selected = \"weekly\"\n",
      ")"
    ))
  })
}

shinyApp(ui, server)

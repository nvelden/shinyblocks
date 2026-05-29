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

button_doc_icon <- function(icon_value) {
  if (is.null(icon_value) || identical(icon_value, "none")) {
    return(NULL)
  }
  icon_value
}

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

ui <- block_page(
  title = "shinyblocks · Button playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::tags$div(
      `data-shinyblocks-root` = "",
      style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
      htmltools::div(
        class = "showcase-playground", style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",

        htmltools::div(
          class = "showcase-playground__controls", style = paste(
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
              block_field_label("label", `for` = "showcase_button_doc_label"),
              block_textarea("showcase_button_doc_label", value = "Continue", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("variant", `for` = "showcase_button_doc_variant"),
              block_select(
                "showcase_button_doc_variant",
                choices = c("default", "secondary", "outline", "ghost", "destructive", "link"),
                selected = "default",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("icon", `for` = "showcase_button_doc_icon"),
              block_select(
                "showcase_button_doc_icon",
                choices = c("<None>" = "none", search = "search", `arrow-right` = "arrow-right", check = "check"),
                selected = "none",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("icon_position", `for` = "showcase_button_doc_icon_position"),
              block_select(
                "showcase_button_doc_icon_position",
                choices = c("inline-start", "inline-end"),
                selected = "inline-start",
                size = "sm"
              )
            )
          ),

          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
            htmltools::tags$h4(
              style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
              "State"
            ),
            block_field(
              block_field_label("disabled", `for` = "showcase_button_doc_disabled"),
              block_checkbox("showcase_button_doc_disabled", "Disabled", value = FALSE)
            )
          ),

          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
            htmltools::tags$h4(
              style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
              "Styling"
            ),
            block_field(
              block_field_label("size", `for` = "showcase_button_doc_size"),
              block_select(
                "showcase_button_doc_size",
                choices = c("default", "sm", "lg"),
                selected = "default",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("icon-only", `for` = "showcase_button_doc_icon_only"),
              block_checkbox("showcase_button_doc_icon_only", "Render icon-only button", value = FALSE)
            ),
            block_field(
              block_field_label("style", `for` = "showcase_button_doc_style"),
              block_textarea(
                "showcase_button_doc_style",
                value = "",
                rows = 1,
                placeholder = "e.g., min-width: 10rem;",
                resize = "none"
              )
            ),
            block_field(
              block_field_label("class", `for` = "showcase_button_doc_class"),
              block_checkbox(
                "showcase_button_doc_class",
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
              showcase_action_button("showcase_button_set_label", "Set label"),
              showcase_action_button("showcase_button_cycle_variant", "Cycle variant"),
              showcase_action_button("showcase_button_disable", "Disable"),
              showcase_action_button("showcase_button_enable", "Enable"),
              showcase_action_button("showcase_button_set_icon", "Set icon"),
              showcase_action_button("showcase_button_clear_icon", "Clear icon")
            )
          )
        ),

        htmltools::div(
          class = "showcase-playground__main", style = "flex: 2; min-width: 320px; display: flex; flex-direction: column; gap: 1.25rem;",
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
                "border: 1px solid var(--border); border-radius: 0.75rem;",
                "min-height: 160px; box-sizing: border-box;",
                "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
              ),
              uiOutput("showcase_button_preview_ui")
            )
          ),
          uiOutput("showcase_button_preview_value"),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(
                style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
                "UI Definition"
              ),
              uiOutput("showcase_button_preview_code")
            ),
            htmltools::tags$div(
              htmltools::tags$div(
                style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
                "Server Action"
              ),
              uiOutput("showcase_button_reactive_code")
            )
          )
        )
      )
    )
)

server <- function(input, output, session) {
  variant_choices <- c("default", "secondary", "outline", "ghost", "destructive", "link")

  preview_args <- reactive({
    label <- input$showcase_button_doc_label %||% "Continue"
    if (!nzchar(label)) label <- "Continue"

    size <- input$showcase_button_doc_size %||% "default"
    icon_only <- isTRUE(input$showcase_button_doc_icon_only)
    icon <- button_doc_icon(input$showcase_button_doc_icon)
    if (icon_only) {
      size <- "icon"
      if (is.null(icon)) icon <- "search"
      label <- NULL
    }

    style <- input$showcase_button_doc_style %||% ""
    if (!nzchar(style)) style <- NULL

    list(
      label = label,
      variant = input$showcase_button_doc_variant %||% "default",
      size = size,
      icon = icon,
      icon_position = input$showcase_button_doc_icon_position %||% "inline-start",
      disabled = isTRUE(input$showcase_button_doc_disabled),
      style = style,
      class = if (isTRUE(input$showcase_button_doc_class)) "showcase-button-preview-custom" else NULL
    )
  })

  output$showcase_button_preview_ui <- renderUI({
    args <- preview_args()
    do.call(
      block_button,
      c(
        list(id = "showcase_button_preview"),
        args
      )
    )
  })
  outputOptions(output, "showcase_button_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_button_preview_value <- showcase_render_value({
    value <- input$showcase_button_preview
    val_str <- if (is.null(value)) "<NULL>" else as.character(value)
    paste0("input$showcase_button_preview = ", val_str)
  })
  outputOptions(output, "showcase_button_preview_value", suspendWhenHidden = FALSE)

  output$showcase_button_preview_code <- showcase_render_code({
    args <- preview_args()
    code_args <- c(
      paste0("label = ", if (is.null(args$label)) "NULL" else string_literal(args$label)),
      'id = "showcase_button_preview"'
    )

    if (args$variant != "default") code_args <- c(code_args, paste0("variant = ", string_literal(args$variant)))
    if (args$size != "default") code_args <- c(code_args, paste0("size = ", string_literal(args$size)))
    if (!is.null(args$icon)) {
      code_args <- c(code_args, paste0("icon = ", string_literal(args$icon)))
      if (args$icon_position != "inline-start") {
        code_args <- c(code_args, paste0("icon_position = ", string_literal(args$icon_position)))
      }
    }
    if (args$disabled) code_args <- c(code_args, "disabled = TRUE")
    if (!is.null(args$style)) code_args <- c(code_args, paste0("style = ", string_literal(args$style)))
    if (!is.null(args$class)) code_args <- c(code_args, paste0("class = ", string_literal(args$class)))

    paste0("block_button(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_button_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_button() code here."
  ))

  output$showcase_button_reactive_code <- showcase_render_code({
    reactive_code()
  })
  outputOptions(output, "showcase_button_reactive_code", suspendWhenHidden = FALSE)

  observeEvent(input$showcase_button_set_label, {
    update_block_button(session, "showcase_button_preview", label = "Saved!")
    reactive_code("update_block_button(\n  session = session,\n  input_id = \"showcase_button_preview\",\n  label = \"Saved!\"\n)")
  })

  observeEvent(input$showcase_button_cycle_variant, {
    current <- input$showcase_button_doc_variant %||% "default"
    idx <- match(current, variant_choices, nomatch = 0L)
    next_variant <- variant_choices[(idx %% length(variant_choices)) + 1L]
    update_block_button(session, "showcase_button_preview", variant = next_variant)
    reactive_code(paste0(
      "update_block_button(\n",
      "  session = session,\n",
      "  input_id = \"showcase_button_preview\",\n",
      "  variant = \"", next_variant, "\"\n",
      ")"
    ))
  })

  observeEvent(input$showcase_button_disable, {
    update_block_button(session, "showcase_button_preview", disabled = TRUE)
    reactive_code("update_block_button(\n  session = session,\n  input_id = \"showcase_button_preview\",\n  disabled = TRUE\n)")
  })

  observeEvent(input$showcase_button_enable, {
    update_block_button(session, "showcase_button_preview", disabled = FALSE)
    reactive_code("update_block_button(\n  session = session,\n  input_id = \"showcase_button_preview\",\n  disabled = FALSE\n)")
  })

  observeEvent(input$showcase_button_set_icon, {
    update_block_button(session, "showcase_button_preview", icon = "check")
    reactive_code("update_block_button(\n  session = session,\n  input_id = \"showcase_button_preview\",\n  icon = \"check\"\n)")
  })

  observeEvent(input$showcase_button_clear_icon, {
    update_block_button(session, "showcase_button_preview", icon = NULL)
    reactive_code("update_block_button(\n  session = session,\n  input_id = \"showcase_button_preview\",\n  icon = NULL\n)")
  })
}

shinyApp(ui, server)

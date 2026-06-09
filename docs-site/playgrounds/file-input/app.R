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

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
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

showcase_controls_heading <- function(label) {
  htmltools::tags$h4(
    style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
    label
  )
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
  title = "shinyblocks · File input playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css"),
    htmltools::tags$style(htmltools::HTML(
      "
      [data-shinyblocks-root] .sb-file-input-control.showcase-file-input-preview-custom,
      [data-shinyblocks-root] .sb-file-dropzone.showcase-file-input-preview-custom {
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
      style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",

      # Left Column: Controls Panel
      block_card(
        title = "Controls",
        class = "showcase-playground__controls",
        style = "flex: 1; min-width: 280px; max-width: 320px;",

        # Content Controls Group
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem;",
          showcase_controls_heading("Content"),
          block_field(
            block_field_label("variant", `for` = "showcase_file_input_doc_variant"),
            block_select(
              "showcase_file_input_doc_variant",
              choices = c(button = "button", dropzone = "dropzone"),
              selected = "button",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("button label", `for` = "showcase_file_input_doc_button_label"),
            block_input("showcase_file_input_doc_button_label", value = "Browse")
          ),
          block_field(
            block_field_label("placeholder", `for` = "showcase_file_input_doc_placeholder"),
            block_input("showcase_file_input_doc_placeholder", value = "No file selected")
          ),
          block_field(
            block_field_label("dropzone label", `for` = "showcase_file_input_doc_dropzone_label"),
            block_input("showcase_file_input_doc_dropzone_label", value = "Drag files here or click to browse")
          ),
          block_field(
            block_field_label("dropzone hint", `for` = "showcase_file_input_doc_dropzone_hint"),
            block_input("showcase_file_input_doc_dropzone_hint", value = "", placeholder = "optional hint")
          ),
          block_field(
            block_field_label("dropzone icon", `for` = "showcase_file_input_doc_dropzone_icon"),
            block_select(
              "showcase_file_input_doc_dropzone_icon",
              choices = c(none = "none", upload = "upload", file = "file", image = "image"),
              selected = "upload",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("custom content", `for` = "showcase_file_input_doc_dropzone_content"),
            block_checkbox("showcase_file_input_doc_dropzone_content", "Use custom dropzone_content", value = FALSE)
          ),
          block_field(
            block_field_label("accept", `for` = "showcase_file_input_doc_accept"),
            block_input("showcase_file_input_doc_accept", value = ".csv,text/csv", placeholder = ".csv,image/png")
          )
        ),

        # State Controls Group
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          showcase_controls_heading("State"),
          block_field(
            block_field_label("multiple", `for` = "showcase_file_input_doc_multiple"),
            block_checkbox("showcase_file_input_doc_multiple", "Allow multiple files", value = FALSE)
          ),
          block_field(
            block_field_label("disabled", `for` = "showcase_file_input_doc_disabled"),
            block_checkbox("showcase_file_input_doc_disabled", "Disabled", value = FALSE)
          ),
          block_field(
            block_field_label("invalid", `for` = "showcase_file_input_doc_invalid"),
            block_checkbox("showcase_file_input_doc_invalid", "Invalid", value = FALSE)
          )
        ),

        # Styling Controls Group
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          showcase_controls_heading("Styling"),
          block_field(
            block_field_label("width", `for` = "showcase_file_input_doc_width"),
            block_input("showcase_file_input_doc_width", value = "100%", placeholder = "20rem or 100%")
          ),
          block_field(
            block_field_label("style", `for` = "showcase_file_input_doc_style"),
            block_textarea(
              "showcase_file_input_doc_style",
              value = "",
              rows = 1,
              placeholder = "e.g., max-width: 24rem;",
              resize = "none"
            )
          ),
          block_field(
            block_field_label("class", `for` = "showcase_file_input_doc_class"),
            block_checkbox(
              "showcase_file_input_doc_class",
              "Use custom dashed-border class",
              value = FALSE
            )
          )
        ),

        # Actions (Server Update) Group
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          showcase_controls_heading("Actions (Server Update)"),
          htmltools::tags$div(
            style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
            showcase_action_button("showcase_file_input_to_dropzone", "Switch to dropzone"),
            showcase_action_button("showcase_file_input_to_button", "Switch to button"),
            showcase_action_button("showcase_file_input_relabel", "Relabel button"),
            showcase_action_button("showcase_file_input_set_content", "Set custom content"),
            showcase_action_button("showcase_file_input_clear_content", "Clear custom content"),
            showcase_action_button("showcase_file_input_disable", "Disable"),
            showcase_action_button("showcase_file_input_enable", "Enable"),
            showcase_action_button("showcase_file_input_mark_invalid", "Mark invalid"),
            showcase_action_button("showcase_file_input_clear_invalid", "Clear invalid"),
            showcase_action_button("showcase_file_input_reset", "Reset selection")
          )
        )
      ),

      # Right Column: Preview & Code Blocks
      htmltools::div(
        class = "showcase-playground__main",
        style = "flex: 1.4; min-width: 320px; display: flex; flex-direction: column; gap: 1rem;",
        htmltools::div(
          style = "border: 1px dashed var(--border); border-radius: var(--radius-lg); padding: 1.25rem; background: color-mix(in oklch, var(--muted) 18%, transparent);",
          block_field(
            block_field_label("Upload data", `for` = "showcase_file_input_preview"),
            uiOutput("showcase_file_input_preview_ui"),
            block_field_description("Server value uses Shiny's native fileInput() data frame.")
          )
        ),
        uiOutput("showcase_file_input_preview_value"),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_file_input_preview_code")
        ),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "Server Action"
          ),
          uiOutput("showcase_file_input_reactive_code")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  dropzone_content_example <- function() {
    htmltools::tagList(
      htmltools::tags$span(
        class = "sb-file-dropzone-icon",
        `aria-hidden` = "true",
        block_icon("upload", size = "lg")
      ),
      htmltools::tags$strong("Upload your files"),
      htmltools::tags$span(
        style = "color: var(--muted-foreground); font-size: 0.8125rem;",
        "Drag and drop files here or click to browse"
      ),
      htmltools::tags$button(
        type = "button",
        class = "sb-file-dropzone-trigger",
        `data-dropzone-trigger` = NA,
        "Select files"
      )
    )
  }
  dropzone_content_example_code <- paste(
    "dropzone_content = htmltools::tagList(",
    "    htmltools::tags$span(",
    "      class = \"sb-file-dropzone-icon\", `aria-hidden` = \"true\",",
    "      block_icon(\"upload\", size = \"lg\")",
    "    ),",
    "    htmltools::tags$strong(\"Upload your files\"),",
    "    htmltools::tags$span(\"Drag and drop files here or click to browse\"),",
    "    htmltools::tags$button(",
    "      type = \"button\", class = \"sb-file-dropzone-trigger\",",
    "      `data-dropzone-trigger` = NA, \"Select files\"",
    "    )",
    "  )",
    sep = "\n"
  )

  file_input_args <- reactive({
    accept_value <- input$showcase_file_input_doc_accept %||% ".csv,text/csv"
    accept <- trimws(strsplit(accept_value, ",", fixed = TRUE)[[1]])
    accept <- accept[nzchar(accept)]
    if (!length(accept)) accept <- NULL

    style_val <- input$showcase_file_input_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL

    class_val <- if (isTRUE(input$showcase_file_input_doc_class)) {
      "showcase-file-input-preview-custom"
    } else {
      NULL
    }

    dz_hint <- input$showcase_file_input_doc_dropzone_hint %||% ""
    if (!nzchar(dz_hint)) dz_hint <- NULL

    dz_icon <- input$showcase_file_input_doc_dropzone_icon %||% "upload"
    if (!nzchar(dz_icon) || identical(dz_icon, "none")) dz_icon <- NULL

    list(
      variant = input$showcase_file_input_doc_variant %||% "button",
      button_label = input$showcase_file_input_doc_button_label %||% "Browse",
      placeholder = input$showcase_file_input_doc_placeholder %||% "No file selected",
      dropzone_label = input$showcase_file_input_doc_dropzone_label %||% "Drag files here or click to browse",
      dropzone_hint = dz_hint,
      dropzone_icon = dz_icon,
      use_content = isTRUE(input$showcase_file_input_doc_dropzone_content),
      accept = accept,
      multiple = isTRUE(input$showcase_file_input_doc_multiple),
      width = input$showcase_file_input_doc_width %||% "100%",
      disabled = isTRUE(input$showcase_file_input_doc_disabled),
      invalid = isTRUE(input$showcase_file_input_doc_invalid),
      style = style_val,
      class = class_val
    )
  })

  output$showcase_file_input_preview_ui <- renderUI({
    args <- file_input_args()
    block_file_input(
      "showcase_file_input_preview",
      variant = args$variant,
      multiple = args$multiple,
      accept = args$accept,
      button_label = args$button_label,
      placeholder = args$placeholder,
      dropzone_label = args$dropzone_label,
      dropzone_hint = args$dropzone_hint,
      dropzone_icon = args$dropzone_icon,
      dropzone_content = if (args$use_content) dropzone_content_example() else NULL,
      width = args$width,
      disabled = args$disabled,
      invalid = args$invalid,
      style = args$style,
      class = args$class
    )
  })
  outputOptions(output, "showcase_file_input_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_file_input_preview_value <- showcase_render_code({
    value <- input$showcase_file_input_preview
    if (is.null(value)) {
      "input$showcase_file_input_preview = <NULL>"
    } else {
      paste(c(
        "input$showcase_file_input_preview =",
        capture.output(print(value[, c("name", "size", "type", "datapath")], row.names = FALSE))
      ), collapse = "\n")
    }
  })
  outputOptions(output, "showcase_file_input_preview_value", suspendWhenHidden = FALSE)

  output$showcase_file_input_preview_code <- showcase_render_code({
    args <- file_input_args()
    code_args <- c('input_id = "showcase_file_input_preview"')
    if (!identical(args$variant, "button")) {
      code_args <- c(code_args, paste0("variant = ", string_literal(args$variant)))
    }
    if (args$multiple) code_args <- c(code_args, "multiple = TRUE")
    if (!is.null(args$accept)) {
      quoted <- paste(vapply(args$accept, string_literal, character(1)), collapse = ", ")
      code_args <- c(code_args, paste0("accept = c(", quoted, ")"))
    }
    if (!identical(args$button_label, "Browse")) {
      code_args <- c(code_args, paste0("button_label = ", string_literal(args$button_label)))
    }
    if (!identical(args$placeholder, "No file selected")) {
      code_args <- c(code_args, paste0("placeholder = ", string_literal(args$placeholder)))
    }
    if (identical(args$variant, "dropzone") &&
          !identical(args$dropzone_label, "Drag files here or click to browse")) {
      code_args <- c(code_args, paste0("dropzone_label = ", string_literal(args$dropzone_label)))
    }
    if (identical(args$variant, "dropzone") && !is.null(args$dropzone_hint)) {
      code_args <- c(code_args, paste0("dropzone_hint = ", string_literal(args$dropzone_hint)))
    }
    if (identical(args$variant, "dropzone") && args$use_content) {
      code_args <- c(code_args, dropzone_content_example_code)
    } else if (identical(args$variant, "dropzone") &&
                 !is.null(args$dropzone_icon) &&
                 !identical(args$dropzone_icon, "upload")) {
      code_args <- c(code_args, paste0("dropzone_icon = ", string_literal(args$dropzone_icon)))
    }
    if (!is.null(args$width) && nzchar(args$width) && !identical(args$width, "100%")) {
      code_args <- c(code_args, paste0("width = ", string_literal(args$width)))
    }
    if (args$disabled) code_args <- c(code_args, "disabled = TRUE")
    if (args$invalid) code_args <- c(code_args, "invalid = TRUE")
    if (!is.null(args$style)) code_args <- c(code_args, paste0("style = ", string_literal(args$style)))
    if (!is.null(args$class)) code_args <- c(code_args, paste0("class = ", string_literal(args$class)))

    paste0("block_file_input(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_file_input_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_file_input() code here."
  ))

  output$showcase_file_input_reactive_code <- showcase_render_code({
    reactive_code()
  })
  outputOptions(output, "showcase_file_input_reactive_code", suspendWhenHidden = FALSE)

  observeEvent(input$showcase_file_input_to_dropzone, {
    update_block_file_input(session, "showcase_file_input_preview", variant = "dropzone")
    reactive_code('update_block_file_input(\n  session = session,\n  input_id = "showcase_file_input_preview",\n  variant = "dropzone"\n)')
  })

  observeEvent(input$showcase_file_input_to_button, {
    update_block_file_input(session, "showcase_file_input_preview", variant = "button")
    reactive_code('update_block_file_input(\n  session = session,\n  input_id = "showcase_file_input_preview",\n  variant = "button"\n)')
  })

  observeEvent(input$showcase_file_input_relabel, {
    update_block_file_input(session, "showcase_file_input_preview", button_label = "Pick a file")
    reactive_code('update_block_file_input(\n  session = session,\n  input_id = "showcase_file_input_preview",\n  button_label = "Pick a file"\n)')
  })

  observeEvent(input$showcase_file_input_set_content, {
    update_block_file_input(
      session, "showcase_file_input_preview",
      variant = "dropzone",
      dropzone_content = dropzone_content_example()
    )
    reactive_code(paste0(
      "update_block_file_input(\n",
      "  session = session,\n",
      "  input_id = \"showcase_file_input_preview\",\n",
      "  variant = \"dropzone\",\n",
      "  ", dropzone_content_example_code, "\n",
      ")"
    ))
  })

  observeEvent(input$showcase_file_input_clear_content, {
    update_block_file_input(session, "showcase_file_input_preview", dropzone_content = NULL)
    reactive_code('update_block_file_input(\n  session = session,\n  input_id = "showcase_file_input_preview",\n  dropzone_content = NULL\n)')
  })

  observeEvent(input$showcase_file_input_disable, {
    update_block_file_input(session, "showcase_file_input_preview", disabled = TRUE)
    reactive_code('update_block_file_input(\n  session = session,\n  input_id = "showcase_file_input_preview",\n  disabled = TRUE\n)')
  })

  observeEvent(input$showcase_file_input_enable, {
    update_block_file_input(session, "showcase_file_input_preview", disabled = FALSE)
    reactive_code('update_block_file_input(\n  session = session,\n  input_id = "showcase_file_input_preview",\n  disabled = FALSE\n)')
  })

  observeEvent(input$showcase_file_input_mark_invalid, {
    update_block_file_input(session, "showcase_file_input_preview", invalid = TRUE)
    reactive_code('update_block_file_input(\n  session = session,\n  input_id = "showcase_file_input_preview",\n  invalid = TRUE\n)')
  })

  observeEvent(input$showcase_file_input_clear_invalid, {
    update_block_file_input(session, "showcase_file_input_preview", invalid = FALSE)
    reactive_code('update_block_file_input(\n  session = session,\n  input_id = "showcase_file_input_preview",\n  invalid = FALSE\n)')
  })

  observeEvent(input$showcase_file_input_reset, {
    update_block_file_input(session, "showcase_file_input_preview", reset = TRUE)
    reactive_code('update_block_file_input(\n  session = session,\n  input_id = "showcase_file_input_preview",\n  reset = TRUE\n)')
  })
}

shinyApp(ui, server)

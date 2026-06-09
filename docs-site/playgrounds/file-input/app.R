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

ui <- block_page(
  title = "shinyblocks · File input playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::tags$div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      class = "showcase-playground",
      style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
      block_card(
        title = "Controls",
        class = "showcase-playground__controls",
        style = "flex: 1; min-width: 280px; max-width: 320px;",
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem;",
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
            block_field_label("dropzone label", `for` = "showcase_file_input_doc_dropzone_label"),
            block_input("showcase_file_input_doc_dropzone_label", value = "Drag files here or click to browse")
          ),
          block_field(
            block_field_label("dropzone hint", `for` = "showcase_file_input_doc_dropzone_hint"),
            block_input("showcase_file_input_doc_dropzone_hint", value = "", placeholder = "optional hint")
          ),
          block_field(
            block_field_label("placeholder", `for` = "showcase_file_input_doc_placeholder"),
            block_input("showcase_file_input_doc_placeholder", value = "No file selected")
          ),
          block_field(
            block_field_label("accept", `for` = "showcase_file_input_doc_accept"),
            block_input("showcase_file_input_doc_accept", value = ".csv,text/csv")
          ),
          block_field(
            block_field_label("multiple", `for` = "showcase_file_input_doc_multiple"),
            block_checkbox("showcase_file_input_doc_multiple", "Allow multiple files")
          ),
          block_field(
            block_field_label("disabled", `for` = "showcase_file_input_doc_disabled"),
            block_checkbox("showcase_file_input_doc_disabled", "Disabled")
          ),
          block_field(
            block_field_label("invalid", `for` = "showcase_file_input_doc_invalid"),
            block_checkbox("showcase_file_input_doc_invalid", "Invalid")
          )
        )
      ),
      htmltools::div(
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
        uiOutput("showcase_file_input_preview_code")
      )
    )
  )
)

server <- function(input, output, session) {
  file_input_args <- reactive({
    accept_value <- input$showcase_file_input_doc_accept %||% ".csv,text/csv"
    accept <- trimws(strsplit(accept_value, ",", fixed = TRUE)[[1]])
    accept <- accept[nzchar(accept)]
    if (!length(accept)) accept <- NULL

    dz_hint <- input$showcase_file_input_doc_dropzone_hint %||% ""
    if (!nzchar(dz_hint)) dz_hint <- NULL

    list(
      variant = input$showcase_file_input_doc_variant %||% "button",
      button_label = input$showcase_file_input_doc_button_label %||% "Browse",
      placeholder = input$showcase_file_input_doc_placeholder %||% "No file selected",
      dropzone_label = input$showcase_file_input_doc_dropzone_label %||% "Drag files here or click to browse",
      dropzone_hint = dz_hint,
      accept = accept,
      multiple = isTRUE(input$showcase_file_input_doc_multiple),
      disabled = isTRUE(input$showcase_file_input_doc_disabled),
      invalid = isTRUE(input$showcase_file_input_doc_invalid)
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
      disabled = args$disabled,
      invalid = args$invalid
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
    if (args$disabled) code_args <- c(code_args, "disabled = TRUE")
    if (args$invalid) code_args <- c(code_args, "invalid = TRUE")

    paste0("block_file_input(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_file_input_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)

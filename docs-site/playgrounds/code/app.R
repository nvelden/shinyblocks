if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)

  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch(
      {
        webr::mount("/packages", path)
        if ("shinyblocks" %in% installed.packages(lib.loc = "/packages")[, "Package"]) {
          mounted <- TRUE
          break
        }
      },
      error = function(e) {
        # Try the next path; Shinylive resolves mount URLs differently by host.
      }
    )
  }

  if (!mounted) {
    tryCatch(
      {
        webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
      },
      error = function(e) {
        stop("Failed to mount shinyblocks WASM package library: ", e$message)
      }
    )
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

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

# Sample snippet per language so the Code playground demonstrates the
# component's language-aware highlighting instead of one hardcoded example.
code_language_sample <- function(language) {
  samples <- list(
    r = paste(
      "plot_data <- function(x) {",
      "  # Simple summary for a Shiny dashboard",
      "  mean(x, na.rm = TRUE)",
      "}",
      "",
      "plot_data(c(12, 18, NA, 24))",
      sep = "\n"
    ),
    python = paste(
      "def greet(name):",
      "    # Build a friendly message",
      "    return f\"Hello, {name}!\"",
      "",
      "print(greet(\"world\"))",
      sep = "\n"
    ),
    javascript = paste(
      "function greet(name) {",
      "  // Build a friendly message",
      "  return `Hello, ${name}!`;",
      "}",
      "",
      "console.log(greet(\"world\"));",
      sep = "\n"
    ),
    typescript = paste(
      "function greet(name: string): string {",
      "  // Build a friendly message",
      "  return `Hello, ${name}!`;",
      "}",
      "",
      "console.log(greet(\"world\"));",
      sep = "\n"
    ),
    html = paste(
      "<!-- Page heading -->",
      "<section class=\"card\">",
      "  <h1 id=\"title\">Hello, world!</h1>",
      "  <a href=\"#start\">Get started</a>",
      "</section>",
      sep = "\n"
    ),
    css = paste(
      "/* Card surface */",
      ".card {",
      "  display: flex;",
      "  padding: 1rem;",
      "  color: var(--foreground);",
      "}",
      sep = "\n"
    ),
    json = paste(
      "{",
      "  \"name\": \"shinyblocks\",",
      "  \"version\": \"0.1.0\",",
      "  \"private\": true,",
      "  \"keywords\": [\"shiny\", \"shadcn\"]",
      "}",
      sep = "\n"
    ),
    sql = paste(
      "SELECT id, name, created_at",
      "FROM users",
      "WHERE active = TRUE",
      "ORDER BY created_at DESC",
      "LIMIT 10;",
      sep = "\n"
    ),
    bash = paste(
      "#!/usr/bin/env bash",
      "# Deploy the built assets",
      "for file in dist/*.js; do",
      "  echo \"Uploading $file\"",
      "done",
      sep = "\n"
    )
  )
  samples[[language]] %||% samples[["r"]]
}

language_choices <- c(
  "r",
  "python",
  "javascript",
  "typescript",
  "html",
  "css",
  "json",
  "sql",
  "bash"
)

ui <- block_page(
  title = "shinyblocks - Code playground",
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
            htmltools::tags$h4(
              class = "showcase-controls-group__title",
              "Content"
            ),
            block_field(
              block_field_label("language", `for` = "showcase_code_doc_language"),
              block_select(
                "showcase_code_doc_language",
                choices = language_choices,
                selected = "r",
                size = "sm"
              ),
              block_field_description(
                "The sample snippet updates to match the selected language."
              )
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(
              class = "showcase-controls-group__title",
              "State"
            ),
            block_field(
              block_field_label("header", `for` = "showcase_code_doc_header"),
              block_checkbox("showcase_code_doc_header", "Header with editor dots", value = FALSE)
            ),
            block_field(
              block_field_label("line_numbers", `for` = "showcase_code_doc_line_numbers"),
              block_checkbox("showcase_code_doc_line_numbers", "Line numbers", value = TRUE)
            ),
            block_field(
              block_field_label("copyable", `for` = "showcase_code_doc_copyable"),
              block_checkbox("showcase_code_doc_copyable", "Copy button", value = TRUE)
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(
              class = "showcase-controls-group__title",
              "Styling"
            ),
            block_field(
              block_field_label("variant", `for` = "showcase_code_doc_variant"),
              block_select(
                "showcase_code_doc_variant",
                choices = c("default", "outline"),
                selected = "default",
                size = "sm"
              )
            ),
            block_field(
              block_field_label("style", `for` = "showcase_code_doc_style"),
              block_textarea("showcase_code_doc_style", value = "", rows = 1, placeholder = "e.g., max-width: 400px;", resize = "none")
            ),
            block_field(
              block_field_label("class", `for` = "showcase_code_doc_class"),
              block_checkbox(
                "showcase_code_doc_class",
                "Use custom class (sb-code-custom)",
                value = FALSE
              )
            )
          )
        ),
        block_stack(
          gap = "lg",
          class = "showcase-playground__main",
          block_stack(
            gap = "sm",
            htmltools::tags$div(
              class = "showcase-playground__label",
              "Preview"
            ),
            htmltools::tags$div(
              style = paste(
                "position: relative; padding: 1.5rem; background: var(--card);",
                "border: 1px solid var(--border); border-radius: 0.75rem;",
                "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
              ),
              uiOutput("showcase_code_preview_ui")
            )
          ),
          htmltools::tags$div(
            htmltools::tags$div(
              class = "showcase-playground__label showcase-playground__label--code",
              "UI Definition"
            ),
            uiOutput("showcase_code_preview_code")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  preview_args <- reactive({
    language <- input$showcase_code_doc_language %||% "r"
    if (!nzchar(language)) language <- "r"
    code <- code_language_sample(language)
    style <- input$showcase_code_doc_style %||% ""
    list(
      code = code,
      language = language,
      header = isTRUE(input$showcase_code_doc_header),
      line_numbers = isTRUE(input$showcase_code_doc_line_numbers %||% TRUE),
      copyable = isTRUE(input$showcase_code_doc_copyable %||% TRUE),
      variant = input$showcase_code_doc_variant %||% "default",
      class = if (isTRUE(input$showcase_code_doc_class)) "sb-code-custom" else NULL,
      style = if (nzchar(style)) style else NULL
    )
  })

  output$showcase_code_preview_ui <- renderUI({
    args <- preview_args()
    block_code(
      code = args$code,
      language = args$language,
      copyable = args$copyable,
      header = args$header,
      line_numbers = args$line_numbers,
      variant = args$variant,
      class = args$class,
      style = args$style
    )
  })
  outputOptions(output, "showcase_code_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_code_preview_code <- showcase_render_code({
    args <- preview_args()
    code_args <- c(paste0("code = ", string_literal(args$code)))
    if (!identical(args$language, "r")) {
      code_args <- c(code_args, paste0("language = ", string_literal(args$language)))
    }
    if (!isTRUE(args$copyable)) code_args <- c(code_args, "copyable = FALSE")
    if (isTRUE(args$header)) code_args <- c(code_args, "header = TRUE")
    if (!isTRUE(args$line_numbers)) code_args <- c(code_args, "line_numbers = FALSE")
    if (!identical(args$variant, "default")) {
      code_args <- c(code_args, paste0("variant = ", string_literal(args$variant)))
    }
    if (!is.null(args$style)) {
      code_args <- c(code_args, paste0("style = ", string_literal(args$style)))
    }
    if (!is.null(args$class)) {
      code_args <- c(code_args, paste0("class = ", string_literal(args$class)))
    }
    paste0("block_code(\n  ", paste(code_args, collapse = ",\n  "), "\n)")
  })
  outputOptions(output, "showcase_code_preview_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)

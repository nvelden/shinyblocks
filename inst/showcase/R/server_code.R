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

register_code_showcase <- function(input, output, session) {
  output$showcase_code_preview_ui <- shiny::renderUI({
    lang_val <- input$showcase_code_doc_language %||% "r"
    if (!nzchar(lang_val)) lang_val <- "r"
    code_val <- code_language_sample(lang_val)

    style_val <- input$showcase_code_doc_style %||% ""
    if (!nzchar(style_val)) style_val <- NULL

    block_code(
      code = code_val,
      language = lang_val,
      copyable = isTRUE(input$showcase_code_doc_copyable),
      line_numbers = isTRUE(input$showcase_code_doc_line_numbers),
      header = isTRUE(input$showcase_code_doc_header),
      variant = input$showcase_code_doc_variant %||% "default",
      style = style_val,
      class = if (isTRUE(input$showcase_code_doc_class)) "sb-code-custom" else NULL
    )
  })
  shiny::outputOptions(
    output,
    "showcase_code_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_code_preview_code <- showcase_render_code({
    lang_val <- input$showcase_code_doc_language %||% "r"
    if (!nzchar(lang_val)) lang_val <- "r"
    code_val <- code_language_sample(lang_val)
    # Escape quotes and formatting for R string representation
    escaped_code <- gsub("\n", "\\\\n", gsub('"', '\\\\"', code_val))

    copyable_val <- input$showcase_code_doc_copyable
    line_numbers_val <- input$showcase_code_doc_line_numbers
    header_val <- input$showcase_code_doc_header
    variant_val <- input$showcase_code_doc_variant %||% "default"
    style_val <- input$showcase_code_doc_style %||% ""
    class_val <- input$showcase_code_doc_class

    args <- c(
      paste0('code = "', escaped_code, '"')
    )

    if (nzchar(lang_val)) {
      args <- c(args, paste0('language = "', lang_val, '"'))
    }
    if (!isTRUE(copyable_val)) {
      args <- c(args, "copyable = FALSE")
    }
    if (!isTRUE(line_numbers_val)) {
      args <- c(args, "line_numbers = FALSE")
    }
    if (isTRUE(header_val)) {
      args <- c(args, "header = TRUE")
    }
    if (variant_val != "default") {
      args <- c(args, paste0('variant = "', variant_val, '"'))
    }
    if (nzchar(style_val)) {
      args <- c(args, paste0('style = "', style_val, '"'))
    }
    if (isTRUE(class_val)) {
      args <- c(args, 'class = "sb-code-custom"')
    }

    paste0("block_code(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  shiny::outputOptions(
    output,
    "showcase_code_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_code_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("code", "language", "copyable", "line_numbers", "header", "variant", "class", "style"),
      Type = c("character", "character", "logical", "logical", "logical", "character", "character", "character"),
      Default = c("required", "NULL", "TRUE", "TRUE", "FALSE", "\"default\"", "NULL", "NULL"),
      Description = c(
        "The raw code string to display in the monospace block.",
        "Optional programming language label to show in the header bar.",
        "If TRUE, enables the dynamic copy-to-clipboard action button.",
        "If TRUE, displays dynamic line numbers in the left column margin.",
        "If TRUE, displays editor dots and the header bar.",
        "Visual variant container design theme. One of default or outline.",
        "Additional CSS custom stylesheet classes to apply.",
        "Inline CSS custom stylesheet style declarations."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_code_api_table",
    suspendWhenHidden = FALSE
  )
}

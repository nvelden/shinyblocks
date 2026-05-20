htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        style = "display: flex; gap: 2rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          style = "flex: 1; min-width: 300px; display: flex; flex-direction: column; gap: 1.5rem;",
          block_field(
            block_field_label("Preview", `for` = "showcase_code_preview"),
            shiny::uiOutput("showcase_code_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::verbatimTextOutput("showcase_code_preview_code")
            )
          )
        ),
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Content controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Content"),
            block_field(
              block_field_label("code", `for` = "showcase_code_doc_code"),
              block_textarea("showcase_code_doc_code", value = "npm install shinyblocks\n# or\ninstall.packages(\"shinyblocks\")", rows = 4)
            ),
            block_field(
              block_field_label("language", `for` = "showcase_code_doc_language"),
              block_textarea("showcase_code_doc_language", value = "bash", rows = 1)
            )
          ),
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 2rem;",
            # State controls
            htmltools::div(
              style = "display: flex; flex-direction: column; gap: 1rem;",
              htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "State"),
              block_field(
                block_field_label("header", `for` = "showcase_code_doc_header"),
                block_checkbox("showcase_code_doc_header", "Header (with terminal dots)", value = FALSE)
              ),
              block_field(
                block_field_label("line_numbers", `for` = "showcase_code_doc_line_numbers"),
                block_checkbox("showcase_code_doc_line_numbers", "Line numbers", value = TRUE)
              ),
              block_field(
                block_field_label("copyable", `for` = "showcase_code_doc_copyable"),
                block_checkbox("showcase_code_doc_copyable", "Copyable button", value = TRUE)
              )
            )
          ),
          # Styling controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Styling"),
            block_field(
              block_field_label("variant", `for` = "showcase_code_doc_variant"),
              block_select("showcase_code_doc_variant", choices = c("default", "outline"), selected = "default")
            ),
            block_field(
              block_field_label("style", `for` = "showcase_code_doc_style"),
              block_textarea("showcase_code_doc_style", value = "", rows = 1, placeholder = "e.g., max-width: 400px;")
            ),
            block_field(
              block_field_label("class", `for` = "showcase_code_doc_class"),
              block_checkbox("showcase_code_doc_class", "Use custom class (sb-code-custom)", value = FALSE)
            )
          )
        )
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_code_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance captured by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "padding: 1rem; border: 1px dashed var(--border); border-radius: 0.5rem;",
    block_code(
      code = "cat(\"Hello, Parity!\")",
      language = "R",
      copyable = TRUE,
      header = TRUE,
      variant = "default",
      class = "sb-parity-code-default"
    )
  )
)

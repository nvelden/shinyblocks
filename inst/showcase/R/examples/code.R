htmltools::tagList(
  showcase_playground_layout(
      controls = htmltools::tagList(
        showcase_controls_group(
          "Content", first = TRUE,
          block_field(
            block_field_label("code", `for` = "showcase_code_doc_code"),
            block_textarea(
              "showcase_code_doc_code",
              value = "plot_data <- function(x) {\n  # Simple summary for a Shiny dashboard\n  mean(x, na.rm = TRUE)\n}\n\nplot_data(c(12, 18, NA, 24))",
              rows = 6
            )
          ),
          block_field(
            block_field_label("language", `for` = "showcase_code_doc_language"),
            block_textarea("showcase_code_doc_language", value = "r", rows = 1)
          )
        ),
        showcase_controls_group(
          "State",
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
        showcase_controls_group(
          "Styling",
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
            block_textarea("showcase_code_doc_style", value = "", rows = 1, placeholder = "e.g., max-width: 400px;")
          ),
          block_field(
            block_field_label("class", `for` = "showcase_code_doc_class"),
            block_checkbox("showcase_code_doc_class", "Use custom class (sb-code-custom)", value = FALSE)
          )
        )
      ),
      preview_output_id = "showcase_code_preview_ui",
      code_output_id = "showcase_code_preview_code",
      preview_canvas_style = paste(
        "position: relative; padding: 1.5rem; background: var(--card);",
        "border: 1px solid var(--border); border-radius: 0.75rem;",
        "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
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

htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("trail depth", `for` = "showcase_breadcrumb_doc_depth"),
          block_select(
            "showcase_breadcrumb_doc_depth",
            choices = c("2", "3", "4"),
            selected = "3"
          )
        ),
        block_field(
          block_field_label("current page label", `for` = "showcase_breadcrumb_doc_current"),
          block_input("showcase_breadcrumb_doc_current", value = "Breadcrumb")
        ),
        block_field(
          block_field_label("ellipsis", `for` = "showcase_breadcrumb_doc_ellipsis"),
          block_checkbox(
            "showcase_breadcrumb_doc_ellipsis",
            "Collapse the middle with block_breadcrumb_ellipsis()",
            value = FALSE
          )
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("separator", `for` = "showcase_breadcrumb_doc_separator"),
          block_select(
            "showcase_breadcrumb_doc_separator",
            choices = c("chevron (default)" = "chevron", "slash" = "slash", "dot" = "dot"),
            selected = "chevron"
          )
        ),
        block_field(
          block_field_label("plain entry", `for` = "showcase_breadcrumb_doc_plain"),
          block_checkbox(
            "showcase_breadcrumb_doc_plain",
            "Render the first entry without href (plain text)",
            value = FALSE
          )
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("style", `for` = "showcase_breadcrumb_doc_style"),
          block_input(
            "showcase_breadcrumb_doc_style",
            value = "",
            placeholder = "e.g., font-family: var(--font-mono);"
          )
        ),
        block_field(
          block_field_label("class", `for` = "showcase_breadcrumb_doc_class"),
          block_checkbox(
            "showcase_breadcrumb_doc_class",
            "Use custom dashed-border class",
            value = FALSE
          )
        )
      )
    ),
    preview_output_id = "showcase_breadcrumb_preview_ui",
    code_output_id = "showcase_breadcrumb_preview_code"
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_breadcrumb_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance used by tools/parity/ and tools/theme/. Do not remove."
  ),
  block_breadcrumb(
    block_breadcrumb_item("Home", href = "#"),
    block_breadcrumb_ellipsis(),
    block_breadcrumb_item("Components", href = "#"),
    block_breadcrumb_item("Breadcrumb", current = TRUE),
    class = "sb-parity-breadcrumb-default"
  )
)

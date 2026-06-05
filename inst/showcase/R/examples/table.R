htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("dataset", `for` = "showcase_table_doc_dataset"),
          block_select(
            "showcase_table_doc_dataset",
            choices = c(
              "Revenue summary" = "revenue",
              "Release queue" = "releases",
              "Zero rows" = "empty"
            ),
            selected = "revenue",
            size = "sm"
          )
        ),
        block_field(
          block_field_label("caption", `for` = "showcase_table_doc_caption"),
          block_textarea(
            "showcase_table_doc_caption",
            value = "Monthly operating metrics.",
            rows = 2,
            resize = "none"
          )
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label("max_rows", `for` = "showcase_table_doc_max_rows"),
          block_select(
            "showcase_table_doc_max_rows",
            choices = c("All rows" = "all", "2 rows" = "2", "3 rows" = "3"),
            selected = "all",
            size = "sm"
          )
        ),
        block_field(
          block_field_label("numeric alignment", `for` = "showcase_table_doc_align"),
          block_select(
            "showcase_table_doc_align",
            choices = c("left", "center", "right"),
            selected = "right",
            size = "sm"
          )
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("style", `for` = "showcase_table_doc_style"),
          block_textarea(
            "showcase_table_doc_style",
            value = "",
            rows = 1,
            placeholder = "e.g., max-width: 520px;",
            resize = "none"
          )
        ),
        block_field(
          block_field_label("class", `for` = "showcase_table_doc_class"),
          block_checkbox(
            "showcase_table_doc_class",
            "Use custom dashed-border class",
            value = FALSE
          )
        )
      )
    ),
    preview_output_id = "showcase_table_preview_ui",
    code_output_id = "showcase_table_preview_code",
    preview_canvas_style = paste(
      "position: relative; padding: 1.5rem; background: var(--card);",
      "border: 1px solid var(--border); border-radius: 0.75rem;",
      "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);",
      "overflow-x: auto;"
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_table_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance used by tools/parity/ and tools/theme/. Do not remove."
  ),
  htmltools::div(
    style = "padding: 1rem; border: 1px dashed var(--border); border-radius: 0.5rem;",
    block_table(
      data.frame(
        metric = c("Revenue", "Orders", "Conversion"),
        value = c("$42k", "128", "4.8%")
      ),
      columns = list(
        value = table_column(label = "Value", align = "right")
      ),
      caption = "Table parity fixture.",
      class = "sb-parity-table"
    )
  )
)

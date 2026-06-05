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
        ),
        block_field(
          block_field_label("na", `for` = "showcase_table_doc_na"),
          block_input(
            "showcase_table_doc_na",
            value = "",
            placeholder = "e.g. —"
          )
        ),
        block_field(
          block_field_label("digits", `for` = "showcase_table_doc_digits"),
          block_select(
            "showcase_table_doc_digits",
            choices = c("default" = "default", "0" = "0", "1" = "1", "2" = "2"),
            selected = "default",
            size = "sm"
          )
        ),
        block_field(
          block_checkbox(
            "showcase_table_doc_rownames",
            "Show row names",
            value = FALSE
          )
        ),
        block_field(
          block_checkbox(
            "showcase_table_doc_rowformat",
            "Highlight rows where value > 100 (row_format)",
            value = FALSE
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
          block_checkbox(
            "showcase_table_doc_class",
            "Use custom dashed-border class",
            value = FALSE
          )
        )
      ),
      showcase_controls_group(
        "Server actions",
        htmltools::tags$p(
          style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.8125rem;",
          "Each control pushes a fresh payload with update_block_table()."
        ),
        htmltools::div(
          style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
          block_button(
            "Toggle loading",
            id = "showcase_table_act_loading",
            variant = "outline",
            size = "sm"
          ),
          block_button(
            "Toggle filtered subset",
            id = "showcase_table_act_filter",
            variant = "outline",
            size = "sm"
          ),
          block_button(
            "Toggle striped",
            id = "showcase_table_act_striped",
            variant = "outline",
            size = "sm"
          ),
          block_button(
            "Toggle bordered",
            id = "showcase_table_act_bordered",
            variant = "outline",
            size = "sm"
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
    ),
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_table_preview_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "Server Action"
        ),
        shiny::uiOutput("showcase_table_reactive_code")
      )
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_table_api_table"),
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

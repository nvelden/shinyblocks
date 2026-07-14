htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content",
        first = TRUE,
        block_field(
          block_field_label("pages", `for` = "showcase_pagination_pages"),
          block_input(
            "showcase_pagination_pages",
            value = "20",
            type = "number"
          )
        ),
        block_field(
          block_field_label("selected", `for` = "showcase_pagination_selected"),
          block_input(
            "showcase_pagination_selected",
            value = "8",
            type = "number"
          )
        )
      ),
      showcase_controls_group(
        "State",
        block_field(
          block_field_label(
            "sibling_count",
            `for` = "showcase_pagination_siblings"
          ),
          block_input(
            "showcase_pagination_siblings",
            value = "1",
            type = "number"
          )
        ),
        block_checkbox(
          "showcase_pagination_edges",
          "Show edge pages",
          value = TRUE
        ),
        block_checkbox(
          "showcase_pagination_disabled",
          "Disabled",
          value = FALSE
        )
      ),
      showcase_controls_group(
        "Actions",
        showcase_action_button("showcase_pagination_first", "First page"),
        showcase_action_button("showcase_pagination_last", "Last page")
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("class", `for` = "showcase_pagination_class"),
          block_checkbox(
            "showcase_pagination_class",
            "Use custom class",
            value = FALSE
          )
        )
      )
    ),
    preview_output_id = "showcase_pagination_preview_ui",
    code_output_id = "showcase_pagination_preview_code",
    extra_outputs = htmltools::tagList(
      shiny::uiOutput("showcase_pagination_value"),
      htmltools::tags$div(
        htmltools::tags$div(
          class = "showcase-playground__label showcase-playground__label--code",
          "Server Action"
        ),
        shiny::uiOutput("showcase_pagination_action_code")
      )
    )
  ),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "API Reference"
  ),
  shiny::uiOutput("showcase_pagination_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixture"
  ),
  block_pagination(
    "showcase_pagination_parity",
    pages = 10,
    selected = 5,
    class = "sb-parity-pagination-active"
  )
)

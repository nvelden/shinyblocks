htmltools::tagList(
  block_field_set(
    block_field_legend("Common patterns"),
    htmltools::div(
      style = "display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.25rem;",
      block_field(
        block_field_label("Leading icon", `for` = "showcase_input_group_search"),
        block_input_group(
          block_input_group_addon(block_icon("search")),
          block_input(
            "showcase_input_group_search",
            placeholder = "Search workspace"
          )
        ),
        block_field_description("Single leading addon with an icon.")
      ),
      block_field(
        block_field_label("Trailing icon", `for` = "showcase_input_group_email"),
        block_input_group(
          block_input(
            "showcase_input_group_email",
            placeholder = "name@company.com"
          ),
          block_input_group_addon(block_icon("mail"))
        ),
        block_field_description("Trailing addon by placing the icon after the input.")
      ),
      block_field(
        block_field_label("Both addons", `for` = "showcase_input_group_amount"),
        block_input_group(
          block_input_group_addon("$"),
          block_input(
            "showcase_input_group_amount",
            type = "number",
            value = 0,
            placeholder = "0"
          ),
          block_input_group_addon("USD")
        ),
        block_field_description("Leading and trailing text addons.")
      ),
      block_field(
        block_field_label("Workspace slug", `for` = "showcase_input_group_slug"),
        block_input_group(
          block_input_group_addon("acme.app/"),
          block_input(
            "showcase_input_group_slug",
            placeholder = "your-team"
          )
        ),
        block_field_description("Text prefix without an icon.")
      )
    )
  ),
  block_field_set(
    block_field_legend("Invalid state"),
    block_field_invalid(
      block_field(
        block_field_label("API key", `for` = "showcase_input_group_api"),
        block_input_group(
          block_input_group_addon(block_icon("lock")),
          block_input(
            "showcase_input_group_api",
            value = "sk-test",
            invalid = TRUE
          )
        ),
        block_field_description("Production keys must start with sk-live-.")
      ),
      "API keys must start with sk-live-."
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_input_group_api_table")
)

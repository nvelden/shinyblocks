htmltools::tagList(
  block_field_group(
    block_field(
      block_field_label("Email", `for` = "showcase_email"),
      shiny::textInput(
        "showcase_email",
        NULL,
        placeholder = "name@company.com"
      ),
      block_field_description("Used for login and product updates.")
    ),
    block_field(
      block_field_label("Workspace", `for` = "showcase_workspace"),
      block_input_group(
        block_input_group_addon(block_icon("search")),
        shiny::textInput("showcase_workspace", NULL, placeholder = "acme")
      ),
      block_field_description("Your public workspace slug.")
    )
  ),
  block_field_set(
    block_field_legend("Notification defaults"),
    block_field_group(
      block_field(
        block_field_label("Plan", `for` = "showcase_plan"),
        block_select(
          "showcase_plan",
          choices = c("Free", "Pro", "Enterprise")
        ),
        block_field_description("Controls usage limits and support access.")
      ),
      block_field_invalid(
        block_field(
          block_field_label("API key", `for` = "showcase_api_key"),
          shiny::textInput("showcase_api_key", NULL, value = "sk-test"),
          block_field_description("Paste a live key to continue.")
        ),
        "API keys must start with sk-live-."
      )
    )
  )
)

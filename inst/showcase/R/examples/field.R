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
      ),
      block_field(
        block_field_label("Internal note", `for` = "showcase_note"),
        block_textarea(
          "showcase_note",
          placeholder = "Record rollout details for the next operator."
        ),
        block_field_description("Stored with the current workspace.")
      ),
      block_field(
        block_checkbox(
          "showcase_marketing",
          "Email me product updates",
          value = TRUE
        ),
        block_field_description("Optional outbound product communication.")
      ),
      block_field(
        block_switch(
          "showcase_incidents",
          "Send incident alerts",
          value = TRUE
        ),
        block_field_description(
          "Immediate notifications for production issues."
        )
      )
    )
  )
)

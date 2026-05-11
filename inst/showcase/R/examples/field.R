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
          placeholder = "Record rollout details for the next operator.",
          class = "sb-parity-textarea-default"
        ),
        block_field_description("Stored with the current workspace.")
      ),
      block_field(
        block_field_label("Runbook", `for` = "showcase_runbook"),
        block_textarea(
          "showcase_runbook",
          value = "Escalate to the on-call operator if retries fail.",
          rows = 2,
          disabled = TRUE,
          class = "sb-parity-textarea-disabled"
        ),
        block_field_description("Disabled textarea state.")
      ),
      block_field_invalid(
        block_field(
          block_field_label("Rollback plan", `for` = "showcase_rollback"),
          block_textarea(
            "showcase_rollback",
            value = "Document rollback steps before continuing.",
            class = "sb-parity-textarea-invalid"
          ),
          block_field_description("Invalid textarea state.")
        ),
        "A rollback plan is required before deployment."
      ),
      block_field(
        block_checkbox(
          "showcase_marketing",
          "Email me product updates",
          value = FALSE,
          class = "sb-parity-checkbox-default"
        ),
        block_field_description("Unchecked default checkbox state.")
      ),
      block_field(
        block_checkbox(
          "showcase_beta",
          "Join beta releases",
          value = TRUE,
          class = "sb-parity-checkbox-checked"
        ),
        block_field_description("Checked checkbox state.")
      ),
      block_field(
        block_checkbox(
          "showcase_marketing_disabled",
          "Paused notifications",
          value = FALSE,
          disabled = TRUE,
          class = "sb-parity-checkbox-disabled"
        ),
        block_field_description("Disabled checkbox state.")
      ),
      block_field(
        block_switch(
          "showcase_incidents",
          "Send incident alerts",
          value = FALSE,
          class = "sb-parity-switch-default"
        ),
        block_field_description("Off/default switch state.")
      ),
      block_field(
        block_switch(
          "showcase_auto_resolve",
          "Auto-resolve low-severity pages",
          value = TRUE,
          class = "sb-parity-switch-checked"
        ),
        block_field_description(
          "On/checked switch state."
        )
      ),
      block_field(
        block_switch(
          "showcase_switch_disabled",
          "Mute low-priority alerts",
          value = FALSE,
          disabled = TRUE,
          class = "sb-parity-switch-disabled"
        ),
        block_field_description(
          "Disabled switch state."
        )
      )
    )
  )
)

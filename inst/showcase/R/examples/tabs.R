htmltools::tagList(
  block_tabs(
    id = "showcase_tabs",
    selected = "overview",
    block_tab(
      "Overview",
      value = "overview",
      block_card(
        title = "Workspace",
        description = "Manage the default workspace state for this app.",
        block_field_group(
          block_field(
            block_field_label("Name", `for` = "tabs_workspace_name"),
            shiny::textInput("tabs_workspace_name", NULL, "Acme"),
            block_field_description("Used in the sidebar and header shell.")
          ),
          block_field(
            block_field_label("Plan", `for` = "tabs_workspace_plan"),
            block_select(
              "tabs_workspace_plan",
              NULL,
              choices = c("Starter", "Pro", "Enterprise"),
              selected = "Pro"
            )
          )
        )
      )
    ),
    block_tab(
      "Usage",
      value = "usage",
      block_card(
        title = "Members",
        description = "This content stays reactive through the tab input.",
        htmltools::div(
          style = "display: grid; gap: 0.75rem;",
          block_alert(
            title = "Invites enabled",
            description = "Team members can invite collaborators."
          ),
          block_value_box(
            title = "Active seats",
            value = "14",
            description = "2 seats remaining on the current plan."
          )
        )
      )
    ),
    block_tab(
      "Settings",
      value = "settings",
      block_card(
        title = "Billing",
        description = "Persist actions without leaving the current tab.",
        htmltools::div(
          style = "display: flex; gap: 0.75rem; flex-wrap: wrap;",
          block_button("Save changes"),
          block_button("Cancel", variant = "outline")
        )
      )
    )
  ),
  block_tabs(
    id = "showcase_tabs_line",
    selected = "account",
    variant = "line",
    block_tab(
      "Account",
      value = "account",
      block_card(
        title = "Account",
        description = "Line variant tabs use the underline treatment."
      )
    ),
    block_tab(
      "Security",
      value = "security",
      block_card(
        title = "Security",
        description = "Selection still feeds the Shiny input binding."
      )
    )
  )
)

register_tabs_showcase <- function(input, output, session) {
  # Dynamic preview rendering
  output$showcase_tabs_preview_ui <- shiny::renderUI({
    variant <- input$showcase_tabs_doc_variant %||% "default"
    orientation <- input$showcase_tabs_doc_orientation %||% "horizontal"
    selected <- input$showcase_tabs_doc_selected %||% "overview"
    
    block_tabs(
      id = "showcase_tabs_interactive",
      selected = selected,
      variant = variant,
      orientation = orientation,
      block_tab(
        "Overview",
        value = "overview",
        block_card(
          title = "Workspace Overview",
          description = "Manage default workspace state.",
          "This is the dashboard overview tab."
        )
      ),
      block_tab(
        "Usage",
        value = "usage",
        block_card(
          title = "Members & Usage",
          description = "Reactive seats and collaborators.",
          "Check active seats and remaining billing credits."
        )
      ),
      block_tab(
        "Settings",
        value = "settings",
        block_card(
          title = "Billing & Settings",
          description = "Persist plans and billing preferences.",
          "Configure enterprise accounts."
        )
      )
    )
  })
  shiny::outputOptions(
    output,
    "showcase_tabs_preview_ui",
    suspendWhenHidden = FALSE
  )

  # Dynamic code snippet rendering
  output$showcase_tabs_preview_code <- showcase_render_code({
    selected_val <- input$showcase_tabs_doc_selected %||% "overview"
    variant_val <- input$showcase_tabs_doc_variant %||% "default"
    orientation_val <- input$showcase_tabs_doc_orientation %||% "horizontal"

    paste0(
      "block_tabs(\n",
      "  id = \"showcase_tabs_interactive\",\n",
      "  selected = \"", selected_val, "\",\n",
      "  variant = \"", variant_val, "\",\n",
      "  orientation = \"", orientation_val, "\",\n",
      "  block_tab(\n",
      "    \"Overview\",\n",
      "    value = \"overview\",\n",
      "    block_card(title = \"Workspace Overview\", ...)\n",
      "  ),\n",
      "  block_tab(\n",
      "    \"Usage\",\n",
      "    value = \"usage\",\n",
      "    block_card(title = \"Members & Usage\", ...)\n",
      "  ),\n",
      "  block_tab(\n",
      "    \"Settings\",\n",
      "    value = \"settings\",\n",
      "    block_card(title = \"Billing & Settings\", ...)\n",
      "  )\n",
      ")"
    )
  })
  shiny::outputOptions(
    output,
    "showcase_tabs_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_tabs_preview_value <- showcase_render_code({
    value <- input$showcase_tabs_interactive
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (!nzchar(value)) {
      "<EMPTY>"
    } else {
      value
    }
    paste0("input$showcase_tabs_interactive = ", val_str)
  })
  shiny::outputOptions(
    output,
    "showcase_tabs_preview_value",
    suspendWhenHidden = FALSE
  )

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_tabs() code here."
  ))

  output$showcase_tabs_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_tabs_reactive_code",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_tabs_select_usage, {
    update_block_tabs(session, "showcase_tabs_interactive", selected = "usage")
    update_block_select(session, "showcase_tabs_doc_selected", selected = "usage")
    reactive_code(paste0(
      "update_block_tabs(\n",
      "  session = session,\n",
      "  input_id = \"showcase_tabs_interactive\",\n",
      "  selected = \"usage\"\n",
      ")"
    ))
  })

  shiny::observeEvent(input$showcase_tabs_select_settings, {
    update_block_tabs(session, "showcase_tabs_interactive", selected = "settings")
    update_block_select(session, "showcase_tabs_doc_selected", selected = "settings")
    reactive_code(paste0(
      "update_block_tabs(\n",
      "  session = session,\n",
      "  input_id = \"showcase_tabs_interactive\",\n",
      "  selected = \"settings\"\n",
      ")"
    ))
  })

  # API reference table
  output$showcase_tabs_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("...", "id", "selected", "variant", "orientation", "class", "update_block_tabs()"),
      Type = c("block_tab() tags", "character", "character", "character", "character", "character", "function"),
      Default = c("required", "NULL", "NULL", "'default'", "'horizontal'", "NULL", "selected required"),
      Description = c(
        "List of block_tab() child elements.",
        "Optional input ID to bind active tab changes to the Shiny server.",
        "Optional value/title of the tab to select by default.",
        "Visual style variant: 'default' or 'line'.",
        "Layout orientation: 'horizontal' or 'vertical'.",
        "Additional CSS class merged onto the tabs container.",
        "Server updater for selecting an active tab by value."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_tabs_api_table",
    suspendWhenHidden = FALSE
  )
}

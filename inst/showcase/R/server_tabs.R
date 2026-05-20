register_tabs_showcase <- function(input, output, session) {
  # Server-side reactive log of tab changes
  output$showcase_tabs_reactive_log <- shiny::renderText({
    current_tab <- input$showcase_tabs_interactive %||% "overview"
    paste0("Active tab reported by server: \"", current_tab, "\"")
  })

  # Dynamic preview rendering
  output$showcase_tabs_preview_ui <- shiny::renderUI({
    variant <- input$showcase_tabs_doc_variant %||% "default"
    orientation <- input$showcase_tabs_doc_orientation %||% "horizontal"
    
    block_tabs(
      id = "showcase_tabs_interactive",
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
    variant_val <- input$showcase_tabs_doc_variant %||% "default"
    orientation_val <- input$showcase_tabs_doc_orientation %||% "horizontal"

    paste0(
      "block_tabs(\n",
      "  id = \"showcase_tabs_interactive\",\n",
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

  # API reference table
  output$showcase_tabs_api_table <- shiny::renderTable({
    data.frame(
      Argument = c("...", "id", "selected", "variant", "orientation", "class"),
      Type = c("block_tab() tags", "character", "character", "character", "character", "character"),
      Default = c("required", "NULL", "NULL", "'default'", "'horizontal'", "NULL"),
      Description = c(
        "List of block_tab() child elements.",
        "Optional input ID to bind active tab changes to the Shiny server.",
        "Optional value/title of the tab to select by default.",
        "Visual style variant: 'default' or 'line'.",
        "Layout orientation: 'horizontal' or 'vertical'.",
        "Additional CSS class merged onto the tabs container."
      )
    )
  }, width = "100%", align = "llll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_tabs_api_table",
    suspendWhenHidden = FALSE
  )
}

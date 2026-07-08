htmltools::tagList(
  htmltools::tags$section(
    `aria-label` = "Interactive Playground",
    showcase_playground_layout(
      controls = htmltools::tagList(
        showcase_controls_group(
          "Content", first = TRUE,
          block_field(
            block_field_label("trigger label", `for` = "showcase_dropdown_menu_doc_trigger"),
            block_input("showcase_dropdown_menu_doc_trigger", value = "Open menu")
          ),
          block_field(
            block_field_label("show icons", `for` = "showcase_dropdown_menu_doc_icons"),
            block_checkbox("showcase_dropdown_menu_doc_icons", "Leading item icons", value = TRUE)
          ),
          block_field(
            block_field_label("show shortcuts", `for` = "showcase_dropdown_menu_doc_shortcuts"),
            block_checkbox("showcase_dropdown_menu_doc_shortcuts", "Shortcut hints", value = TRUE)
          ),
          block_field(
            block_field_label("destructive item", `for` = "showcase_dropdown_menu_doc_destructive"),
            block_checkbox("showcase_dropdown_menu_doc_destructive", "Include a destructive \"Delete\" item", value = TRUE)
          )
        ),
        showcase_controls_group(
          "State",
          block_field(
            block_field_label("disabled item", `for` = "showcase_dropdown_menu_doc_disable_item"),
            block_checkbox("showcase_dropdown_menu_doc_disable_item", "Disable the \"Billing\" item", value = FALSE)
          ),
          block_field(
            block_field_label("disabled", `for` = "showcase_dropdown_menu_doc_disabled"),
            block_checkbox("showcase_dropdown_menu_doc_disabled", "Disable the trigger", value = FALSE)
          )
        ),
        showcase_controls_group(
          "Actions (Server Update)",
          block_cluster(
            gap = "sm",
            showcase_action_button("showcase_dropdown_menu_open", "Open"),
            showcase_action_button("showcase_dropdown_menu_close", "Close"),
            showcase_action_button("showcase_dropdown_menu_replace", "Replace items"),
            showcase_action_button("showcase_dropdown_menu_disable", "Disable"),
            showcase_action_button("showcase_dropdown_menu_enable", "Enable")
          )
        ),
        showcase_controls_group(
          "Styling",
          block_field(
            block_field_label("trigger_variant", `for` = "showcase_dropdown_menu_doc_variant"),
            block_select("showcase_dropdown_menu_doc_variant", choices = c("outline", "default", "secondary", "ghost"), selected = "outline", size = "sm")
          ),
          block_field(
            block_field_label("side", `for` = "showcase_dropdown_menu_doc_side"),
            block_select("showcase_dropdown_menu_doc_side", choices = c("bottom", "top", "left", "right"), selected = "bottom", size = "sm")
          ),
          block_field(
            block_field_label("align", `for` = "showcase_dropdown_menu_doc_align"),
            block_select("showcase_dropdown_menu_doc_align", choices = c("start", "center", "end"), selected = "start", size = "sm")
          ),
          block_field(
            block_field_label("style", `for` = "showcase_dropdown_menu_doc_style"),
            block_input("showcase_dropdown_menu_doc_style", value = "", placeholder = "e.g., min-width: 16rem;")
          )
        )
      ),
      preview_output_id = "showcase_dropdown_menu_preview_ui",
      code_output_id = "showcase_dropdown_menu_preview_code",
      extra_outputs = htmltools::tagList(
        shiny::uiOutput("showcase_dropdown_menu_preview_value"),
        htmltools::tags$div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "Server Action"
          ),
          shiny::uiOutput("showcase_dropdown_menu_reactive_code")
        )
      ),
      preview_canvas_class = "showcase-preview-canvas--muted",
      preview_canvas_style = "min-height: 180px;"
    )
  ),
  htmltools::tags$div(
    style = "display: none;",
    block_dropdown_menu(
      "Static fallback",
      dropdown_menu_label("Account"),
      dropdown_menu_item("profile", "Profile"),
      dropdown_menu_separator(),
      dropdown_menu_item("logout", "Log out", variant = "destructive")
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_dropdown_menu_api_table")
)

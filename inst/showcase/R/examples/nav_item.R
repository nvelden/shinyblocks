htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Navigation Settings", first = TRUE,
        block_field(
          block_field_label("label", `for` = "showcase_nav_item_doc_label"),
          block_textarea("showcase_nav_item_doc_label", value = "Home", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("href", `for` = "showcase_nav_item_doc_href"),
          block_textarea("showcase_nav_item_doc_href", value = "#", rows = 1, resize = "none")
        ),
        block_field(
          block_field_label("icon", `for` = "showcase_nav_item_doc_icon"),
          block_select("showcase_nav_item_doc_icon", choices = c("home", "file-text", "users", "settings", "none"), selected = "home", size = "sm")
        )
      ),
      showcase_controls_group(
        "State & Styling",
        block_field(
          block_field_label("selected", `for` = "showcase_nav_item_doc_selected"),
          block_checkbox("showcase_nav_item_doc_selected", label = "Set active/selected", value = TRUE)
        ),
        block_field(
          block_field_label("class", `for` = "showcase_nav_item_doc_class"),
          block_checkbox("showcase_nav_item_doc_class", label = "Use emphasized class", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_nav_item_preview_ui",
    code_output_id = "showcase_nav_item_preview_code",
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: center; justify-content: center;",
      "padding: 2rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
      "border: 0; border-radius: 0.75rem; min-height: 220px; box-sizing: border-box;"
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_nav_item_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    class = "sb-parity-nav-baseline",
    style = "background: var(--sidebar); color: var(--sidebar-foreground); padding: 0.75rem; border-radius: 0.5rem; max-width: 18rem;",
    block_nav(
      class = "sb-sidebar-nav",
      block_nav_item("Home", icon = "home", selected = TRUE),
      block_nav_item("Reports", icon = "file-text"),
      block_nav_item("Users", icon = "users"),
      block_nav_item("Settings", icon = "settings")
    )
  )
)

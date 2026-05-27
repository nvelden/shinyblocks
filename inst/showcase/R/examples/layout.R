htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Header & Sidebar", first = TRUE,
        block_field(
          block_field_label("header title", `for` = "showcase_layout_doc_title"),
          block_textarea("showcase_layout_doc_title", value = "Admin Dashboard", rows = 1)
        ),
        block_field(
          block_field_label("sidebar title", `for` = "showcase_layout_doc_sidebar_title"),
          block_textarea("showcase_layout_doc_sidebar_title", value = "Acme Corp", rows = 1)
        ),
        block_field(
          block_field_label("profile avatar", `for` = "showcase_layout_doc_profile"),
          block_checkbox("showcase_layout_doc_profile", label = "Show profile avatar", value = TRUE)
        ),
        block_field(
          block_field_label("profile label", `for` = "showcase_layout_doc_profile_label"),
          block_textarea("showcase_layout_doc_profile_label", value = "NV", rows = 1)
        )
      ),
      showcase_controls_group(
        "Sidebar State",
        block_field(
          block_field_label("collapsible", `for` = "showcase_layout_doc_collapsible"),
          block_checkbox("showcase_layout_doc_collapsible", label = "Enable sidebar toggle button", value = TRUE)
        ),
        block_field(
          block_field_label("collapsed", `for` = "showcase_layout_doc_collapsed"),
          block_checkbox("showcase_layout_doc_collapsed", label = "Sidebar starts collapsed", value = FALSE)
        )
      )
    ),
    preview_output_id = "showcase_layout_preview_ui",
    code_output_id = "showcase_layout_preview_code",
    preview_canvas_style = paste(
      "position: relative; display: flex; align-items: stretch; justify-content: stretch;",
      "padding: 1rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
      "border: 0; border-radius: 0.75rem; min-height: 332px; box-sizing: border-box;"
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::tableOutput("showcase_layout_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    class = "sb-parity-layout-baseline",
    style = "display: flex; flex-direction: column; gap: 0.75rem;",
    htmltools::tags$p(
      "The page you are viewing is itself built with shinyblocks. ",
      htmltools::tags$code("block_page()"),
      " wraps the document, ",
      htmltools::tags$code("block_sidebar()"),
      " on the left holds the ",
      htmltools::tags$code("block_nav_item()"),
      " links, ",
      htmltools::tags$code("block_header()"),
      " is the bar at the top, and the gallery sections below sit inside ",
      htmltools::tags$code("block_body()"),
      "."
    ),
    htmltools::tags$p(
      "This showcase also enables ",
      htmltools::tags$code("block_sidebar(collapsible = TRUE)"),
      ", so the desktop sidebar can be collapsed and the mobile trigger",
      " opens it as a sheet."
    )
  )
)

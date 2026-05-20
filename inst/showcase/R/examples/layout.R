htmltools::tagList(
  block_field_set(
    block_field_legend("Interactive Playground"),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1.5rem;",
      htmltools::div(
        style = "display: flex; gap: 2rem; flex-wrap: wrap; align-items: flex-start;",
        htmltools::div(
          style = "flex: 1; min-width: 300px; display: flex; flex-direction: column; gap: 1.5rem;",
          block_field(
            block_field_label("Mini Mock Layout Preview", `for` = "showcase_layout_preview"),
            shiny::uiOutput("showcase_layout_preview_ui")
          ),
          htmltools::tags$div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$div(
              htmltools::tags$div(style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;", "UI Definition"),
              shiny::uiOutput("showcase_layout_preview_code")
            )
          )
        ),
        htmltools::div(
          style = "flex: 2; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; background: var(--muted); padding: 1.5rem; border-radius: 0.5rem;",
          # Controls
          htmltools::div(
            style = "display: flex; flex-direction: column; gap: 1rem;",
            htmltools::tags$h3(style = "font-size: 0.875rem; font-weight: 600; margin: 0; color: var(--foreground);", "Header & Sidebar Settings"),
            block_field(
              block_field_label("header title", `for` = "showcase_layout_doc_title"),
              block_textarea("showcase_layout_doc_title", value = "Admin Dashboard", rows = 1)
            ),
            block_field(
              block_field_label("sidebar title", `for` = "showcase_layout_doc_sidebar_title"),
              block_textarea("showcase_layout_doc_sidebar_title", value = "Acme Corp", rows = 1)
            ),
            block_field(
              block_field_label("collapsible", `for` = "showcase_layout_doc_collapsible"),
              block_checkbox("showcase_layout_doc_collapsible", label = "Enable sidebar toggle button", value = TRUE)
            ),
            block_field(
              block_field_label("collapsed", `for` = "showcase_layout_doc_collapsed"),
              block_checkbox("showcase_layout_doc_collapsed", label = "Sidebar starts collapsed", value = FALSE)
            )
          )
        )
      )
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

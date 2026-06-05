htmltools::tagList(
  showcase_playground_layout(
    controls = htmltools::tagList(
      showcase_controls_group(
        "Content", first = TRUE,
        block_field(
          block_field_label("name", `for` = "showcase_icon_doc_name"),
          block_select(
            "showcase_icon_doc_name",
            choices = sort(shinyblocks:::shinyblocks_icon_names()),
            selected = "home"
          )
        )
      ),
      showcase_controls_group(
        "Styling",
        block_field(
          block_field_label("size", `for` = "showcase_icon_doc_size"),
          block_select("showcase_icon_doc_size", choices = c("sm", "default", "lg", "xl"), selected = "default", size = "sm")
        ),
        block_field(
          block_field_label("color", `for` = "showcase_icon_doc_color"),
          block_select(
            "showcase_icon_doc_color",
            choices = shinyblocks:::semantic_color_choices(),
            selected = "default",
            size = "sm"
          )
        )
      )
    ),
    preview_output_id = "showcase_icon_preview_ui",
    code_output_id = "showcase_icon_preview_code"
  ),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    paste0("All icons (", length(shinyblocks:::shinyblocks_icon_names()), ")")
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.75rem 0; font-size: 0.875rem;",
    "Hover an icon to see its name. Pass the name to ", htmltools::tags$code("block_icon()"), "."
  ),
  htmltools::div(
    style = paste(
      "display: grid;",
      "grid-template-columns: repeat(auto-fill, minmax(64px, 1fr));",
      "gap: 0.5rem;",
      "padding: 1rem;",
      "background: var(--muted);",
      "border-radius: 0.5rem;"
    ),
    lapply(sort(shinyblocks:::shinyblocks_icon_names()), function(nm) {
      htmltools::tags$div(
        title = nm,
        style = paste(
          "display: flex; flex-direction: column; align-items: center; gap: 0.25rem;",
          "padding: 0.5rem; border-radius: calc(var(--radius) * 0.8);",
          "background: var(--background); color: var(--foreground);",
          "font-size: 0.625rem; color: var(--muted-foreground);",
          "overflow: hidden; text-overflow: ellipsis;"
        ),
        block_icon(nm, style = "width: 1.25rem; height: 1.25rem;"),
        htmltools::tags$span(
          style = "max-width: 100%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;",
          nm
        )
      )
    })
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "API Reference"),
  shiny::uiOutput("showcase_icon_api_table"),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances used by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; gap: 1rem; flex-wrap: wrap; align-items: center;",
    block_icon("home", class = "sb-parity-icon-home"),
    block_icon("settings", class = "sb-parity-icon-settings")
  )
)

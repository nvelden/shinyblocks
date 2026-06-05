register_layout_showcase <- function(input, output, session) {
  collapsed_state <- shiny::reactiveVal(FALSE)

  shiny::observeEvent(input$showcase_layout_doc_collapsed, {
    collapsed_state(isTRUE(input$showcase_layout_doc_collapsed))
  }, ignoreInit = FALSE)

  shiny::observeEvent(input$showcase_layout_preview_toggle, {
    if (isTRUE(input$showcase_layout_doc_collapsible)) {
      collapsed_state(!isTRUE(collapsed_state()))
    }
  })

  output$showcase_layout_preview_ui <- shiny::renderUI({
    title <- input$showcase_layout_doc_title %||% "Admin Dashboard"
    sidebar_title <- input$showcase_layout_doc_sidebar_title %||% "Acme Corp"
    collapsible <- isTRUE(input$showcase_layout_doc_collapsible)
    collapsed <- if (collapsible) isTRUE(collapsed_state()) else FALSE
    show_profile <- isTRUE(input$showcase_layout_doc_profile)
    profile_label <- input$showcase_layout_doc_profile_label %||% "NV"
    profile_label <- trimws(profile_label)
    if (!nzchar(profile_label)) profile_label <- "NV"
    
    htmltools::div(
      style = "display: flex; height: 300px; width: 100%; position: relative; overflow: hidden; background: var(--background); border: 1px solid var(--border); border-radius: 0.5rem; box-shadow: 0 2px 6px rgb(0 0 0 / 0.08);",
      
      htmltools::div(
        style = paste0(
          "width: ", if (collapsed) "60px" else "200px", ";",
          "transition: width 0.3s ease; display: flex; flex-direction: column; padding: 1rem;",
          "position: relative; overflow: hidden; border-right: 1px solid var(--border); background: var(--muted);"
        ),
        
        htmltools::div(
          style = "display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.5rem; white-space: nowrap;",
          if (!collapsed) htmltools::tags$span(style = "font-weight: 700; font-size: 0.875rem;", sidebar_title) else NULL,
          if (collapsible) {
            block_button(
              "",
              id = "showcase_layout_preview_toggle",
              variant = "ghost",
              size = "icon",
              icon = "panel-left",
              style = "width: 1.75rem; height: 1.75rem;",
              `aria-label` = "Toggle sidebar"
            )
          }
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.5rem;",
          htmltools::div(style = "display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem; background: var(--accent); border-radius: 0.375rem; color: var(--accent-foreground);",
            block_icon("layout-dashboard"),
            if (!collapsed) htmltools::tags$span(style = "font-size: 0.8125rem;", "Dashboard") else NULL
          ),
          htmltools::div(style = "display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem; border-radius: 0.375rem; color: var(--muted-foreground);",
            block_icon("users"),
            if (!collapsed) htmltools::tags$span(style = "font-size: 0.8125rem;", "Users") else NULL
          )
        )
      ),
      
      htmltools::div(
        style = "flex: 1; display: flex; flex-direction: column;",
        
        htmltools::div(
          style = "height: 50px; display: flex; align-items: center; padding: 0 1rem; gap: 0.75rem; justify-content: space-between; border-bottom: 1px solid var(--border); background: var(--background);",
          htmltools::div(
            style = "display: flex; align-items: center; gap: 0.5rem;",
            block_icon("menu"),
            htmltools::tags$span(style = "font-weight: 600; font-size: 0.875rem;", title)
          ),
          if (show_profile) {
            htmltools::tags$div(
              title = "Profile area",
              style = paste(
                "width: 1.75rem; height: 1.75rem; border-radius: 9999px;",
                "display: inline-flex; align-items: center; justify-content: center;",
                "background: var(--muted); color: var(--muted-foreground);",
                "font-size: 0.6875rem; font-weight: 700;"
              ),
              substr(profile_label, 1, 2)
            )
          }
        ),
        
        htmltools::div(
          style = "flex: 1; padding: 1rem; background: var(--background); overflow-y: auto;",
          htmltools::tags$h4(style = "margin: 0 0 0.5rem 0; font-size: 0.875rem; font-weight: 600;", "Overview Metrics"),
          htmltools::div(
            style = "display: grid; grid-template-columns: repeat(2, 1fr); gap: 0.75rem;",
            htmltools::div(
              style = "padding: 0.75rem; border-radius: 0.5rem; border: 1px solid var(--border);",
              htmltools::tags$div(style = "font-size: 0.6875rem; color: var(--muted-foreground);", "Sales"),
              htmltools::tags$div(style = "font-size: 0.875rem; font-weight: 700;", "$12,402")
            ),
            htmltools::div(
              style = "padding: 0.75rem; border-radius: 0.5rem; border: 1px solid var(--border);",
              htmltools::tags$div(style = "font-size: 0.6875rem; color: var(--muted-foreground);", "Active Users"),
              htmltools::tags$div(style = "font-size: 0.875rem; font-weight: 700;", "1,280")
            )
          )
        )
      )
    )
  })
  shiny::outputOptions(
    output,
    "showcase_layout_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_layout_preview_code <- showcase_render_code({
    string_literal <- function(value) {
      paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
    }

    title_val <- input$showcase_layout_doc_title %||% "Admin Dashboard"
    sidebar_title_val <- input$showcase_layout_doc_sidebar_title %||% "Acme Corp"
    collapsible_val <- isTRUE(input$showcase_layout_doc_collapsible)
    collapsed_val <- isTRUE(input$showcase_layout_doc_collapsed)
    show_profile_val <- isTRUE(input$showcase_layout_doc_profile)
    profile_label_val <- substr(input$showcase_layout_doc_profile_label %||% "NV", 1, 2)
    profile_code <- if (show_profile_val) {
      paste0(
        ",\n",
        "    htmltools::div(\n",
        "      class = \"profile-avatar\",\n",
        "      ", string_literal(profile_label_val), "\n",
        "    )"
      )
    } else {
      ""
    }

    paste0(
      "block_page(\n",
      "  title = ", string_literal(title_val), ",\n",
      "  sidebar = block_sidebar(\n",
      "    title = ", string_literal(sidebar_title_val), ",\n",
      "    collapsible = ", as.character(collapsible_val), ",\n",
      "    collapsed = ", as.character(collapsed_val), ",\n",
      "    block_nav(\n",
      "      block_nav_item(\"Dashboard\", icon = \"layout-dashboard\"),\n",
      "      block_nav_item(\"Users\", icon = \"users\")\n",
      "    )\n",
      "  ),\n",
      "  header = block_header(\n",
      "    ", string_literal(title_val), profile_code, "\n",
      "  ),\n",
      "  block_body(\n",
      "    # Main content here\n",
      "  )\n",
      ")"
    )
  })
  shiny::outputOptions(
    output,
    "showcase_layout_preview_code",
    suspendWhenHidden = FALSE
  )

  # API Reference table
  output$showcase_layout_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("block_page", "block_sidebar", "block_header", "block_body"),
      Type = c(
        "..., title, sidebar, header, theme_mode, theme, class",
        "..., title, collapsible, collapsed, id, class",
        "..., class",
        "..., class"
      ),
      Default = c("none", "none", "none", "none"),
      Description = c(
        "Main modern layout page shell. Injects and handles responsive sheet-drawers.",
        "Dashboard left sidebar with collapsible mode support and built-in menu toggles.",
        "Top navigation/action header shell.",
        "Central page landmark wrapper for nested sections/grids."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_layout_api_table",
    suspendWhenHidden = FALSE
  )
}

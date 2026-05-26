register_layout_showcase <- function(input, output, session) {
  output$showcase_layout_preview_ui <- shiny::renderUI({
    title <- input$showcase_layout_doc_title %||% "Admin Dashboard"
    sidebar_title <- input$showcase_layout_doc_sidebar_title %||% "Acme Corp"
    collapsible <- isTRUE(input$showcase_layout_doc_collapsible)
    collapsed <- isTRUE(input$showcase_layout_doc_collapsed)
    
    # Render a beautiful miniature mock-up of the layout structure
    htmltools::div(
      class = "sb-layout-mockup border rounded-lg overflow-hidden bg-background shadow-md",
      style = "display: flex; height: 300px; width: 100%; position: relative;",
      
      # Mock Sidebar
      htmltools::div(
        class = paste0("sb-sidebar-mock border-r bg-muted ", if (collapsed) "collapsed-mock" else ""),
        style = paste0("width: ", if (collapsed) "60px" else "200px", "; transition: width 0.3s ease; display: flex; flex-direction: column; padding: 1rem; position: relative; overflow: hidden;"),
        
        # Sidebar Header
        htmltools::div(
          style = "display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.5rem; white-space: nowrap;",
          if (!collapsed) htmltools::tags$span(style = "font-weight: 700; font-size: 0.875rem;", sidebar_title) else NULL,
          if (collapsible) {
            htmltools::tags$div(
              style = "opacity: 0.7; font-size: 0.75rem; cursor: pointer; padding: 0.25rem; border-radius: 0.25rem;",
              block_icon("panel-left")
            )
          }
        ),
        # Sidebar items mockup
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
      
      # Mock Main Area
      htmltools::div(
        style = "flex: 1; display: flex; flex-direction: column;",
        
        # Mock Header
        htmltools::div(
          class = "border-b bg-background",
          style = "height: 50px; display: flex; align-items: center; padding: 0 1rem; gap: 0.75rem; justify-content: space-between;",
          htmltools::div(
            style = "display: flex; align-items: center; gap: 0.5rem;",
            block_icon("menu"),
            htmltools::tags$span(style = "font-weight: 600; font-size: 0.875rem;", title)
          ),
          htmltools::tags$div(
            style = "width: 1.5rem; height: 1.5rem; border-radius: 50%; background: var(--muted);"
          )
        ),
        
        # Mock Body
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
    title_val <- input$showcase_layout_doc_title %||% "Admin Dashboard"
    sidebar_title_val <- input$showcase_layout_doc_sidebar_title %||% "Acme Corp"
    collapsible_val <- isTRUE(input$showcase_layout_doc_collapsible)
    collapsed_val <- isTRUE(input$showcase_layout_doc_collapsed)

    paste0(
      "block_page(\n",
      "  title = \"", title_val, "\",\n",
      "  sidebar = block_sidebar(\n",
      "    title = \"", sidebar_title_val, "\",\n",
      "    collapsible = ", tolower(as.character(collapsible_val)), ",\n",
      "    collapsed = ", tolower(as.character(collapsed_val)), ",\n",
      "    block_nav(\n",
      "      block_nav_item(\"Dashboard\", icon = \"layout-dashboard\"),\n",
      "      block_nav_item(\"Users\", icon = \"users\")\n",
      "    )\n",
      "  ),\n",
      "  header = block_header(\n",
      "    \"", title_val, "\"\n",
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
  output$showcase_layout_api_table <- shiny::renderTable({
    data.frame(
      Component = c("block_page", "block_sidebar", "block_header", "block_body"),
      Arguments = c(
        "..., title, sidebar, header, theme_mode, theme, class",
        "..., title, collapsible, collapsed, id, class",
        "..., class",
        "..., class"
      ),
      Description = c(
        "Main modern layout page shell. Injects and handles responsive sheet-drawers.",
        "Dashboard left sidebar with collapsible mode support and built-in menu toggles.",
        "Top navigation/action header shell.",
        "Central page landmark wrapper for nested sections/grids."
      )
    )
  }, width = "100%", align = "lll", striped = FALSE, hover = FALSE, bordered = FALSE, sanitize.text.function = function(x) x)
  shiny::outputOptions(
    output,
    "showcase_layout_api_table",
    suspendWhenHidden = FALSE
  )
}

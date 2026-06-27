# A small, static user roster shown on the layout preview's "Users" page.
layout_preview_users_table <- function() {
  users <- data.frame(
    Name = c("Ada Lovelace", "Alan Turing", "Grace Hopper", "Katherine Johnson"),
    Role = c("Admin", "Editor", "Editor", "Viewer"),
    Status = c("Active", "Active", "Invited", "Active"),
    stringsAsFactors = FALSE
  )

  cell <- function(value, muted = FALSE) {
    htmltools::tags$td(
      style = paste0(
        "padding: 0.375rem 0.5rem; border-bottom: 1px solid var(--border);",
        if (muted) " color: var(--muted-foreground);" else ""
      ),
      value
    )
  }

  htmltools::tagList(
    htmltools::tags$h4(
      style = "margin: 0 0 0.5rem 0; font-size: 0.875rem; font-weight: 600;",
      "Users"
    ),
    htmltools::tags$table(
      style = "width: 100%; border-collapse: collapse; font-size: 0.75rem;",
      htmltools::tags$thead(
        htmltools::tags$tr(
          lapply(c("Name", "Role", "Status"), function(heading) {
            htmltools::tags$th(
              style = paste(
                "text-align: left; padding: 0.375rem 0.5rem; font-weight: 600;",
                "color: var(--muted-foreground); border-bottom: 1px solid var(--border);"
              ),
              heading
            )
          })
        )
      ),
      htmltools::tags$tbody(
        lapply(seq_len(nrow(users)), function(i) {
          htmltools::tags$tr(
            cell(users$Name[i]),
            cell(users$Role[i], muted = TRUE),
            cell(users$Status[i], muted = TRUE)
          )
        })
      )
    )
  )
}

register_layout_showcase <- function(input, output, session) {
  collapsed_state <- shiny::reactiveVal(FALSE)

  # Which page the sidebar nav has selected. `block_nav(id = ...)` reports the
  # clicked item's value here, and we keep it so the choice survives a preview
  # re-render when other controls change.
  preview_page <- shiny::reactiveVal("dashboard")

  shiny::observeEvent(input$showcase_layout_doc_collapsed, {
    collapsed_state(isTRUE(input$showcase_layout_doc_collapsed))
  }, ignoreInit = FALSE)

  shiny::observeEvent(input$showcase_layout_preview_toggle, {
    if (isTRUE(input$showcase_layout_doc_collapsible)) {
      collapsed_state(!isTRUE(collapsed_state()))
    }
  })

  shiny::observeEvent(input$showcase_layout_preview_nav, {
    preview_page(input$showcase_layout_preview_nav)
  })

  reactive_code <- shiny::reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_nav() code here."
  ))

  output$showcase_layout_reactive_code <- showcase_render_code({
    reactive_code()
  })
  shiny::outputOptions(
    output,
    "showcase_layout_reactive_code",
    suspendWhenHidden = FALSE
  )

  shiny::observeEvent(input$showcase_layout_select_other, {
    current <- preview_page() %||% "dashboard"
    next_page <- if (identical(current, "users")) "dashboard" else "users"
    update_block_nav(
      session = session,
      input_id = "showcase_layout_preview_nav",
      selected = next_page
    )
    reactive_code(paste0(
      "update_block_nav(\n",
      "  session = session,\n",
      "  input_id = \"showcase_layout_preview_nav\",\n",
      "  selected = \"", next_page, "\"\n",
      ")"
    ))
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
    active_page <- preview_page() %||% "dashboard"

    htmltools::div(
      class = "sb-page has-sidebar",
      `data-sidebar-enhanced` = "true",
      `data-sidebar-mobile-open` = "false",
      `data-sidebar-collapsed` = tolower(as.character(collapsed)),
      style = "display: flex; min-height: 0; height: 300px; width: 100%; position: relative; overflow: hidden; background: var(--background); border: 1px solid var(--border); border-radius: 0.5rem; box-shadow: 0 2px 6px rgb(0 0 0 / 0.08);",
      
      htmltools::div(
        style = paste0(
          "width: ", if (collapsed) "4.5rem" else "200px", ";",
          "transition: width 0.3s ease; display: flex; flex-direction: column; padding: 1rem;",
          "position: relative; overflow: hidden; border-right: 1px solid var(--border); background: var(--muted);"
        ),
        
        htmltools::div(
          class = "sb-sidebar-title",
          style = "border-bottom: 0; padding: 0; margin-bottom: 1.5rem; white-space: nowrap;",
          htmltools::tags$span(
            class = "sb-sidebar-title-text",
            style = "font-weight: 700; font-size: 0.875rem;",
            sidebar_title
          ),
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
        # A real navigation input: clicking an item reports its value as
        # input$showcase_layout_preview_nav and the page below switches.
        block_nav(
          id = "showcase_layout_preview_nav",
          block_nav_item(
            "Dashboard",
            value = "dashboard",
            icon = "layout-dashboard",
            selected = identical(active_page, "dashboard")
          ),
          block_nav_item(
            "Users",
            value = "users",
            icon = "users",
            selected = identical(active_page, "users")
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
          # Dashboard page: shown unless the Users item is selected.
          shiny::conditionalPanel(
            condition = "input.showcase_layout_preview_nav != 'users'",
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
          ),
          # Users page: shown when the Users nav item is selected.
          shiny::conditionalPanel(
            condition = "input.showcase_layout_preview_nav == 'users'",
            layout_preview_users_table()
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

  output$showcase_layout_preview_value <- showcase_render_code({
    value <- input$showcase_layout_preview_nav
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else {
      paste0("\"", value, "\"")
    }
    paste0("input$showcase_layout_preview_nav = ", val_str)
  })
  shiny::outputOptions(
    output,
    "showcase_layout_preview_value",
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
      "ui <- block_page(\n",
      "  title = ", string_literal(title_val), ",\n",
      "  sidebar = block_sidebar(\n",
      "    title = ", string_literal(sidebar_title_val), ",\n",
      "    collapsible = ", as.character(collapsible_val), ",\n",
      "    collapsed = ", as.character(collapsed_val), ",\n",
      "    # block_nav(id = ...) makes the items a Shiny input.\n",
      "    block_nav(\n",
      "      id = \"page\",\n",
      "      block_nav_item(\"Dashboard\", value = \"dashboard\",\n",
      "                     icon = \"layout-dashboard\", selected = TRUE),\n",
      "      block_nav_item(\"Users\", value = \"users\", icon = \"users\")\n",
      "    )\n",
      "  ),\n",
      "  header = block_header(\n",
      "    ", string_literal(title_val), profile_code, "\n",
      "  ),\n",
      "  block_body(\n",
      "    # Each page shows when its nav item is selected.\n",
      "    conditionalPanel(\n",
      "      \"input.page == 'dashboard'\",\n",
      "      block_card(title = \"Overview Metrics\", textOutput(\"summary\"))\n",
      "    ),\n",
      "    conditionalPanel(\n",
      "      \"input.page == 'users'\",\n",
      "      block_card(title = \"Users\", tableOutput(\"users\"))\n",
      "    )\n",
      "  )\n",
      ")\n\n",
      "server <- function(input, output, session) {\n",
      "  # input$page is a normal Shiny input: \"dashboard\" or \"users\".\n",
      "  output$summary <- renderText(\n",
      "    sprintf(\"You are viewing the %s page.\", input$page)\n",
      "  )\n\n",
      "  output$users <- renderTable(\n",
      "    data.frame(\n",
      "      Name   = c(\"Ada Lovelace\", \"Alan Turing\", \"Grace Hopper\"),\n",
      "      Role   = c(\"Admin\", \"Editor\", \"Viewer\"),\n",
      "      Status = c(\"Active\", \"Active\", \"Invited\")\n",
      "    )\n",
      "  )\n\n",
      "  # Jump to a page from the server when you need to:\n",
      "  # update_block_nav(session, \"page\", \"users\")\n",
      "}"
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

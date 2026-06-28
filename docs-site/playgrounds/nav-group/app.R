if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)

  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch(
      {
        webr::mount("/packages", path)
        if ("shinyblocks" %in% installed.packages(lib.loc = "/packages")[, "Package"]) {
          mounted <- TRUE
          break
        }
      },
      error = function(e) {
        # Try the next path; Shinylive resolves mount URLs differently by host.
      }
    )
  }

  if (!mounted) {
    tryCatch(
      {
        webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
      },
      error = function(e) {
        stop("Failed to mount shinyblocks WASM package library: ", e$message)
      }
    )
  }

  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
do.call(library, list("shinyblocks", character.only = TRUE))

`%||%` <- function(a, b) if (is.null(a)) b else a

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

showcase_render_code <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    block_code(
      paste(as.character(eval(quoted, envir = env)), collapse = "\n"),
      language = "r",
      copyable = TRUE,
      line_numbers = TRUE
    )
  })
}

ui <- block_page(
  title = "shinyblocks - Nav group playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      class = "showcase-playground",
      block_cluster(
        gap = "lg",
        align = "start",
        class = "showcase-playground__split",
        block_card(
          title = "Controls",
          class = "showcase-playground__controls",
          block_stack(
            gap = "sm",
            class = "showcase-controls-group showcase-controls-group--first",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Content"),
            block_field(
              block_field_label("section label", `for` = "nav_group_section"),
              block_textarea("nav_group_section", value = "Workspace", rows = 1, resize = "none")
            ),
            block_field(
              block_field_label("group label", `for` = "nav_group_label"),
              block_textarea("nav_group_label", value = "Operations", rows = 1, resize = "none")
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "State"),
            block_field(
              block_field_label("expanded", `for` = "nav_group_expanded"),
              block_checkbox("nav_group_expanded", label = "Start expanded", value = TRUE)
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Styling"),
            block_field(
              block_field_label("class", `for` = "nav_group_class"),
              block_checkbox("nav_group_class", label = "Use sidebar nav styling", value = TRUE)
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Actions"),
            block_cluster(
              gap = "sm",
              block_button("Select users", id = "nav_group_select_users", variant = "outline", size = "sm"),
              block_button("Select orders", id = "nav_group_select_orders", variant = "outline", size = "sm")
            )
          )
        ),
        block_stack(
          gap = "lg",
          class = "showcase-playground__main",
          block_stack(
            gap = "sm",
            htmltools::div(class = "showcase-playground__label", "Preview"),
            htmltools::div(
              class = "showcase-preview-canvas showcase-preview-canvas--muted",
              style = "min-height: 260px;",
              uiOutput("nav_group_preview_ui")
            )
          ),
          htmltools::div(
            htmltools::div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
              "Nav value"
            ),
            uiOutput("nav_group_value_echo")
          ),
          htmltools::div(
            htmltools::div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
              "Server Action"
            ),
            uiOutput("nav_group_action_code")
          ),
          htmltools::div(
            htmltools::div(
              class = "showcase-playground__label showcase-playground__label--code",
              "UI Definition"
            ),
            uiOutput("nav_group_code")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  selected <- reactiveVal("dashboard")
  action_code <- reactiveVal("# Click an action button to see update_block_nav().")

  observeEvent(input$nav_group_value, {
    selected(input$nav_group_value)
  })

  observeEvent(input$nav_group_select_users, {
    update_block_nav(session, "nav_group_value", selected = "users")
    action_code("update_block_nav(session, \"nav_group_value\", selected = \"users\")")
  })

  observeEvent(input$nav_group_select_orders, {
    update_block_nav(session, "nav_group_value", selected = "orders")
    action_code("update_block_nav(session, \"nav_group_value\", selected = \"orders\")")
  })

  output$nav_group_preview_ui <- renderUI({
    active <- selected() %||% "dashboard"
    section <- input$nav_group_section %||% "Workspace"
    group <- input$nav_group_label %||% "Operations"
    class <- if (isTRUE(input$nav_group_class)) "sb-sidebar-nav" else NULL

    htmltools::div(
      style = paste(
        "background: var(--sidebar); color: var(--sidebar-foreground);",
        "padding: 0.75rem; border: 1px solid var(--border);",
        "border-radius: 0.5rem; max-width: 18rem; width: 100%;"
      ),
      block_nav(
        id = "nav_group_value",
        class = class,
        block_nav_label(section),
        block_nav_item(
          "Dashboard",
          value = "dashboard",
          icon = "layout-dashboard",
          selected = identical(active, "dashboard")
        ),
        block_nav_group(
          group,
          block_nav_item(
            "Users",
            value = "users",
            icon = "users",
            selected = identical(active, "users")
          ),
          block_nav_item(
            "Orders",
            value = "orders",
            icon = "clipboard",
            selected = identical(active, "orders")
          ),
          icon = "folder",
          value = "operations",
          expanded = isTRUE(input$nav_group_expanded)
        )
      )
    )
  })

  output$nav_group_value_echo <- showcase_render_code({
    value <- input$nav_group_value
    paste0(
      "input$nav_group_value = ",
      if (is.null(value)) "<NULL>" else string_literal(value)
    )
  })

  output$nav_group_action_code <- showcase_render_code({
    action_code()
  })

  output$nav_group_code <- showcase_render_code({
    section <- input$nav_group_section %||% "Workspace"
    group <- input$nav_group_label %||% "Operations"
    expanded <- as.character(isTRUE(input$nav_group_expanded))
    class <- if (isTRUE(input$nav_group_class)) ',\n  class = "sb-sidebar-nav"' else ""

    paste0(
      "block_nav(\n",
      "  id = \"page\",\n",
      "  block_nav_label(", string_literal(section), "),\n",
      "  block_nav_item(\"Dashboard\", value = \"dashboard\",\n",
      "                 icon = \"layout-dashboard\", selected = TRUE),\n",
      "  block_nav_group(\n",
      "    ", string_literal(group), ",\n",
      "    block_nav_item(\"Users\", value = \"users\", icon = \"users\"),\n",
      "    block_nav_item(\"Orders\", value = \"orders\", icon = \"clipboard\"),\n",
      "    icon = \"folder\",\n",
      "    value = \"operations\",\n",
      "    expanded = ", expanded, "\n",
      "  )", class, "\n",
      ")"
    )
  })
}

shinyApp(ui, server)

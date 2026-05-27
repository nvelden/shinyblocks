if (!"shinyblocks" %in% installed.packages()[, "Package"]) {
  dir.create("/packages", recursive = TRUE, showWarnings = FALSE)

  mounted <- FALSE
  for (path in c("../../library.data.gz", "../library.data.gz")) {
    tryCatch({
      webr::mount("/packages", path)
      if ("shinyblocks" %in% installed.packages(lib.loc = "/packages")[, "Package"]) {
        mounted <- TRUE
        break
      }
    }, error = function(e) {})
  }

  if (!mounted) {
    webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
  }

  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
do.call(library, list("shinyblocks", character.only = TRUE))

`%||%` <- function(a, b) if (is.null(a)) b else a

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

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

ui <- block_page(
  title = "shinyblocks - Layout playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
      htmltools::div(
        style = paste(
          "flex: 1; min-width: 280px; max-width: 320px;",
          "border: 1px solid var(--border); border-radius: 0.75rem;",
          "padding: 1.25rem; display: flex; flex-direction: column; gap: 1.25rem;",
          "background: color-mix(in oklab, var(--muted) 40%, transparent);"
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Header & Sidebar"
          ),
          block_field(
            block_field_label("header title", `for` = "showcase_layout_doc_title"),
            block_textarea("showcase_layout_doc_title", value = "Admin Dashboard", rows = 1)
          ),
          block_field(
            block_field_label("sidebar title", `for` = "showcase_layout_doc_sidebar_title"),
            block_textarea("showcase_layout_doc_sidebar_title", value = "Acme Corp", rows = 1)
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Sidebar State"
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
      ),
      htmltools::div(
        style = "flex: 2; min-width: 320px; display: flex; flex-direction: column; gap: 1.25rem;",
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.5rem;",
          htmltools::div(style = "font-size: 0.875rem; font-weight: 600; color: var(--foreground);", "Preview"),
          htmltools::div(
            style = paste(
              "position: relative; display: flex; align-items: stretch; justify-content: stretch;",
              "padding: 1rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
              "border: 0; border-radius: 0.75rem; min-height: 332px; box-sizing: border-box;"
            ),
            uiOutput("showcase_layout_preview_ui")
          )
        ),
        htmltools::div(
          htmltools::div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_layout_preview_code")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  output$showcase_layout_preview_ui <- renderUI({
    title <- input$showcase_layout_doc_title %||% "Admin Dashboard"
    sidebar_title <- input$showcase_layout_doc_sidebar_title %||% "Acme Corp"
    collapsible <- isTRUE(input$showcase_layout_doc_collapsible)
    collapsed <- isTRUE(input$showcase_layout_doc_collapsed)

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
            htmltools::div(
              style = "opacity: 0.7; font-size: 0.75rem; padding: 0.25rem; border-radius: 0.25rem;",
              block_icon("panel-left")
            )
          }
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.5rem;",
          htmltools::div(
            style = "display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem; background: var(--accent); border-radius: 0.375rem; color: var(--accent-foreground);",
            block_icon("layout-dashboard"),
            if (!collapsed) htmltools::tags$span(style = "font-size: 0.8125rem;", "Dashboard") else NULL
          ),
          htmltools::div(
            style = "display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem; border-radius: 0.375rem; color: var(--muted-foreground);",
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
          htmltools::div(style = "width: 1.5rem; height: 1.5rem; border-radius: 50%; background: var(--muted);")
        ),
        htmltools::div(
          style = "flex: 1; padding: 1rem; background: var(--background); overflow-y: auto;",
          htmltools::tags$h4(style = "margin: 0 0 0.5rem 0; font-size: 0.875rem; font-weight: 600;", "Overview Metrics"),
          htmltools::div(
            style = "display: grid; grid-template-columns: repeat(2, 1fr); gap: 0.75rem;",
            htmltools::div(
              style = "padding: 0.75rem; border-radius: 0.5rem; border: 1px solid var(--border);",
              htmltools::div(style = "font-size: 0.6875rem; color: var(--muted-foreground);", "Sales"),
              htmltools::div(style = "font-size: 0.875rem; font-weight: 700;", "$12,402")
            ),
            htmltools::div(
              style = "padding: 0.75rem; border-radius: 0.5rem; border: 1px solid var(--border);",
              htmltools::div(style = "font-size: 0.6875rem; color: var(--muted-foreground);", "Active Users"),
              htmltools::div(style = "font-size: 0.875rem; font-weight: 700;", "1,280")
            )
          )
        )
      )
    )
  })

  output$showcase_layout_preview_code <- showcase_render_code({
    title <- input$showcase_layout_doc_title %||% "Admin Dashboard"
    sidebar_title <- input$showcase_layout_doc_sidebar_title %||% "Acme Corp"
    collapsible <- as.character(isTRUE(input$showcase_layout_doc_collapsible))
    collapsed <- as.character(isTRUE(input$showcase_layout_doc_collapsed))
    paste0(
      "block_page(\n",
      "  title = ", string_literal(title), ",\n",
      "  sidebar = block_sidebar(\n",
      "    title = ", string_literal(sidebar_title), ",\n",
      "    collapsible = ", collapsible, ",\n",
      "    collapsed = ", collapsed, ",\n",
      "    block_nav(\n",
      "      block_nav_item(\"Dashboard\", icon = \"layout-dashboard\"),\n",
      "      block_nav_item(\"Users\", icon = \"users\")\n",
      "    )\n",
      "  ),\n",
      "  header = block_header(", string_literal(title), "),\n",
      "  block_body(...)\n",
      ")"
    )
  })
}

shinyApp(ui, server)

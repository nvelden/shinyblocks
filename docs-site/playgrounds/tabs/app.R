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

ui <- block_page(
  title = "shinyblocks - Tabs playground",
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
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; color: var(--muted-foreground); margin: 0;",
            "Tab Styles"
          ),
          block_field(
            block_field_label("variant", `for` = "showcase_tabs_doc_variant"),
            block_select("showcase_tabs_doc_variant", choices = c("default", "line"), selected = "default", size = "sm")
          ),
          block_field(
            block_field_label("orientation", `for` = "showcase_tabs_doc_orientation"),
            block_select("showcase_tabs_doc_orientation", choices = c("horizontal", "vertical"), selected = "horizontal", size = "sm")
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
              "position: relative; display: flex; align-items: stretch;",
              "padding: 1.5rem; background: var(--card);",
              "border: 1px dashed var(--border); border-radius: 0.75rem;",
              "min-height: 260px; box-sizing: border-box;"
            ),
            uiOutput("showcase_tabs_preview_ui")
          )
        ),
        htmltools::div(
          style = "font-size: 0.875rem; font-weight: 500; padding: 0.5rem; background: var(--secondary); border-radius: 0.25rem;",
          textOutput("showcase_tabs_reactive_log")
        ),
        htmltools::div(
          htmltools::div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_tabs_preview_code")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  output$showcase_tabs_reactive_log <- renderText({
    current <- input$showcase_tabs_interactive %||% "overview"
    paste0("Active tab reported by server: \"", current, "\"")
  })

  output$showcase_tabs_preview_ui <- renderUI({
    block_tabs(
      id = "showcase_tabs_interactive",
      variant = input$showcase_tabs_doc_variant %||% "default",
      orientation = input$showcase_tabs_doc_orientation %||% "horizontal",
      block_tab(
        "Overview",
        value = "overview",
        block_card(title = "Workspace Overview", description = "Manage default workspace state.", "This is the dashboard overview tab.")
      ),
      block_tab(
        "Usage",
        value = "usage",
        block_card(title = "Members & Usage", description = "Reactive seats and collaborators.", "Check active seats and remaining billing credits.")
      ),
      block_tab(
        "Settings",
        value = "settings",
        block_card(title = "Billing & Settings", description = "Persist plans and billing preferences.", "Configure enterprise accounts.")
      )
    )
  })

  output$showcase_tabs_preview_code <- showcase_render_code({
    variant <- input$showcase_tabs_doc_variant %||% "default"
    orientation <- input$showcase_tabs_doc_orientation %||% "horizontal"
    paste0(
      "block_tabs(\n",
      "  id = \"showcase_tabs_interactive\",\n",
      "  variant = \"", variant, "\",\n",
      "  orientation = \"", orientation, "\",\n",
      "  block_tab(\"Overview\", value = \"overview\", ...),\n",
      "  block_tab(\"Usage\", value = \"usage\", ...),\n",
      "  block_tab(\"Settings\", value = \"settings\", ...)\n",
      ")"
    )
  })
}

shinyApp(ui, server)

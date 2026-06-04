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
    value <- eval(quoted, envir = env)
    if (is.null(value) || !length(value)) value <- ""
    block_code(
      paste(as.character(value), collapse = "\n"),
      language = "r",
      copyable = TRUE,
      line_numbers = TRUE
    )
  })
}

showcase_render_value <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    value <- eval(quoted, envir = env)
    htmltools::tags$pre(
      class = "sb-code-block sb-code-block-default",
      style = "margin: 0; padding: 0.75rem 1rem; font-size: 0.8125rem;",
      htmltools::tags$code(paste(as.character(value), collapse = "\n"))
    )
  })
}

showcase_action_button <- function(input_id, label) {
  block_button(
    label,
    id = input_id,
    variant = "outline",
    size = "sm"
  )
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
      class = "showcase-playground", style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
      block_card(
                title = "Controls",
                class = "showcase-playground__controls",
                style = "flex: 1; min-width: 280px; max-width: 320px;",
htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; color: var(--muted-foreground); margin: 0;",
            "Tab Styles"
          ),
          block_field(
            block_field_label("selected", `for` = "showcase_tabs_doc_selected"),
            block_select("showcase_tabs_doc_selected", choices = c("overview", "usage", "settings"), selected = "overview", size = "sm")
          ),
          block_field(
            block_field_label("variant", `for` = "showcase_tabs_doc_variant"),
            block_select("showcase_tabs_doc_variant", choices = c("default", "line"), selected = "default", size = "sm")
          ),
          block_field(
            block_field_label("orientation", `for` = "showcase_tabs_doc_orientation"),
            block_select("showcase_tabs_doc_orientation", choices = c("horizontal", "vertical"), selected = "horizontal", size = "sm")
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; color: var(--muted-foreground); margin: 0;",
            "Actions (Server Update)"
          ),
          htmltools::tags$div(
            style = "display: flex; flex-wrap: wrap; gap: 0.35rem;",
            showcase_action_button("showcase_tabs_select_usage", "Select Usage"),
            showcase_action_button("showcase_tabs_select_settings", "Select Settings")
          )
        )
      ),
      htmltools::div(
        class = "showcase-playground__main", style = "flex: 2; min-width: 320px; display: flex; flex-direction: column; gap: 1.25rem;",
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
        uiOutput("showcase_tabs_preview_value"),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 1rem;",
          htmltools::div(
            htmltools::div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
              "UI Definition"
            ),
            uiOutput("showcase_tabs_preview_code")
          ),
          htmltools::div(
            htmltools::div(
              style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
              "Server Action"
            ),
            uiOutput("showcase_tabs_reactive_code")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  output$showcase_tabs_preview_value <- showcase_render_value({
    value <- input$showcase_tabs_interactive
    val_str <- if (is.null(value)) {
      "<NULL>"
    } else if (!nzchar(value)) {
      "<EMPTY>"
    } else {
      paste0('"', value, '"')
    }
    paste0("input$showcase_tabs_interactive = ", val_str)
  })
  outputOptions(output, "showcase_tabs_preview_value", suspendWhenHidden = FALSE)

  output$showcase_tabs_preview_ui <- renderUI({
    block_tabs(
      id = "showcase_tabs_interactive",
      selected = input$showcase_tabs_doc_selected %||% "overview",
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
  outputOptions(output, "showcase_tabs_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_tabs_preview_code <- showcase_render_code({
    selected <- input$showcase_tabs_doc_selected %||% "overview"
    variant <- input$showcase_tabs_doc_variant %||% "default"
    orientation <- input$showcase_tabs_doc_orientation %||% "horizontal"
    paste0(
      "block_tabs(\n",
      "  id = \"showcase_tabs_interactive\",\n",
      "  selected = \"", selected, "\",\n",
      "  variant = \"", variant, "\",\n",
      "  orientation = \"", orientation, "\",\n",
      "  block_tab(\"Overview\", value = \"overview\", ...),\n",
      "  block_tab(\"Usage\", value = \"usage\", ...),\n",
      "  block_tab(\"Settings\", value = \"settings\", ...)\n",
      ")"
    )
  })
  outputOptions(output, "showcase_tabs_preview_code", suspendWhenHidden = FALSE)

  reactive_code <- reactiveVal(paste0(
    "# Click an action button to see\n",
    "# the update_block_tabs() code here."
  ))
  output$showcase_tabs_reactive_code <- showcase_render_code({ reactive_code() })
  outputOptions(output, "showcase_tabs_reactive_code", suspendWhenHidden = FALSE)

  observeEvent(input$showcase_tabs_select_usage, {
    update_block_tabs(session, "showcase_tabs_interactive", selected = "usage")
    update_block_select(session, "showcase_tabs_doc_selected", selected = "usage")
    reactive_code('update_block_tabs(\n  session = session,\n  input_id = "showcase_tabs_interactive",\n  selected = "usage"\n)')
  })

  observeEvent(input$showcase_tabs_select_settings, {
    update_block_tabs(session, "showcase_tabs_interactive", selected = "settings")
    update_block_select(session, "showcase_tabs_doc_selected", selected = "settings")
    reactive_code('update_block_tabs(\n  session = session,\n  input_id = "showcase_tabs_interactive",\n  selected = "settings"\n)')
  })
}

shinyApp(ui, server)

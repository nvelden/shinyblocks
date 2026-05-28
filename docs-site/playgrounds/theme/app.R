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
  title = "shinyblocks - Theme playground",
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
            "Tokens"
          ),
          block_field(
            block_field_label("radius", `for` = "showcase_theme_doc_radius"),
            block_select("showcase_theme_doc_radius", choices = c("0rem", "0.25rem", "0.5rem", "1rem", "1.5rem"), selected = "0.5rem", size = "sm")
          ),
          block_field(
            block_field_label("primary", `for` = "showcase_theme_doc_primary"),
            block_select("showcase_theme_doc_primary", choices = c(
              "blue" = "hsl(221.2, 83.2%, 53.3%)",
              "red" = "hsl(0, 72.2%, 50.6%)",
              "green" = "hsl(142.1, 76.2%, 36.3%)",
              "purple" = "hsl(262.1, 83.3%, 57.8%)"
            ), selected = "hsl(221.2, 83.2%, 53.3%)", size = "sm")
          ),
          block_field(
            block_field_label("accent", `for` = "showcase_theme_doc_accent"),
            block_select("showcase_theme_doc_accent", choices = c(
              "blue tint" = "hsl(214, 95%, 93%)",
              "green tint" = "hsl(142, 69%, 90%)",
              "amber tint" = "hsl(48, 96%, 89%)",
              "rose tint" = "hsl(351, 95%, 93%)"
            ), selected = "hsl(214, 95%, 93%)", size = "sm")
          )
        ),
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.75rem; border-top: 1px solid var(--border); padding-top: 0.75rem;",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Actions (Server Update)"
          ),
          block_button("Force Light Mode", id = "showcase_theme_set_light", variant = "outline", size = "sm"),
          block_button("Force Dark Mode", id = "showcase_theme_set_dark", variant = "outline", size = "sm"),
          block_button("Sync with System", id = "showcase_theme_set_system", variant = "outline", size = "sm")
        )
      ),
      htmltools::div(
        style = "flex: 2; min-width: 320px; display: flex; flex-direction: column; gap: 1.25rem;",
        htmltools::div(
          style = "display: flex; flex-direction: column; gap: 0.5rem;",
          htmltools::div(style = "font-size: 0.875rem; font-weight: 600; color: var(--foreground);", "Preview"),
          htmltools::div(
            style = paste(
              "position: relative; display: flex; align-items: center; justify-content: center;",
              "padding: 1.5rem; background: color-mix(in oklab, var(--muted) 28%, transparent);",
              "border: 0; border-radius: 0.75rem; min-height: 330px; box-sizing: border-box;"
            ),
            uiOutput("showcase_theme_preview_ui")
          )
        ),
        htmltools::div(
          htmltools::div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_theme_preview_code")
        ),
        htmltools::div(
          htmltools::div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "Server Action"
          ),
          uiOutput("showcase_theme_action_code")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  observeEvent(input$showcase_theme_set_light, {
    update_block_theme(session, mode = "light")
  })
  observeEvent(input$showcase_theme_set_dark, {
    update_block_theme(session, mode = "dark")
  })
  observeEvent(input$showcase_theme_set_system, {
    update_block_theme(session, mode = "system")
  })

  output$showcase_theme_preview_ui <- renderUI({
    radius <- input$showcase_theme_doc_radius %||% "0.5rem"
    primary <- input$showcase_theme_doc_primary %||% "hsl(221.2, 83.2%, 53.3%)"
    accent <- input$showcase_theme_doc_accent %||% "hsl(214, 95%, 93%)"

    htmltools::tagList(
      block_theme(radius = radius, primary = primary, accent = accent),
      htmltools::div(
        style = "display: flex; flex-direction: column; gap: 1rem; width: 100%;",
        htmltools::div(
          style = "display: flex; gap: 0.75rem; align-items: center; flex-wrap: wrap;",
          block_button("Primary Button"),
          block_button("Secondary Button", variant = "secondary"),
          block_button("Outline Button", variant = "outline")
        ),
        htmltools::div(
          style = paste(
            "padding: 1rem; background: var(--accent); color: var(--accent-foreground);",
            "border: 1px solid color-mix(in oklab, var(--accent) 70%, var(--foreground));",
            "border-radius: calc(var(--radius) * 1.2); font-size: 0.875rem; font-weight: 500;",
            "display: flex; align-items: center; justify-content: space-between; gap: 1rem;"
          ),
          htmltools::span("Accent surface"),
          block_badge("Token preview", variant = "secondary")
        ),
        block_card(
          title = "Dynamic Card",
          description = "Token overrides apply immediately.",
          "The buttons and this surface inherit the selected theme values."
        )
      )
    )
  })

  output$showcase_theme_preview_code <- showcase_render_code({
    radius <- input$showcase_theme_doc_radius %||% "0.5rem"
    primary <- input$showcase_theme_doc_primary %||% "hsl(221.2, 83.2%, 53.3%)"
    accent <- input$showcase_theme_doc_accent %||% "hsl(214, 95%, 93%)"
    paste0(
      "block_theme(\n",
      "  radius = \"", radius, "\",\n",
      "  primary = \"", primary, "\",\n",
      "  accent = \"", accent, "\"\n",
      ")"
    )
  })

  output$showcase_theme_action_code <- showcase_render_code({
    paste(
      "update_block_theme(",
      "  session = session,",
      "  mode = \"dark\"",
      ")",
      sep = "\n"
    )
  })
}

shinyApp(ui, server)

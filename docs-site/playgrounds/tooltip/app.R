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
  title = "shinyblocks - Tooltip playground",
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
                style = "flex: 1; min-width: 280px; max-width: 320px;",
block_stack(
  gap = "sm",
  class = "showcase-controls-group showcase-controls-group--first",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Content"
          ),
          block_field(
            block_field_label("trigger label", `for` = "showcase_tooltip_doc_trigger"),
            block_textarea("showcase_tooltip_doc_trigger", value = "Hover me", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("content", `for` = "showcase_tooltip_doc_content"),
            block_textarea("showcase_tooltip_doc_content", value = "Tooltip details go here.", rows = 2, resize = "none")
          ),
          block_field(
            block_field_label("delay_duration", `for` = "showcase_tooltip_doc_delay"),
            block_select(
              "showcase_tooltip_doc_delay",
              choices = c("0ms" = 0, "100ms" = 100, "500ms" = 500, "700ms" = 700, "1500ms" = 1500),
              selected = "700",
              size = "sm"
            )
          )
        ),
        block_stack(
          gap = "sm",
          class = "showcase-controls-group",
          htmltools::tags$h4(
            style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
            "Styling"
          ),
          block_field(
            block_field_label("side", `for` = "showcase_tooltip_doc_side"),
            block_select("showcase_tooltip_doc_side", choices = c("top", "bottom", "left", "right"), selected = "top", size = "sm")
          ),
          block_field(
            block_field_label("align", `for` = "showcase_tooltip_doc_align"),
            block_select("showcase_tooltip_doc_align", choices = c("center", "start", "end"), selected = "center", size = "sm")
          ),
          block_field(
            block_field_label("style", `for` = "showcase_tooltip_doc_style"),
            block_textarea("showcase_tooltip_doc_style", value = "", rows = 1, placeholder = "e.g., border: 2px dashed red;", resize = "none")
          ),
          block_field(
            block_field_label("class", `for` = "showcase_tooltip_doc_class"),
            block_checkbox("showcase_tooltip_doc_class", "Use custom dashed-border class", value = FALSE)
          )
        )
      ),
      block_stack(
        gap = "lg",
        class = "showcase-playground__main",
        block_stack(
          gap = "sm",
          htmltools::div(style = "font-size: 0.875rem; font-weight: 600; color: var(--foreground);", "Preview"),
          htmltools::div(
            class = "showcase-preview-canvas",
            uiOutput("showcase_tooltip_preview_ui")
          )
        ),
        htmltools::div(
          htmltools::div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("showcase_tooltip_preview_code")
        )
      )
        )
)
  )
)

server <- function(input, output, session) {
  output$showcase_tooltip_preview_ui <- renderUI({
    style <- input$showcase_tooltip_doc_style %||% ""
    if (!nzchar(style)) style <- NULL

    block_tooltip(
      trigger = input$showcase_tooltip_doc_trigger %||% "Hover me",
      input$showcase_tooltip_doc_content %||% "Tooltip details go here.",
      side = input$showcase_tooltip_doc_side %||% "top",
      align = input$showcase_tooltip_doc_align %||% "center",
      delay_duration = as.numeric(input$showcase_tooltip_doc_delay %||% 700),
      style = style,
      class = if (isTRUE(input$showcase_tooltip_doc_class)) "showcase-tooltip-preview-custom" else NULL
    )
  })

  output$showcase_tooltip_preview_code <- showcase_render_code({
    trigger <- input$showcase_tooltip_doc_trigger %||% "Hover me"
    content <- input$showcase_tooltip_doc_content %||% "Tooltip details go here."
    side <- input$showcase_tooltip_doc_side %||% "top"
    align <- input$showcase_tooltip_doc_align %||% "center"
    delay <- as.numeric(input$showcase_tooltip_doc_delay %||% 700)
    style <- input$showcase_tooltip_doc_style %||% ""
    args <- c(paste0("trigger = ", string_literal(trigger)), string_literal(content))

    if (!identical(side, "top")) args <- c(args, paste0("side = ", string_literal(side)))
    if (!identical(align, "center")) args <- c(args, paste0("align = ", string_literal(align)))
    if (!identical(delay, 700)) args <- c(args, paste0("delay_duration = ", delay))
    if (isTRUE(input$showcase_tooltip_doc_class)) args <- c(args, 'class = "showcase-tooltip-preview-custom"')
    if (nzchar(style)) args <- c(args, paste0("style = ", string_literal(style)))

    paste0("block_tooltip(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
}

shinyApp(ui, server)

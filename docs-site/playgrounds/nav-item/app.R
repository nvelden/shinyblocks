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
  title = "shinyblocks - Nav Item playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; margin: 0; box-sizing: border-box; overflow-x: hidden;",
    htmltools::div(
      class = "showcase-playground",
      block_card(
                title = "Controls",
                class = "showcase-playground__controls",
block_stack(
          gap = "sm",
          class = "showcase-controls-group showcase-controls-group--first",
          htmltools::tags$h4(
            class = "showcase-controls-group__title",
            "Navigation Settings"
          ),
          block_field(
            block_field_label("label", `for` = "showcase_nav_item_doc_label"),
            block_textarea("showcase_nav_item_doc_label", value = "Home", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("href", `for` = "showcase_nav_item_doc_href"),
            block_textarea("showcase_nav_item_doc_href", value = "#", rows = 1, resize = "none")
          ),
          block_field(
            block_field_label("icon", `for` = "showcase_nav_item_doc_icon"),
            block_select("showcase_nav_item_doc_icon", choices = c("home", "file-text", "users", "settings", "none"), selected = "home", size = "sm")
          )
        ),
        block_stack(
          gap = "sm",
          class = "showcase-controls-group",
          htmltools::tags$h4(
            class = "showcase-controls-group__title",
            "State & Styling"
          ),
          block_field(
            block_field_label("selected", `for` = "showcase_nav_item_doc_selected"),
            block_checkbox("showcase_nav_item_doc_selected", label = "Set active/selected", value = TRUE)
          ),
          block_field(
            block_field_label("class", `for` = "showcase_nav_item_doc_class"),
            block_checkbox("showcase_nav_item_doc_class", label = "Use emphasized class", value = FALSE)
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
            style = "min-height: 220px;",
            uiOutput("showcase_nav_item_preview_ui")
          )
        ),
        htmltools::div(
          htmltools::div(
            class = "showcase-playground__label showcase-playground__label--code",
            "UI Definition"
          ),
          uiOutput("showcase_nav_item_preview_code")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  output$showcase_nav_item_preview_ui <- renderUI({
    label <- input$showcase_nav_item_doc_label %||% "Home"
    href <- input$showcase_nav_item_doc_href %||% "#"
    icon <- input$showcase_nav_item_doc_icon %||% "home"
    if (identical(icon, "none")) icon <- NULL
    class <- if (isTRUE(input$showcase_nav_item_doc_class)) "sb-nav-demo-highlight" else NULL

    htmltools::tagList(
      htmltools::tags$style(".sb-nav-demo-highlight { outline: 2px solid var(--ring); outline-offset: 2px; }"),
      htmltools::div(
        style = "background: var(--sidebar); color: var(--sidebar-foreground); padding: 0.75rem; border-radius: 0.5rem; max-width: 18rem; width: 100%; border: 1px solid var(--border);",
        block_nav(
          class = "sb-sidebar-nav",
          block_nav_item(
            label = label,
            href = href,
            icon = icon,
            selected = isTRUE(input$showcase_nav_item_doc_selected),
            class = class
          )
        )
      )
    )
  })

  output$showcase_nav_item_preview_code <- showcase_render_code({
    label <- input$showcase_nav_item_doc_label %||% "Home"
    href <- input$showcase_nav_item_doc_href %||% "#"
    icon <- input$showcase_nav_item_doc_icon %||% "home"
    args <- c(paste0("label = ", string_literal(label)))

    if (!identical(href, "#")) args <- c(args, paste0("href = ", string_literal(href)))
    if (!identical(icon, "none")) args <- c(args, paste0("icon = ", string_literal(icon)))
    if (isTRUE(input$showcase_nav_item_doc_selected)) args <- c(args, "selected = TRUE")
    if (isTRUE(input$showcase_nav_item_doc_class)) args <- c(args, 'class = "sb-nav-demo-highlight"')

    paste0("block_nav_item(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
}

shinyApp(ui, server)

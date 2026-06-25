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
      error = function(e) {}
    )
  }
  if (!mounted) webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
do.call(library, list("shinyblocks", character.only = TRUE))

`%||%` <- function(a, b) if (is.null(a)) b else a
string_literal <- function(value) paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")

showcase_render_code <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    block_code(paste(as.character(eval(quoted, envir = env)), collapse = "\n"), language = "r", copyable = TRUE, line_numbers = TRUE)
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

ui <- block_page(
  title = "shinyblocks - Popover playground",
  theme = htmltools::tagList(htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")),
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
            block_field(block_field_label("trigger label", `for` = "showcase_popover_doc_trigger"), block_textarea("showcase_popover_doc_trigger", value = "Open popover", rows = 1, resize = "none")),
            block_field(block_field_label("body", `for` = "showcase_popover_doc_body"), block_textarea("showcase_popover_doc_body", value = "Place additional details, a small form, or contextual actions inside the popover.", rows = 3, resize = "none"))
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "State"),
            block_field(block_field_label("open", `for` = "showcase_popover_doc_open"), block_checkbox("showcase_popover_doc_open", "Open", value = FALSE))
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Actions (Server Update)"),
            block_cluster(
              gap = "sm",
              block_button("Open", id = "showcase_popover_open", variant = "outline", size = "sm"),
              block_button("Close", id = "showcase_popover_close", variant = "outline", size = "sm"),
              block_button("Move", id = "showcase_popover_reposition", variant = "outline", size = "sm"),
              block_button("Swap text", id = "showcase_popover_swap_body", variant = "outline", size = "sm")
            )
          ),
          block_stack(
            gap = "sm",
            class = "showcase-controls-group",
            htmltools::tags$h4(class = "showcase-controls-group__title", "Styling"),
            block_field(block_field_label("side", `for` = "showcase_popover_doc_side"), block_select("showcase_popover_doc_side", choices = c("bottom", "top", "left", "right"), selected = "bottom", size = "sm")),
            block_field(block_field_label("align", `for` = "showcase_popover_doc_align"), block_select("showcase_popover_doc_align", choices = c("center", "start", "end"), selected = "center", size = "sm")),
            block_field(block_field_label("style", `for` = "showcase_popover_doc_style"), block_textarea("showcase_popover_doc_style", value = "", rows = 1, placeholder = "e.g., border: 2px dashed red;", resize = "none")),
            block_field(block_field_label("class", `for` = "showcase_popover_doc_class"), block_checkbox("showcase_popover_doc_class", "Use custom dashed-border class", value = FALSE))
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
              style = "min-height: 180px;",
              uiOutput("showcase_popover_preview_ui")
            )
          ),
          uiOutput("showcase_popover_preview_value"),
          htmltools::div(htmltools::div(class = "showcase-playground__label--code", "UI Definition"), uiOutput("showcase_popover_preview_code")),
          htmltools::div(htmltools::div(class = "showcase-playground__label--code", "Server Action"), uiOutput("showcase_popover_reactive_code"))
        )
      )
    )
  )
)

server <- function(input, output, session) {
  swapped_body <- reactiveVal(FALSE)
  open_state <- reactiveVal(FALSE)
  reactive_code <- reactiveVal("# Click an action button to see\n# the update_block_popover() code here.")

  observeEvent(input$showcase_popover_doc_open,
    {
      open_state(isTRUE(input$showcase_popover_doc_open))
    },
    ignoreNULL = FALSE
  )

  current_body <- reactive({
    if (isTRUE(swapped_body())) "Body updated from the server." else input$showcase_popover_doc_body %||% ""
  })

  output$showcase_popover_preview_ui <- renderUI({
    style <- input$showcase_popover_doc_style %||% ""
    if (!nzchar(style)) style <- NULL
    trigger <- input$showcase_popover_doc_trigger %||% "Open popover"
    if (!nzchar(trigger)) trigger <- "Open popover"
    block_popover(
      id = "showcase_popover_preview",
      trigger = trigger,
      side = input$showcase_popover_doc_side %||% "bottom",
      align = input$showcase_popover_doc_align %||% "center",
      open = isTRUE(open_state()),
      style = style,
      class = if (isTRUE(input$showcase_popover_doc_class)) "showcase-popover-preview-custom" else NULL,
      htmltools::tags$p(current_body())
    )
  })

  output$showcase_popover_preview_value <- showcase_render_value({
    value <- input$showcase_popover_preview
    paste0("input$showcase_popover_preview = ", if (is.null(value)) "<NULL>" else if (isTRUE(value)) "TRUE" else "FALSE")
  })

  output$showcase_popover_preview_code <- showcase_render_code({
    trigger <- input$showcase_popover_doc_trigger %||% "Open popover"
    args <- c('id = "showcase_popover_preview"', paste0("trigger = ", string_literal(trigger)))
    if (nzchar(current_body())) args <- c(args, paste0("htmltools::tags$p(", string_literal(current_body()), ")"))
    side <- input$showcase_popover_doc_side %||% "bottom"
    align <- input$showcase_popover_doc_align %||% "center"
    if (!identical(side, "bottom")) args <- c(args, paste0("side = ", string_literal(side)))
    if (!identical(align, "center")) args <- c(args, paste0("align = ", string_literal(align)))
    if (isTRUE(open_state())) args <- c(args, "open = TRUE")
    style <- input$showcase_popover_doc_style %||% ""
    if (nzchar(style)) args <- c(args, paste0("style = ", string_literal(style)))
    if (isTRUE(input$showcase_popover_doc_class)) args <- c(args, 'class = "showcase-popover-preview-custom"')
    paste0("block_popover(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })

  output$showcase_popover_reactive_code <- showcase_render_code({
    reactive_code()
  })

  observeEvent(input$showcase_popover_open, {
    swapped_body(FALSE)
    open_state(TRUE)
    update_block_popover(session, "showcase_popover_preview", open = TRUE)
    reactive_code("update_block_popover(\n  session = session,\n  input_id = \"showcase_popover_preview\",\n  open = TRUE\n)")
  })
  observeEvent(input$showcase_popover_close, {
    swapped_body(FALSE)
    open_state(FALSE)
    update_block_popover(session, "showcase_popover_preview", open = FALSE)
    reactive_code("update_block_popover(\n  session = session,\n  input_id = \"showcase_popover_preview\",\n  open = FALSE\n)")
  })
  observeEvent(input$showcase_popover_reposition, {
    swapped_body(FALSE)
    open_state(TRUE)
    update_block_select(session, "showcase_popover_doc_side", selected = "top")
    update_block_select(session, "showcase_popover_doc_align", selected = "end")
    update_block_popover(session, "showcase_popover_preview", open = TRUE, side = "top", align = "end")
    reactive_code("update_block_popover(\n  session = session,\n  input_id = \"showcase_popover_preview\",\n  open = TRUE,\n  side = \"top\",\n  align = \"end\"\n)")
  })
  observeEvent(input$showcase_popover_swap_body, {
    open_state(TRUE)
    swapped_body(!isTRUE(swapped_body()))
    body <- current_body()
    update_block_popover(session, "showcase_popover_preview", open = TRUE, body = htmltools::tags$p(body))
    reactive_code(paste0("update_block_popover(\n  session = session,\n  input_id = \"showcase_popover_preview\",\n  open = TRUE,\n  body = htmltools::tags$p(", string_literal(body), ")\n)"))
  })
}

shinyApp(ui, server)

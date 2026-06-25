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

control_group <- function(title, ..., first = FALSE) {
  block_stack(
    gap = "sm",
    class = if (first) "showcase-controls-group showcase-controls-group--first" else "showcase-controls-group",
    htmltools::tags$h4(class = "showcase-controls-group__title", title),
    ...
  )
}

ui <- block_page(
  title = "shinyblocks - Dialog playground",
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
          control_group(
            "Content",
            first = TRUE,
            block_field(block_field_label("title", `for` = "showcase_dialog_doc_title"), block_textarea("showcase_dialog_doc_title", value = "Confirm action", rows = 1, resize = "none")),
            block_field(block_field_label("description", `for` = "showcase_dialog_doc_description"), block_textarea("showcase_dialog_doc_description", value = "This cannot be undone.", rows = 2, resize = "none")),
            block_field(block_field_label("trigger label", `for` = "showcase_dialog_doc_trigger"), block_textarea("showcase_dialog_doc_trigger", value = "Open dialog", rows = 1, resize = "none")),
            block_field(block_field_label("footer", `for` = "showcase_dialog_doc_footer"), block_checkbox("showcase_dialog_doc_footer", "Include Cancel + Continue footer", value = TRUE))
          ),
          control_group(
            "State",
            block_field(block_field_label("hide_title", `for` = "showcase_dialog_doc_hide_title"), block_checkbox("showcase_dialog_doc_hide_title", "Hide title visually", value = FALSE))
          ),
          control_group(
            "Actions (Server Update)",
            block_cluster(
              gap = "sm",
              block_button("Open modal", id = "showcase_dialog_open", variant = "outline", size = "sm"),
              block_button("Close modal", id = "showcase_dialog_close", variant = "outline", size = "sm"),
              block_button("Resize sm", id = "showcase_dialog_resize_sm", variant = "outline", size = "sm"),
              block_button("Resize lg", id = "showcase_dialog_resize_lg", variant = "outline", size = "sm"),
              block_button("Swap footer", id = "showcase_dialog_swap_footer", variant = "outline", size = "sm")
            )
          ),
          control_group(
            "Styling",
            block_field(block_field_label("size", `for` = "showcase_dialog_doc_size"), block_select("showcase_dialog_doc_size", choices = c("default", "sm", "lg", "xl"), selected = "default", size = "sm")),
            block_field(block_field_label("style", `for` = "showcase_dialog_doc_style"), block_textarea("showcase_dialog_doc_style", value = "", rows = 1, placeholder = "e.g., border: 2px dashed red;", resize = "none")),
            block_field(block_field_label("class", `for` = "showcase_dialog_doc_class"), block_checkbox("showcase_dialog_doc_class", "Use custom dashed-border class", value = FALSE))
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
              uiOutput("showcase_dialog_preview_ui")
            )
          ),
          block_cluster(justify = "center", uiOutput("showcase_dialog_trigger_ui")),
          uiOutput("showcase_dialog_preview_value"),
          htmltools::div(htmltools::div(class = "showcase-playground__label--code", "UI Definition"), uiOutput("showcase_dialog_preview_code")),
          htmltools::div(htmltools::div(class = "showcase-playground__label--code", "Server Action"), uiOutput("showcase_dialog_reactive_code"))
        )
      )
    ),
    block_dialog(
      id = "showcase_dialog_preview",
      title = "Confirm action",
      description = "This cannot be undone.",
      footer = htmltools::tagList(block_button("Cancel", variant = "outline"), block_button("Continue")),
      size = "default",
      htmltools::tags$p("Click the trigger or an action button to open the real dialog.")
    )
  )
)

server <- function(input, output, session) {
  footer_kind <- reactiveVal("default")
  reactive_code <- reactiveVal("# Click an action button to see\n# the update_block_dialog() code here.")
  default_footer <- function() htmltools::tagList(block_button("Cancel", variant = "outline"), block_button("Continue"))
  custom_footer <- function() htmltools::tagList(block_button("Discard", variant = "outline"), block_button("Save draft", variant = "secondary"), block_button("Publish"))
  footer_tags <- reactive({
    if (!isTRUE(input$showcase_dialog_doc_footer)) {
      return(NULL)
    }
    if (identical(footer_kind(), "custom")) custom_footer() else default_footer()
  })

  output$showcase_dialog_trigger_ui <- renderUI({
    label <- input$showcase_dialog_doc_trigger %||% ""
    if (!nzchar(label)) {
      return(NULL)
    }
    block_button(label, id = "showcase_dialog_trigger_click")
  })
  observeEvent(input$showcase_dialog_trigger_click, {
    update_block_dialog(session, "showcase_dialog_preview", open = TRUE)
  })

  observe({
    style <- input$showcase_dialog_doc_style %||% ""
    update_block_dialog(
      session,
      "showcase_dialog_preview",
      size = input$showcase_dialog_doc_size %||% "default",
      class = if (isTRUE(input$showcase_dialog_doc_class)) "showcase-dialog-preview-custom" else NULL,
      style = if (nzchar(style)) style else NULL
    )
  })

  output$showcase_dialog_preview_ui <- renderUI({
    title <- input$showcase_dialog_doc_title %||% "Confirm action"
    description <- input$showcase_dialog_doc_description %||% ""
    size <- input$showcase_dialog_doc_size %||% "default"
    max_width <- switch(size,
      sm = "24rem",
      lg = "48rem",
      xl = "64rem",
      "32rem"
    )
    title_style <- if (isTRUE(input$showcase_dialog_doc_hide_title)) {
      "position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0,0,0,0);"
    } else {
      "margin: 0; font-size: 1.125rem; font-weight: 600; line-height: 1.2;"
    }
    style <- input$showcase_dialog_doc_style %||% ""
    htmltools::div(
      class = c(
        "sb-dialog-content",
        if (isTRUE(input$showcase_dialog_doc_class)) "showcase-dialog-preview-custom"
      ),
      "data-slot" = "dialog-content",
      "data-size" = size,
      # Render the inline preview at the requested size and only clamp if the
      # canvas is too narrow (the previous `width: 100%; max-width: <size>`
      # collapsed `sm` and `default` to identical widths in narrow iframes).
      style = paste0(
        "position: relative; display: flex; flex-direction: column; gap: 1rem;",
        " width: min(", max_width, ", 100%); max-width: 100%; max-height: min(32rem, calc(100vh - 4rem));",
        " overflow: auto; margin: 0 auto; border: 1px solid var(--border);",
        " border-radius: calc(var(--radius) * 1.4); background: var(--background);",
        " padding: 1.5rem; box-sizing: border-box; ",
        style
      ),
      htmltools::div(
        htmltools::tags$h2(style = title_style, title),
        if (nzchar(description)) htmltools::tags$p(style = "margin: 0; font-size: 0.875rem; color: var(--muted-foreground);", description)
      ),
      htmltools::tags$p(style = "margin: 0; font-size: 0.875rem;", "Adjust the controls to configure this modal."),
      if (!is.null(footer_tags())) block_cluster(justify = "end", gap = "sm", footer_tags())
    )
  })

  output$showcase_dialog_preview_value <- showcase_render_value({
    value <- input$showcase_dialog_preview
    paste0("input$showcase_dialog_preview = ", if (is.null(value)) "<NULL>" else if (isTRUE(value)) "TRUE" else "FALSE")
  })

  output$showcase_dialog_preview_code <- showcase_render_code({
    title <- input$showcase_dialog_doc_title %||% "Confirm action"
    description <- input$showcase_dialog_doc_description %||% ""
    trigger <- input$showcase_dialog_doc_trigger %||% ""
    size <- input$showcase_dialog_doc_size %||% "default"
    args <- c('id = "showcase_dialog_preview"', paste0("title = ", string_literal(title)))
    if (nzchar(description)) args <- c(args, paste0("description = ", string_literal(description)))
    if (!is.null(footer_tags())) {
      footer_code <- if (identical(footer_kind(), "custom")) {
        'footer = htmltools::tagList(block_button("Discard", variant = "outline"), block_button("Save draft", variant = "secondary"), block_button("Publish"))'
      } else {
        'footer = htmltools::tagList(block_button("Cancel", variant = "outline"), block_button("Continue"))'
      }
      args <- c(args, footer_code)
    }
    if (nzchar(trigger)) args <- c(args, paste0("trigger = ", string_literal(trigger)))
    if (!identical(size, "default")) args <- c(args, paste0("size = ", string_literal(size)))
    if (isTRUE(input$showcase_dialog_doc_hide_title)) args <- c(args, "hide_title = TRUE")
    style <- input$showcase_dialog_doc_style %||% ""
    if (nzchar(style)) args <- c(args, paste0("style = ", string_literal(style)))
    if (isTRUE(input$showcase_dialog_doc_class)) args <- c(args, 'class = "showcase-dialog-preview-custom"')
    paste0("block_dialog(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })
  output$showcase_dialog_reactive_code <- showcase_render_code({
    reactive_code()
  })

  observeEvent(input$showcase_dialog_open, {
    update_block_dialog(session, "showcase_dialog_preview", open = TRUE)
    reactive_code("update_block_dialog(\n  session = session,\n  input_id = \"showcase_dialog_preview\",\n  open = TRUE\n)")
  })
  observeEvent(input$showcase_dialog_close, {
    update_block_dialog(session, "showcase_dialog_preview", open = FALSE)
    reactive_code("update_block_dialog(\n  session = session,\n  input_id = \"showcase_dialog_preview\",\n  open = FALSE\n)")
  })
  observeEvent(input$showcase_dialog_resize_sm, {
    update_block_select(session, "showcase_dialog_doc_size", selected = "sm")
    update_block_dialog(session, "showcase_dialog_preview", size = "sm")
    reactive_code("update_block_dialog(\n  session = session,\n  input_id = \"showcase_dialog_preview\",\n  size = \"sm\"\n)")
  })
  observeEvent(input$showcase_dialog_resize_lg, {
    update_block_select(session, "showcase_dialog_doc_size", selected = "lg")
    update_block_dialog(session, "showcase_dialog_preview", size = "lg")
    reactive_code("update_block_dialog(\n  session = session,\n  input_id = \"showcase_dialog_preview\",\n  size = \"lg\"\n)")
  })
  observeEvent(input$showcase_dialog_swap_footer, {
    footer_kind(if (identical(footer_kind(), "default")) "custom" else "default")
    update_block_dialog(session, "showcase_dialog_preview", footer = footer_tags())
    reactive_code("update_block_dialog(\n  session = session,\n  input_id = \"showcase_dialog_preview\",\n  footer = htmltools::tagList(...)\n)")
  })
}

shinyApp(ui, server)

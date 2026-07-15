# Install shinyblocks (pre-built WebAssembly binary) from r-universe.
if (!"shinyblocks" %in% rownames(installed.packages())) {
  install.packages(
    "shinyblocks",
    repos = c("https://nvelden.r-universe.dev", "https://repo.r-wasm.org")
  )
}

library(shiny)
library(shinyblocks)

`%||%` <- function(a, b) if (is.null(a)) b else a
string_literal <- function(value) paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")

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

showcase_render_value <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  renderUI({
    htmltools::tags$pre(
      class = "sb-code-block sb-code-block-default",
      style = "margin:0;padding:0.75rem 1rem;font-size:0.8125rem;",
      htmltools::tags$code(paste(as.character(eval(quoted, envir = env)), collapse = "\n"))
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
  title = "shinyblocks - Alert dialog playground",
  theme = htmltools::tagList(
    htmltools::tags$link(rel = "stylesheet", href = "../../../shinyblocks-runtime-override.css")
  ),
  htmltools::div(
    `data-shinyblocks-root` = "",
    style = "padding:1rem;max-width:100%;margin:0;box-sizing:border-box;overflow-x:hidden;",
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
            block_field(block_field_label("title", `for` = "showcase_alert_dialog_title"), block_input("showcase_alert_dialog_title", value = "Delete account?")),
            block_field(block_field_label("description", `for` = "showcase_alert_dialog_description"), block_textarea("showcase_alert_dialog_description", value = "This action cannot be undone.", rows = 2, resize = "none")),
            block_field(block_field_label("confirm_label", `for` = "showcase_alert_dialog_confirm_label"), block_input("showcase_alert_dialog_confirm_label", value = "Delete")),
            block_field(block_field_label("cancel_label", `for` = "showcase_alert_dialog_cancel_label"), block_input("showcase_alert_dialog_cancel_label", value = "Cancel")),
            block_field(block_field_label("trigger", `for` = "showcase_alert_dialog_trigger"), block_input("showcase_alert_dialog_trigger", value = "Delete account"))
          ),
          control_group(
            "State",
            block_field(block_field_label("confirm_variant", `for` = "showcase_alert_dialog_variant"), block_select("showcase_alert_dialog_variant", c("default", "destructive"), selected = "destructive", size = "sm"))
          ),
          control_group(
            "Actions (Server Update)",
            block_cluster(
              gap = "sm",
              block_button("Open", id = "showcase_alert_dialog_open", variant = "outline", size = "sm"),
              block_button("Close", id = "showcase_alert_dialog_close", variant = "outline", size = "sm")
            )
          ),
          control_group(
            "Styling",
            block_field(block_field_label("size", `for` = "showcase_alert_dialog_size"), block_select("showcase_alert_dialog_size", c("default", "sm", "lg", "xl"), selected = "default", size = "sm")),
            block_field(block_field_label("style", `for` = "showcase_alert_dialog_style"), block_input("showcase_alert_dialog_style", value = "", placeholder = "max-width: 28rem;")),
            block_field(block_field_label("class", `for` = "showcase_alert_dialog_class"), block_checkbox("showcase_alert_dialog_class", "Use custom preview class"))
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
              uiOutput("showcase_alert_dialog_preview_ui")
            )
          ),
          block_cluster(justify = "center", uiOutput("showcase_alert_dialog_trigger_ui")),
          uiOutput("showcase_alert_dialog_value"),
          htmltools::div(htmltools::div(class = "showcase-playground__label--code", "UI Definition"), uiOutput("showcase_alert_dialog_code")),
          htmltools::div(htmltools::div(class = "showcase-playground__label--code", "Server Action"), uiOutput("showcase_alert_dialog_server_code"))
        )
      )
    ),
    block_alert_dialog(
      "showcase_alert_dialog_preview",
      "Delete account?",
      description = "This action cannot be undone.",
      confirm_label = "Delete",
      confirm_variant = "destructive"
    )
  )
)

server <- function(input, output, session) {
  server_code <- reactiveVal("# Use update_block_alert_dialog() to open or close.")

  observe({
    style <- input$showcase_alert_dialog_style %||% ""
    update_block_alert_dialog(
      session,
      "showcase_alert_dialog_preview",
      title = input$showcase_alert_dialog_title %||% "Delete account?",
      description = input$showcase_alert_dialog_description %||% "",
      confirm_label = input$showcase_alert_dialog_confirm_label %||% "Delete",
      cancel_label = input$showcase_alert_dialog_cancel_label %||% "Cancel",
      confirm_variant = input$showcase_alert_dialog_variant %||% "destructive",
      size = input$showcase_alert_dialog_size %||% "default",
      class = if (isTRUE(input$showcase_alert_dialog_class)) "showcase-dialog-preview-custom" else NULL,
      style = if (nzchar(style)) style else NULL
    )
  })

  output$showcase_alert_dialog_trigger_ui <- renderUI({
    label <- input$showcase_alert_dialog_trigger %||% ""
    if (!nzchar(label)) return(NULL)
    block_button(label, id = "showcase_alert_dialog_trigger_click")
  })

  observeEvent(input$showcase_alert_dialog_trigger_click, {
    update_block_alert_dialog(session, "showcase_alert_dialog_preview", open = TRUE)
  })
  observeEvent(input$showcase_alert_dialog_open, {
    update_block_alert_dialog(session, "showcase_alert_dialog_preview", open = TRUE)
    server_code('update_block_alert_dialog(session, "showcase_alert_dialog_preview", open = TRUE)')
  })
  observeEvent(input$showcase_alert_dialog_close, {
    update_block_alert_dialog(session, "showcase_alert_dialog_preview", open = FALSE)
    server_code('update_block_alert_dialog(session, "showcase_alert_dialog_preview", open = FALSE)')
  })

  output$showcase_alert_dialog_preview_ui <- renderUI({
    custom_class <- if (isTRUE(input$showcase_alert_dialog_class)) "showcase-dialog-preview-custom" else NULL
    custom_style <- input$showcase_alert_dialog_style %||% ""
    block_stack(
      gap = "sm",
      class = c("sb-parity-alert-dialog", custom_class),
      style = if (nzchar(custom_style)) custom_style else NULL,
      htmltools::tags$strong(input$showcase_alert_dialog_title %||% "Delete account?"),
      htmltools::tags$p(style = "margin:0;color:var(--muted-foreground);", input$showcase_alert_dialog_description %||% ""),
      block_cluster(
        justify = "end",
        block_button(input$showcase_alert_dialog_cancel_label %||% "Cancel", variant = "outline"),
        block_button(input$showcase_alert_dialog_confirm_label %||% "Delete", variant = input$showcase_alert_dialog_variant %||% "destructive")
      )
    )
  })

  output$showcase_alert_dialog_value <- showcase_render_value({
    value <- input$showcase_alert_dialog_preview
    paste0("input$showcase_alert_dialog_preview = ", if (is.null(value)) "NULL" else string_literal(value))
  })

  output$showcase_alert_dialog_code <- showcase_render_code({
    args <- c(
      '"showcase_alert_dialog_preview"',
      string_literal(input$showcase_alert_dialog_title %||% "Delete account?"),
      paste0("description = ", string_literal(input$showcase_alert_dialog_description %||% "")),
      paste0("confirm_label = ", string_literal(input$showcase_alert_dialog_confirm_label %||% "Delete")),
      paste0("cancel_label = ", string_literal(input$showcase_alert_dialog_cancel_label %||% "Cancel")),
      paste0("trigger = ", string_literal(input$showcase_alert_dialog_trigger %||% "")),
      paste0("confirm_variant = ", string_literal(input$showcase_alert_dialog_variant %||% "destructive"))
    )
    size <- input$showcase_alert_dialog_size %||% "default"
    if (!identical(size, "default")) args <- c(args, paste0("size = ", string_literal(size)))
    style <- input$showcase_alert_dialog_style %||% ""
    if (nzchar(style)) args <- c(args, paste0("style = ", string_literal(style)))
    if (isTRUE(input$showcase_alert_dialog_class)) args <- c(args, 'class = "showcase-dialog-preview-custom"')
    paste0("block_alert_dialog(\n  ", paste(args, collapse = ",\n  "), "\n)")
  })

  output$showcase_alert_dialog_server_code <- showcase_render_code({
    server_code()
  })
}

shinyApp(ui, server)

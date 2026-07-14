register_pagination_showcase <- function(input, output, session) {
  state <- shiny::reactive({
    pages <- max(1L, as.integer(input$showcase_pagination_pages %||% 20L))
    selected <- min(
      pages,
      max(1L, as.integer(input$showcase_pagination_selected %||% 1L))
    )
    list(
      pages = pages,
      selected = selected,
      siblings = max(
        0L,
        as.integer(input$showcase_pagination_siblings %||% 1L)
      ),
      edges = isTRUE(input$showcase_pagination_edges),
      disabled = isTRUE(input$showcase_pagination_disabled),
      class = if (isTRUE(input$showcase_pagination_class)) {
        "showcase-pagination-custom"
      } else {
        NULL
      }
    )
  })
  output$showcase_pagination_preview_ui <- shiny::renderUI({
    s <- state()
    block_pagination(
      "showcase_pagination_preview",
      s$pages,
      s$selected,
      s$siblings,
      s$edges,
      s$disabled,
      class = s$class
    )
  })
  output$showcase_pagination_preview_code <- showcase_render_code({
    s <- state()
    sprintf(
      'block_pagination("page", pages = %d, selected = %d, sibling_count = %d, show_edges = %s, disabled = %s)',
      s$pages,
      s$selected,
      s$siblings,
      toupper(s$edges),
      toupper(s$disabled)
    )
  })
  output$showcase_pagination_value <- showcase_render_code({
    value <- input$showcase_pagination_preview
    paste0(
      "input$page = ",
      if (is.null(value)) "NULL" else as.character(value)
    )
  })
  action_code <- shiny::reactiveVal(
    "# Use update_block_pagination() to change pages or selection."
  )
  output$showcase_pagination_action_code <- showcase_render_code(action_code())
  shiny::observeEvent(input$showcase_pagination_first, {
    update_block_pagination(
      session,
      "showcase_pagination_preview",
      selected = 1
    )
    action_code('update_block_pagination(session, "page", selected = 1)')
  })
  shiny::observeEvent(input$showcase_pagination_last, {
    last <- state()$pages
    update_block_pagination(
      session,
      "showcase_pagination_preview",
      selected = last
    )
    action_code(sprintf(
      'update_block_pagination(session, "page", selected = %d)',
      last
    ))
  })
  output$showcase_pagination_api_table <- shiny::renderUI(showcase_api_table(data.frame(
    Argument = c(
      "input_id",
      "pages",
      "selected",
      "sibling_count",
      "show_edges",
      "disabled",
      "style",
      "class"
    ),
    Type = c(
      "character",
      "integer",
      "integer",
      "integer",
      "logical",
      "logical",
      "character | list",
      "character"
    ),
    Default = c(
      "required",
      "required",
      "1",
      "1",
      "TRUE",
      "FALSE",
      "NULL",
      "NULL"
    ),
    Description = c(
      "Shiny input id.",
      "Positive page count.",
      "Active page.",
      "Visible pages on each side.",
      "Keep first and last pages visible.",
      "Disable all controls.",
      "Inline styles.",
      "Additional class."
    )
  )))
}

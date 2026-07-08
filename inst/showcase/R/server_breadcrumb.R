register_breadcrumb_showcase <- function(input, output, session) {
  trail_args <- shiny::reactive({
    depth <- as.integer(input$showcase_breadcrumb_doc_depth %||% "3")
    current_label <- input$showcase_breadcrumb_doc_current %||% "Breadcrumb"
    if (!nzchar(current_label)) current_label <- "Breadcrumb"
    list(
      depth = depth,
      current = current_label,
      ellipsis = isTRUE(input$showcase_breadcrumb_doc_ellipsis),
      plain = isTRUE(input$showcase_breadcrumb_doc_plain),
      separator = input$showcase_breadcrumb_doc_separator %||% "chevron",
      style = {
        style_val <- input$showcase_breadcrumb_doc_style %||% ""
        if (nzchar(style_val)) style_val else NULL
      },
      class = if (isTRUE(input$showcase_breadcrumb_doc_class)) "border-dashed" else NULL
    )
  })

  ancestor_labels <- c("Home", "Library", "Data")

  output$showcase_breadcrumb_preview_ui <- shiny::renderUI({
    args <- trail_args()
    ancestors <- ancestor_labels[seq_len(args$depth - 1L)]

    items <- lapply(seq_along(ancestors), function(i) {
      if (i == 1L && args$plain) {
        block_breadcrumb_item(ancestors[[i]])
      } else {
        block_breadcrumb_item(ancestors[[i]], href = "#")
      }
    })
    if (args$ellipsis) {
      items <- append(items, list(block_breadcrumb_ellipsis()), after = 1L)
    }
    items <- c(items, list(block_breadcrumb_item(args$current, current = TRUE)))

    # "·" (middle dot) stays escaped so sourcing in a C locale can't
    # mangle the literal into raw <c2><b7> bytes.
    separator <- switch(args$separator, slash = "/", dot = "\u00b7", NULL)

    do.call(block_breadcrumb, c(
      items,
      list(separator = separator, style = args$style, class = args$class)
    ))
  })
  shiny::outputOptions(output, "showcase_breadcrumb_preview_ui", suspendWhenHidden = FALSE)

  output$showcase_breadcrumb_preview_code <- showcase_render_code({
    args <- trail_args()
    ancestors <- ancestor_labels[seq_len(args$depth - 1L)]

    lines <- vapply(seq_along(ancestors), function(i) {
      if (i == 1L && args$plain) {
        sprintf('  block_breadcrumb_item("%s")', ancestors[[i]])
      } else {
        sprintf('  block_breadcrumb_item("%s", href = "#")', ancestors[[i]])
      }
    }, character(1))
    if (args$ellipsis) {
      lines <- append(lines, "  block_breadcrumb_ellipsis()", after = 1L)
    }
    lines <- c(lines, sprintf('  block_breadcrumb_item("%s", current = TRUE)', args$current))

    if (identical(args$separator, "slash")) {
      lines <- c(lines, '  separator = "/"')
    } else if (identical(args$separator, "dot")) {
      lines <- c(lines, '  separator = "\\u00b7"')
    }
    if (!is.null(args$style)) {
      lines <- c(lines, sprintf('  style = "%s"', args$style))
    }
    if (!is.null(args$class)) {
      lines <- c(lines, '  class = "border-dashed"')
    }

    paste0("block_breadcrumb(\n", paste(lines, collapse = ",\n"), "\n)")
  })
  shiny::outputOptions(output, "showcase_breadcrumb_preview_code", suspendWhenHidden = FALSE)

  output$showcase_breadcrumb_api_table <- shiny::renderUI({
    htmltools::tagList(
      htmltools::tags$h4(
        style = "margin-top: 1rem; font-size: 0.95rem;",
        "block_breadcrumb()"
      ),
      showcase_api_table(data.frame(
        Argument = c("...", "separator", "style", "class"),
        Type = c("tags", "character | tag", "character", "character"),
        Default = c("required", "NULL", "NULL", "NULL"),
        Description = c(
          "block_breadcrumb_item() and block_breadcrumb_ellipsis() entries.",
          "Separator between entries (string or tag); defaults to a chevron icon. Hidden from assistive technology.",
          "Inline CSS styles applied to the nav container.",
          "Additional classes merged onto the nav container."
        )
      )),
      htmltools::tags$h4(
        style = "margin-top: 1rem; font-size: 0.95rem;",
        "block_breadcrumb_item()"
      ),
      showcase_api_table(data.frame(
        Argument = c("label", "href", "current", "class"),
        Type = c("character | tag", "character", "logical", "character"),
        Default = c("required", "NULL", "FALSE", "NULL"),
        Description = c(
          "Entry label.",
          "Destination URL; renders an anchor. Without href the entry is plain text. Ignored when current = TRUE.",
          "Marks the current page: a non-interactive span with aria-current='page'.",
          "Additional classes merged onto the list entry."
        )
      )),
      htmltools::tags$h4(
        style = "margin-top: 1rem; font-size: 0.95rem;",
        "block_breadcrumb_ellipsis()"
      ),
      showcase_api_table(data.frame(
        Argument = c("label", "class"),
        Type = c("character", "character"),
        Default = c("\"More\"", "NULL"),
        Description = c(
          "Visually hidden text announced to assistive technology in place of the collapsed entries.",
          "Additional classes merged onto the list entry."
        )
      ))
    )
  })
  shiny::outputOptions(output, "showcase_breadcrumb_api_table", suspendWhenHidden = FALSE)
}

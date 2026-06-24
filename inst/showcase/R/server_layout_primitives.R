layout_primitives_demo_specs <- function(values) {
  specs <- list(
    list(title = "Analytics", description = "Track product usage.", height = "5rem"),
    list(title = "Reports", description = "Review weekly summaries.", height = "3.5rem"),
    list(title = "Settings", description = "Manage preferences.", height = "4.5rem"),
    list(title = "Billing", description = "Update invoices and plans.", height = "6rem")
  )
  specs <- specs[seq_len(values$count)]

  lapply(specs, function(spec) {
    style <- switch(
      values$type,
      stack = if (identical(values$align, "stretch")) {
        NULL
      } else {
        "width: min(16rem, 100%);"
      },
      cluster = paste0(
        "width: 10rem;",
        if (values$vary_heights) paste0(" min-height: ", spec$height, ";") else ""
      ),
      grid = if (values$vary_heights) {
        paste0("min-height: ", spec$height, ";")
      } else {
        NULL
      }
    )

    c(spec, list(style = style))
  })
}

layout_primitives_demo_items <- function(specs) {
  lapply(specs, function(spec) {
    block_card(
      title = spec$title,
      description = spec$description,
      style = spec$style
    )
  })
}

layout_primitives_demo_code <- function(values, specs) {
  item_code <- vapply(specs, function(spec) {
    style_arg <- if (is.null(spec$style)) {
      ""
    } else {
      paste0(",\n    style = ", encodeString(spec$style, quote = "\""))
    }
    paste0(
      "  block_card(\n",
      "    title = ", encodeString(spec$title, quote = "\""), ",\n",
      "    description = ", encodeString(spec$description, quote = "\""),
      style_arg, "\n",
      "  )"
    )
  }, character(1))

  args <- c(
    item_code,
    sprintf('  gap = "%s"', values$gap),
    sprintf('  align = "%s"', values$align)
  )
  if (identical(values$type, "cluster")) {
    args <- c(
      args,
      sprintf('  justify = "%s"', values$justify),
      sprintf("  wrap = %s", toupper(as.character(values$wrap)))
    )
  }
  if (identical(values$type, "grid")) {
    args <- c(args, sprintf('  min_width = "%s"', values$min_width))
  }

  layout_code <- paste0(
    "block_", values$type, "(\n",
    paste(args, collapse = ",\n"),
    "\n)"
  )

  if (!identical(values$type, "cluster")) {
    return(layout_code)
  }

  paste0(
    "# The fixed container height makes vertical alignment visible.\n",
    "htmltools::div(\n",
    '  style = "height: 16rem;",\n',
    paste0("  ", gsub("\n", "\n  ", layout_code, fixed = TRUE)), "\n",
    ")"
  )
}

register_layout_primitives_showcase <- function(input, output, session) {
  state <- shiny::reactive({
    list(
      type = input$showcase_layout_primitives_type %||% "stack",
      gap = input$showcase_layout_primitives_gap %||% "md",
      align = input$showcase_layout_primitives_align %||% "stretch",
      justify = input$showcase_layout_primitives_justify %||% "start",
      wrap = isTRUE(input$showcase_layout_primitives_wrap),
      min_width = input$showcase_layout_primitives_min_width %||% "14rem",
      count = as.integer(input$showcase_layout_primitives_count %||% "4"),
      vary_heights = isTRUE(input$showcase_layout_primitives_vary_heights %||% TRUE)
    )
  })

  output$showcase_layout_primitives_preview_ui <- shiny::renderUI({
    values <- state()
    specs <- layout_primitives_demo_specs(values)
    items <- layout_primitives_demo_items(specs)

    layout <- switch(
      values$type,
      cluster = do.call(
        block_cluster,
        c(
          items,
          list(
            gap = values$gap,
            align = values$align,
            justify = values$justify,
            wrap = values$wrap
          )
        )
      ),
      grid = do.call(
        block_grid,
        c(
          items,
          list(
            min_width = values$min_width,
            gap = values$gap,
            align = values$align
          )
        )
      ),
      do.call(
        block_stack,
        c(items, list(gap = values$gap, align = values$align))
      )
    )

    if (identical(values$type, "cluster")) {
      layout <- htmltools::tags$div(
        class = "showcase-layout-primitives-cluster-frame",
        layout
      )
    }

    htmltools::tags$div(
      class = "showcase-layout-primitives-viewport",
      layout
    )
  })
  shiny::outputOptions(
    output,
    "showcase_layout_primitives_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_layout_primitives_preview_code <- showcase_render_code({
    values <- state()
    layout_primitives_demo_code(
      values,
      layout_primitives_demo_specs(values)
    )
  })
  shiny::outputOptions(
    output,
    "showcase_layout_primitives_preview_code",
    suspendWhenHidden = FALSE
  )

  output$showcase_layout_primitives_api_table <- shiny::renderUI({
    showcase_api_table(data.frame(
      Argument = c("block_stack", "block_cluster", "block_grid"),
      Type = c(
        "..., gap, align, class",
        "..., gap, align, justify, wrap, class",
        "..., min_width, gap, align, class"
      ),
      Default = c(
        'gap = "md", align = "stretch"',
        'gap = "sm", align = "center", justify = "start", wrap = TRUE',
        'min_width = "16rem", gap = "md", align = "stretch"'
      ),
      Description = c(
        "Vertical flow with semantic spacing.",
        "Horizontal grouping with optional wrapping and distribution.",
        "Responsive auto-fit grid protected against mobile overflow."
      )
    ))
  })
  shiny::outputOptions(
    output,
    "showcase_layout_primitives_api_table",
    suspendWhenHidden = FALSE
  )
}

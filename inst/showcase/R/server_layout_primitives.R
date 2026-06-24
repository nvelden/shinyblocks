layout_primitives_demo_items <- function() {
  specs <- list(
    list(label = "Analytics", height = "5.5rem"),
    list(label = "Reports", height = "3.5rem"),
    list(label = "Settings", height = "4.5rem"),
    list(label = "Billing", height = "6rem")
  )
  lapply(specs, function(spec) {
    htmltools::div(
      style = paste0(
        "padding: 0.875rem; border: 1px solid var(--border); ",
        "border-radius: 0.5rem; background: var(--card); ",
        "color: var(--card-foreground); min-width: 7rem; ",
        "min-height: ", spec$height, ";"
      ),
      spec$label
    )
  })
}

register_layout_primitives_showcase <- function(input, output, session) {
  state <- shiny::reactive({
    list(
      type = input$showcase_layout_primitives_type %||% "stack",
      gap = input$showcase_layout_primitives_gap %||% "md",
      align = input$showcase_layout_primitives_align %||% "stretch",
      justify = input$showcase_layout_primitives_justify %||% "start",
      wrap = isTRUE(input$showcase_layout_primitives_wrap),
      min_width = input$showcase_layout_primitives_min_width %||% "10rem"
    )
  })

  output$showcase_layout_primitives_preview_ui <- shiny::renderUI({
    values <- state()
    items <- layout_primitives_demo_items()

    switch(
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
  })
  shiny::outputOptions(
    output,
    "showcase_layout_primitives_preview_ui",
    suspendWhenHidden = FALSE
  )

  output$showcase_layout_primitives_preview_code <- showcase_render_code({
    values <- state()
    args <- c(
      sprintf('gap = "%s"', values$gap),
      sprintf('align = "%s"', values$align)
    )
    if (identical(values$type, "cluster")) {
      args <- c(
        args,
        sprintf('justify = "%s"', values$justify),
        sprintf("wrap = %s", toupper(as.character(values$wrap)))
      )
    }
    if (identical(values$type, "grid")) {
      args <- c(sprintf('min_width = "%s"', values$min_width), args)
    }

    paste0(
      "block_", values$type, "(\n",
      "  ", paste(args, collapse = ",\n  "), ",\n",
      '  block_card(title = "Analytics"),\n',
      '  block_card(title = "Reports"),\n',
      '  block_card(title = "Settings")\n',
      ")"
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

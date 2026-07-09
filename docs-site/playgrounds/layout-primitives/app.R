# Install shinyblocks (pre-built WebAssembly binary) from r-universe.
# NOTE: must be installed.packages(), not requireNamespace() - webR shims
# requireNamespace() and it returns NULL (not FALSE) for packages missing
# from the default webR repo, so negating its result errors.
if (!"shinyblocks" %in% rownames(installed.packages())) {
  install.packages(
    "shinyblocks",
    repos = c("https://nvelden.r-universe.dev", "https://repo.r-wasm.org")
  )
}

library(shiny)
library(shinyblocks)

`%||%` <- function(a, b) if (is.null(a)) b else a

demo_specs <- function(values) {
  specs <- list(
    list(title = "Analytics", description = "Track product usage.", height = "8rem"),
    list(title = "Reports", description = "Review weekly summaries.", height = "14rem"),
    list(title = "Settings", description = "Manage preferences.", height = "11rem"),
    list(title = "Billing", description = "Update invoices and plans.", height = "16rem")
  )
  specs <- specs[seq_len(values$count)]

  lapply(specs, function(spec) {
    style <- switch(values$type,
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

demo_items <- function(specs) {
  lapply(specs, function(spec) {
    block_card(
      title = spec$title,
      description = spec$description,
      style = spec$style
    )
  })
}

demo_code <- function(values, specs) {
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
    "# The container min-height gives the row vertical slack so alignment shows.\n",
    "htmltools::div(\n",
    '  style = "min-height: 16rem;",\n',
    paste0("  ", gsub("\n", "\n  ", layout_code, fixed = TRUE)), "\n",
    ")"
  )
}

ui <- block_page(
  title = "shinyblocks - Layout Primitives playground",
  theme = htmltools::tags$link(
    rel = "stylesheet",
    href = "../../../shinyblocks-runtime-override.css"
  ),
  htmltools::div(
    `data-shinyblocks-root` = "",
    style = "padding: 1rem; max-width: 100%; box-sizing: border-box; overflow-x: hidden;",
    block_cluster(
      gap = "lg",
      align = "start",
      class = "showcase-playground__split",
      block_card(
        title = "Controls",
        class = "showcase-playground__controls",
        block_stack(
          gap = "md",
          block_field(
            block_field_label("Primitive", `for` = "layout_primitives_type"),
            block_select(
              "layout_primitives_type",
              choices = c(
                "Stack" = "stack",
                "Cluster" = "cluster",
                "Grid" = "grid"
              ),
              selected = "stack",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("Gap", `for` = "layout_primitives_gap"),
            block_select(
              "layout_primitives_gap",
              choices = c("Small" = "sm", "Medium" = "md", "Large" = "lg"),
              selected = "md",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("Cross-axis alignment", `for` = "layout_primitives_align"),
            block_select(
              "layout_primitives_align",
              choices = c(
                "Stretch" = "stretch",
                "Start" = "start",
                "Center" = "center",
                "End" = "end"
              ),
              selected = "stretch",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("Items", `for` = "layout_primitives_count"),
            block_select(
              "layout_primitives_count",
              choices = c("Two" = "2", "Three" = "3", "Four" = "4"),
              selected = "4",
              size = "sm"
            )
          ),
          conditionalPanel(
            condition = "input.layout_primitives_type == 'cluster'",
            block_stack(
              gap = "md",
              block_field(
                block_field_label("justify", `for` = "layout_primitives_justify"),
                block_select(
                  "layout_primitives_justify",
                  choices = c(
                    "Start" = "start",
                    "Center" = "center",
                    "End" = "end",
                    "Space between" = "between"
                  ),
                  selected = "start",
                  size = "sm"
                )
              ),
              block_field(
                block_checkbox(
                  "layout_primitives_wrap",
                  label = "Allow cluster wrapping",
                  value = TRUE
                )
              )
            )
          ),
          conditionalPanel(
            condition = "input.layout_primitives_type == 'grid'",
            block_field(
              block_field_label("Preferred column width", `for` = "layout_primitives_min_width"),
              block_select(
                "layout_primitives_min_width",
                choices = c(
                  "10rem" = "10rem",
                  "14rem" = "14rem",
                  "18rem" = "18rem",
                  "24rem" = "24rem"
                ),
                selected = "14rem",
                size = "sm"
              )
            )
          ),
          conditionalPanel(
            condition = "input.layout_primitives_type != 'stack'",
            block_field(
              block_checkbox(
                "layout_primitives_vary_heights",
                label = "Use different card heights",
                value = TRUE
              )
            )
          )
        )
      ),
      block_stack(
        gap = "lg",
        class = "showcase-playground__main",
        htmltools::div(
          htmltools::tags$div(
            class = "showcase-playground__label",
            "Preview"
          ),
          htmltools::div(
            class = "showcase-preview-canvas showcase-preview-canvas--stretch",
            style = "padding: 1.25rem; min-height: 200px; border-style: dashed;",
            uiOutput("layout_primitives_preview")
          )
        ),
        htmltools::div(
          htmltools::tags$div(
            class = "showcase-playground__label showcase-playground__label--code",
            "UI Definition"
          ),
          uiOutput("layout_primitives_code")
        ),
        block_card(
          title = "API Reference",
          block_table(
            data.frame(
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
            ),
            columns = list(
              Argument = table_column(width = "11rem"),
              Type = table_column(width = "16rem"),
              Default = table_column(width = "8rem"),
              Description = table_column(width = "28rem")
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  state <- reactive({
    list(
      type = input$layout_primitives_type %||% "stack",
      gap = input$layout_primitives_gap %||% "md",
      align = input$layout_primitives_align %||% "stretch",
      justify = input$layout_primitives_justify %||% "start",
      wrap = isTRUE(input$layout_primitives_wrap %||% TRUE),
      min_width = input$layout_primitives_min_width %||% "14rem",
      count = as.integer(input$layout_primitives_count %||% "4"),
      vary_heights = isTRUE(input$layout_primitives_vary_heights %||% TRUE)
    )
  })

  output$layout_primitives_preview <- renderUI({
    values <- state()
    specs <- demo_specs(values)
    items <- demo_items(specs)
    tryCatch(
      {
        layout <- switch(values$type,
          cluster = do.call(
            block_cluster,
            c(items, list(
              gap = values$gap,
              align = values$align,
              justify = values$justify,
              wrap = values$wrap
            ))
          ),
          grid = do.call(
            block_grid,
            c(items, list(
              min_width = values$min_width,
              gap = values$gap,
              align = values$align
            ))
          ),
          do.call(
            block_stack,
            c(items, list(gap = values$gap, align = values$align))
          )
        )

        if (identical(values$type, "cluster")) {
          layout <- htmltools::div(
            class = "showcase-layout-primitives-cluster-frame",
            layout
          )
        }

        htmltools::div(
          class = "showcase-layout-primitives-viewport",
          layout
        )
      },
      error = function(e) block_alert(e$message, variant = "destructive")
    )
  })
  outputOptions(output, "layout_primitives_preview", suspendWhenHidden = FALSE)

  output$layout_primitives_code <- renderUI({
    values <- state()
    block_code(
      demo_code(values, demo_specs(values)),
      language = "r",
      line_numbers = TRUE
    )
  })
  outputOptions(output, "layout_primitives_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)

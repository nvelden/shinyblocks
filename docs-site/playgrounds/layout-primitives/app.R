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
  if (!mounted) webr::mount("/packages", "/shinyblocks/playgrounds/library.data.gz")
  .libPaths(c("/packages", .libPaths()))
}

library(shiny)
do.call(library, list("shinyblocks", character.only = TRUE))

`%||%` <- function(a, b) if (is.null(a)) b else a

string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

demo_items <- function() {
  lapply(c("Analytics", "Reports", "Settings"), function(label) {
    htmltools::div(
      style = paste(
        "padding: 0.875rem; border: 1px solid var(--border);",
        "border-radius: 0.5rem; background: var(--card);",
        "color: var(--card-foreground); min-width: 7rem;"
      ),
      label
    )
  })
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
      block_card(
        title = "Controls",
        class = "showcase-playground__controls",
        style = "flex: 1; min-width: 280px; max-width: 320px;",
        block_stack(
          gap = "md",
          block_field(
            block_field_label("type", `for` = "layout_primitives_type"),
            block_select(
              "layout_primitives_type",
              choices = c("stack", "cluster", "grid"),
              selected = "stack",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("gap", `for` = "layout_primitives_gap"),
            block_select(
              "layout_primitives_gap",
              choices = c("sm", "md", "lg"),
              selected = "md",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("align", `for` = "layout_primitives_align"),
            block_select(
              "layout_primitives_align",
              choices = c("stretch", "start", "center", "end"),
              selected = "stretch",
              size = "sm"
            )
          ),
          block_field(
            block_field_label("cluster justify", `for` = "layout_primitives_justify"),
            block_select(
              "layout_primitives_justify",
              choices = c("start", "center", "end", "between"),
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
          ),
          block_field(
            block_field_label("grid min_width", `for` = "layout_primitives_min_width"),
            block_input("layout_primitives_min_width", value = "10rem")
          )
        )
      ),
      block_stack(
        gap = "lg",
        class = "showcase-playground__main",
        htmltools::div(
          htmltools::tags$div(
            style = "font-size: 0.875rem; font-weight: 600; margin-bottom: 0.5rem;",
            "Preview"
          ),
          htmltools::div(
            style = paste(
              "padding: 2rem; min-height: 240px;",
              "border: 1px dashed var(--border); border-radius: 0.75rem;",
              "background: color-mix(in oklab, var(--muted) 25%, transparent);"
            ),
            uiOutput("layout_primitives_preview")
          )
        ),
        htmltools::div(
          htmltools::tags$div(
            style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
            "UI Definition"
          ),
          uiOutput("layout_primitives_code")
        ),
        block_card(
          title = "API Reference",
          block_table(data.frame(
            Function = c("block_stack()", "block_cluster()", "block_grid()"),
            Purpose = c(
              "Vertical flow",
              "Horizontal/wrapping group",
              "Responsive auto-fit grid"
            )
          ))
        ),
        style = "flex: 1.2; min-width: 320px;"
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
      wrap = isTRUE(input$layout_primitives_wrap),
      min_width = input$layout_primitives_min_width %||% "10rem"
    )
  })

  output$layout_primitives_preview <- renderUI({
    values <- state()
    items <- demo_items()
    tryCatch(
      switch(
        values$type,
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
        do.call(block_stack, c(items, list(gap = values$gap, align = values$align)))
      ),
      error = function(e) block_alert(e$message, variant = "destructive")
    )
  })
  outputOptions(output, "layout_primitives_preview", suspendWhenHidden = FALSE)

  output$layout_primitives_code <- renderUI({
    values <- state()
    args <- c(
      paste0("gap = ", string_literal(values$gap)),
      paste0("align = ", string_literal(values$align))
    )
    if (identical(values$type, "cluster")) {
      args <- c(
        args,
        paste0("justify = ", string_literal(values$justify)),
        paste0("wrap = ", toupper(as.character(values$wrap)))
      )
    }
    if (identical(values$type, "grid")) {
      args <- c(paste0("min_width = ", string_literal(values$min_width)), args)
    }
    block_code(
      paste0(
        "block_", values$type, "(\n",
        "  ", paste(args, collapse = ",\n  "), ",\n",
        '  block_card(title = "Analytics"),\n',
        '  block_card(title = "Reports"),\n',
        '  block_card(title = "Settings")\n',
        ")"
      ),
      language = "r",
      line_numbers = TRUE
    )
  })
  outputOptions(output, "layout_primitives_code", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)

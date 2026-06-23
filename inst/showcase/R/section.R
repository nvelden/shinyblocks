sb_section <- function(id, title, lead, example_path, active = FALSE) {
  ex <- render_example(example_path)
  scoped_render <- scope_showcase_theme(ex$rendered, id)

  htmltools::tags$section(
    id = id,
    `data-sb-section` = id,
    `aria-labelledby` = paste0(id, "-title"),
    hidden = if (!active) NA else NULL,
    style = "display: flex; flex-direction: column; gap: 1rem;",
    htmltools::tags$h2(
      id = paste0(id, "-title"),
      style = paste(
        "font-size: 1.25rem;",
        "font-weight: 600;",
        "letter-spacing: -0.025em;",
        "margin: 0;"
      ),
      title
    ),
    if (!is.null(lead)) {
      htmltools::tags$p(
        style = "color: var(--muted-foreground); margin: 0;",
        lead
      )
    },
    htmltools::tags$div(
      `data-sb-preview` = id,
      scoped_render
    ),
    htmltools::tags$details(
      htmltools::tags$summary(
        style = paste(
          "cursor: pointer;",
          "color: var(--muted-foreground);",
          "font-size: 0.875rem;",
          "user-select: none;"
        ),
        "View source"
      ),
      htmltools::tags$div(
        style = "margin-top: 0.5rem;",
        block_code(
          code = ex$code,
          language = "r",
          copyable = TRUE,
          line_numbers = TRUE
        )
      )
    )
  )
}

showcase_render_code <- function(expr, env = parent.frame()) {
  quoted <- substitute(expr)
  force(env)
  shiny::renderUI({
    value <- eval(quoted, envir = env)
    if (is.null(value) || !length(value)) {
      value <- ""
    }
    block_code(
      code = paste(as.character(value), collapse = "\n"),
      language = "r",
      copyable = TRUE,
      line_numbers = TRUE
    )
  })
}

showcase_api_table <- function(data) {
  block_table(
    data,
    columns = list(
      Argument = table_column(width = "11rem"),
      Type = table_column(width = "16rem"),
      Default = table_column(width = "8rem"),
      Description = table_column(width = "28rem")
    ),
    class = "showcase-api-table"
  )
}

# --- Shared output-playground helpers --------------------------------------
# Used by the image/plot output showcases to build live block_*_output() calls
# and to mirror the resolved arguments back into the "UI Definition" code panel.

# Treat a blank/whitespace-only control value as an unset (NULL) argument.
showcase_blank_to_null <- function(x) {
  if (is.null(x) || !nzchar(trimws(x))) NULL else x
}

# Quote a value as an R string literal, escaping embedded quotes/backslashes.
showcase_string_literal <- function(value) {
  paste0("\"", gsub("([\"\\\\])", "\\\\\\1", value, perl = TRUE), "\"")
}

# Live click/dblclick/hover/brush *Opts() for a block_*_output() preview call.
showcase_interaction_args <- function(prefix) {
  list(
    click = shiny::clickOpts(id = paste0(prefix, "_click")),
    dblclick = shiny::dblclickOpts(id = paste0(prefix, "_dblclick")),
    hover = shiny::hoverOpts(id = paste0(prefix, "_hover")),
    brush = shiny::brushOpts(id = paste0(prefix, "_brush"))
  )
}

# The same interaction options rendered as source lines for the code panel.
showcase_interaction_code_args <- function(prefix) {
  c(
    paste0("click = shiny::clickOpts(id = ", showcase_string_literal(paste0(prefix, "_click")), ")"),
    paste0("dblclick = shiny::dblclickOpts(id = ", showcase_string_literal(paste0(prefix, "_dblclick")), ")"),
    paste0("hover = shiny::hoverOpts(id = ", showcase_string_literal(paste0(prefix, "_hover")), ")"),
    paste0("brush = shiny::brushOpts(id = ", showcase_string_literal(paste0(prefix, "_brush")), ")")
  )
}

showcase_format_interaction_value <- function(value) {
  if (is.null(value)) {
    return("<NULL>")
  }
  paste(utils::capture.output(utils::str(value, max.level = 1, give.attr = FALSE)), collapse = "\n")
}

# Dump the current click/dblclick/hover/brush input values for the live demo.
showcase_interaction_values <- function(input, prefix) {
  ids <- paste0(prefix, c("_click", "_dblclick", "_hover", "_brush"))
  paste(
    vapply(ids, function(id) {
      paste0("input$", id, "\n", showcase_format_interaction_value(input[[id]]))
    }, character(1)),
    collapse = "\n\n"
  )
}

# Build the demo-data reactive (+ its regenerate observer) shared by the
# image/plot output showcases. Pressing the `<prefix>_regen` button reseeds the
# sample, so each press is reproducible. No other showcase demo uses the RNG, so
# a plain set.seed() is fine here.
showcase_output_demo_values <- function(input, prefix) {
  regen <- shiny::reactiveVal(0)
  shiny::observeEvent(input[[paste0(prefix, "_regen")]], {
    regen(regen() + 1)
  })
  shiny::reactive({
    set.seed(100 + regen())
    stats::setNames(
      round(runif(4, 40, 100)),
      c("North", "South", "East", "West")
    )
  })
}

# Resolve the live frame controls into the arg list both output showcases share.
# `include_fit = TRUE` adds the image-only object-fit control.
showcase_output_frame_state <- function(input, prefix, include_fit = FALSE) {
  ctrl <- function(suffix) input[[paste0(prefix, suffix)]]
  aspect_raw <- ctrl("_aspect") %||% "16/9"
  state <- list(
    caption = showcase_blank_to_null(ctrl("_caption")),
    width = showcase_blank_to_null(ctrl("_width")),
    height = showcase_blank_to_null(ctrl("_height")),
    aspect = if (identical(aspect_raw, "none")) NULL else aspect_raw,
    border = isTRUE(ctrl("_border")),
    rounded = isTRUE(ctrl("_rounded")),
    class = if (isTRUE(ctrl("_class"))) "border-dashed" else NULL,
    style = showcase_blank_to_null(ctrl("_style"))
  )
  if (include_fit) {
    state$fit <- ctrl("_fit") %||% "cover"
  }
  state
}

# Frame state -> named arg list for the live block_*_output() preview call.
showcase_output_preview_args <- function(s) {
  args <- list(
    width = s$width %||% "100%",
    height = s$height,
    aspect = s$aspect,
    border = s$border,
    rounded = s$rounded,
    caption = s$caption,
    class = s$class,
    style = s$style
  )
  if (!is.null(s$fit)) {
    args$fit <- s$fit
  }
  args
}

# Frame state -> the block_*_output() source shown in the "UI Definition" panel.
# Only non-default args are emitted, mirroring how an author would write it.
showcase_output_preview_code <- function(s, constructor, output_id, prefix) {
  args <- paste0("id = ", showcase_string_literal(output_id))
  if (!is.null(s$width)) args <- c(args, paste0("width = ", showcase_string_literal(s$width)))
  if (!is.null(s$height)) args <- c(args, paste0("height = ", showcase_string_literal(s$height)))
  if (!is.null(s$aspect)) args <- c(args, paste0("aspect = ", showcase_string_literal(s$aspect)))
  if (!is.null(s$fit) && !identical(s$fit, "cover")) {
    args <- c(args, paste0("fit = ", showcase_string_literal(s$fit)))
  }
  if (isTRUE(s$border)) args <- c(args, "border = TRUE")
  if (!isTRUE(s$rounded)) args <- c(args, "rounded = FALSE")
  if (!is.null(s$caption)) args <- c(args, paste0("caption = ", showcase_string_literal(s$caption)))
  args <- c(args, showcase_interaction_code_args(prefix))
  if (!is.null(s$class)) args <- c(args, paste0("class = ", showcase_string_literal(s$class)))
  if (!is.null(s$style)) args <- c(args, paste0("style = ", showcase_string_literal(s$style)))
  paste0(constructor, "(\n  ", paste(args, collapse = ",\n  "), "\n)")
}

# Shared "values <- c(...)" line for the Server Render code panel.
showcase_output_data_line <- function(v) {
  paste0(
    "values <- c(",
    paste(sprintf("%s = %d", names(v), as.integer(v)), collapse = ", "),
    ")  # Regenerate draws a new sample"
  )
}

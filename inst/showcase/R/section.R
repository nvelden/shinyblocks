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

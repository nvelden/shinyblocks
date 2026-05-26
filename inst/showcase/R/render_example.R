showcase_action_button <- function(
  input_id,
  label,
  variant = "outline",
  size = "sm",
  class = NULL
) {
  block_button(
    label,
    id = input_id,
    variant = variant,
    size = size,
    class = class
  )
}

# Compact controls-panel + preview/code layout shared with the docs-site
# Shinylive playgrounds, so showcase tabs and embedded playgrounds stay
# visually aligned. Pass groups built with `showcase_controls_group()`.
showcase_playground_layout <- function(
  controls,
  preview_output_id,
  code_output_id,
  preview_canvas_style = NULL,
  extra_outputs = NULL
) {
  default_canvas_style <- paste(
    "position: relative; display: flex; align-items: center; justify-content: center;",
    "padding: 3rem 2rem; background: var(--card);",
    "border: 1px solid var(--border); border-radius: 0.75rem;",
    "min-height: 160px; box-sizing: border-box;",
    "box-shadow: 0 1px 2px rgb(0 0 0 / 0.05);"
  )

  htmltools::tags$div(
    style = "display: flex; gap: 1.5rem; flex-wrap: wrap; align-items: flex-start;",
    htmltools::tags$div(
      style = paste(
        "flex: 1; min-width: 280px; max-width: 320px;",
        "border: 1px solid var(--border); border-radius: 0.75rem;",
        "padding: 1.25rem; display: flex; flex-direction: column; gap: 1.25rem;",
        "background: color-mix(in oklab, var(--muted) 40%, transparent);"
      ),
      controls
    ),
    htmltools::tags$div(
      style = "flex: 2; min-width: 320px; display: flex; flex-direction: column; gap: 1.25rem;",
      htmltools::tags$div(
        style = "display: flex; flex-direction: column; gap: 0.5rem;",
        htmltools::tags$div(
          style = "font-size: 0.875rem; font-weight: 600; color: var(--foreground);",
          "Preview"
        ),
        htmltools::tags$div(
          style = preview_canvas_style %||% default_canvas_style,
          shiny::uiOutput(preview_output_id)
        )
      ),
      extra_outputs,
      htmltools::tags$div(
        htmltools::tags$div(
          style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.35rem;",
          "UI Definition"
        ),
        shiny::uiOutput(code_output_id)
      )
    )
  )
}

showcase_controls_group <- function(title, ..., first = FALSE) {
  border_style <- if (isTRUE(first)) "" else "border-top: 1px solid var(--border); padding-top: 0.75rem;"
  htmltools::tags$div(
    style = paste("display: flex; flex-direction: column; gap: 0.75rem;", border_style),
    htmltools::tags$h4(
      style = "font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted-foreground); margin: 0;",
      title
    ),
    ...
  )
}

render_example <- function(path) {
  code <- readLines(path, warn = FALSE, encoding = "UTF-8")
  Encoding(code) <- "UTF-8"
  rendered <- eval(
    parse(text = code, encoding = "UTF-8"),
    envir = new.env(parent = environment(render_example))
  )
  list(rendered = rendered, code = paste(code, collapse = "\n"))
}

scope_showcase_theme <- function(tag, scope_id) {
  if (inherits(tag, "shiny.tag")) {
    if (
      identical(tag$name, "style") &&
        identical(tag$attribs[["class"]] %||% "", "sb-theme-overrides")
    ) {
      css <- as.character(tag$children[[1]])
      prefix <- paste0('[data-sb-preview="', scope_id, '"]')
      scoped <- gsub("\\.sb-app", prefix, css, perl = TRUE)
      tag$children[[1]] <- htmltools::HTML(scoped)
      return(tag)
    }

    if (length(tag$children) > 0) {
      tag$children <- lapply(
        tag$children,
        scope_showcase_theme,
        scope_id = scope_id
      )
    }

    return(tag)
  }

  if (inherits(tag, "shiny.tag.list") || is.list(tag)) {
    return(structure(
      lapply(tag, scope_showcase_theme, scope_id = scope_id),
      class = class(tag)
    ))
  }

  tag
}

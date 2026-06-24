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
#
# Layout is expressed through the package primitives (`block_stack()`) and
# purpose-specific showcase classes in `inst/showcase/www/showcase.css`; pass
# `preview_canvas_class` for a named visual variant and reserve
# `preview_canvas_style` for non-layout visual overrides only.
showcase_playground_layout <- function(
  controls,
  preview_output_id,
  code_output_id,
  preview_canvas_class = NULL,
  preview_canvas_style = NULL,
  extra_outputs = NULL
) {
  htmltools::tags$section(
    `aria-label` = "Interactive Playground",
    class = "showcase-playground",
    block_cluster(
      gap = "lg",
      align = "start",
      class = "showcase-playground__split",
      block_card(
        title = "Controls",
        class = "showcase-playground__controls",
        controls
      ),
      block_stack(
        gap = "lg",
        class = "showcase-playground__main",
        block_stack(
          gap = "sm",
          htmltools::tags$div(class = "showcase-playground__label", "Preview"),
          htmltools::tags$div(
            class = paste(c("showcase-preview-canvas", preview_canvas_class), collapse = " "),
            style = preview_canvas_style,
            shiny::uiOutput(preview_output_id)
          )
        ),
        extra_outputs,
        htmltools::tags$div(
          htmltools::tags$div(
            class = "showcase-playground__label showcase-playground__label--code",
            "UI Definition"
          ),
          shiny::uiOutput(code_output_id)
        )
      )
    )
  )
}

showcase_controls_group <- function(title, ..., first = FALSE) {
  block_stack(
    gap = "sm",
    class = if (isTRUE(first)) {
      "showcase-controls-group showcase-controls-group--first"
    } else {
      "showcase-controls-group"
    },
    htmltools::tags$h4(class = "showcase-controls-group__title", title),
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

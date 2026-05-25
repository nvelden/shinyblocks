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

#' Create a value box
#'
#' @param title Value box title.
#' @param value Primary value.
#' @param ... Additional value box body content.
#' @param description Optional value box description.
#' @param icon Optional icon tag or vendored icon name.
#' @param variant Visual variant.
#' @param class Additional classes.
#' @param style Optional inline custom styles.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_value_box <- function(
  title,
  value,
  ...,
  description = NULL,
  icon = NULL,
  variant = c("default", "accent", "destructive"),
  class = NULL,
  style = NULL
) {
  variant <- match_arg(variant, c("default", "accent", "destructive"))
  icon_tag <- set_icon_position(icon, "inline-start")

  runtime_component(
    component = "value-box",
    props = list(
      titleHtml = html_fragment(title),
      valueHtml = html_fragment(value),
      descriptionHtml = if (!is.null(description)) html_fragment(description) else NULL,
      contentHtml = html_fragment(...),
      iconHtml = if (!is.null(icon_tag)) html_fragment(icon_tag) else NULL,
      variant = variant
    ),
    class = class,
    style = style
  )
}

#' Create a separator
#'
#' @param orientation Separator orientation.
#' @param decorative Whether the separator is decorative only.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_separator <- function(
  orientation = c("horizontal", "vertical"),
  decorative = TRUE,
  class = NULL
) {
  orientation <- match_arg(
    orientation,
    c("horizontal", "vertical"),
    "orientation"
  )

  runtime_component(
    component = "separator",
    props = list(
      orientation = orientation,
      decorative = isTRUE(decorative)
    ),
    class = class
  )
}

#' Create a skeleton placeholder
#'
#' @param class Additional classes.
#' @param ... Additional attributes passed to `htmltools::tags$div`.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_skeleton <- function(class = NULL, ...) {
  attrs <- named_attrs(list(...))
  if (!is.null(attrs$style)) {
    attrs$style <- normalize_runtime_style(attrs$style)
  }
  extra_class <- attrs[["class"]]
  class <- if (is.null(class) && is.null(extra_class)) {
    NULL
  } else {
    merge_classes(class, extra_class)
  }
  attrs[["class"]] <- NULL

  runtime_component(
    component = "skeleton",
    props = list(
      attrs = attrs
    ),
    class = class
  )
}

#' Create a spinner
#'
#' @param label Accessible `aria-label` announced by assistive technology.
#' @param size Visual size.
#' @param color Semantic color.
#' @param class Additional classes.
#' @param style Optional inline custom styles.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_spinner <- function(
  label = "Loading",
  size = c("default", "sm", "lg"),
  color = c("default", "muted", "destructive"),
  class = NULL,
  style = NULL
) {
  size <- match_arg(size, c("default", "sm", "lg"))
  color <- match_arg(color, c("default", "muted", "destructive"))

  runtime_component(
    component = "spinner",
    props = list(
      label = label,
      size = size,
      color = color
    ),
    class = class,
    style = style
  )
}

#' Create an empty state
#'
#' @param title Empty-state title.
#' @param ... Additional empty-state body content.
#' @param description Optional description.
#' @param icon Optional icon tag or vendored icon name.
#' @param action Optional action content.
#' @param class Additional classes.
#' @param style Optional inline custom styles.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_empty <- function(
  title,
  ...,
  description = NULL,
  icon = NULL,
  action = NULL,
  class = NULL,
  style = NULL
) {
  icon_tag <- set_icon_position(icon, "inline-start")

  runtime_component(
    component = "empty",
    props = list(
      titleHtml = html_fragment(title),
      descriptionHtml = if (!is.null(description)) html_fragment(description) else NULL,
      contentHtml = html_fragment(...),
      iconHtml = if (!is.null(icon_tag)) html_fragment(icon_tag) else NULL,
      actionHtml = if (!is.null(action)) html_fragment(action) else NULL
    ),
    class = class,
    style = style
  )
}

#' Create a dashboard card
#'
#' @param ... Card body content.
#' @param title Optional card title.
#' @param value Optional primary value.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card <- function(..., title = NULL, value = NULL, class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$article(
      class = merge_classes("sb-card", class),
      if (!is.null(title)) htmltools::tags$h3(class = "sb-card-title", title),
      if (!is.null(value)) htmltools::tags$div(class = "sb-card-value", value),
      htmltools::tags$div(class = "sb-card-body", ...)
    )
  )
}

#' Create a modern button
#'
#' @param label Button label.
#' @param variant Visual variant.
#' @param size Button size.
#' @param icon Optional icon tag or vendored icon name.
#' @param icon_position Whether the icon appears before or after the label.
#' @param ... Additional attributes passed to `htmltools::tags$button`.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family action
#' @export
block_button <- function(
  label,
  variant = c(
    "default",
    "secondary",
    "outline",
    "ghost",
    "destructive",
    "link"
  ),
  size = c("default", "sm", "lg", "icon"),
  icon = NULL,
  icon_position = c("inline-start", "inline-end"),
  ...,
  class = NULL
) {
  variant <- match_arg(
    variant,
    c("default", "secondary", "outline", "ghost", "destructive", "link")
  )
  size <- match_arg(size, c("default", "sm", "lg", "icon"))
  icon_position <- match_arg(
    icon_position,
    c("inline-start", "inline-end"),
    "icon_position"
  )
  icon <- set_icon_position(icon, icon_position)

  attach_shinyblocks_deps(
    htmltools::tags$button(
      class = merge_classes(
        "sb-button",
        paste0("sb-button-", variant),
        paste0("sb-button-size-", size),
        class
      ),
      type = "button",
      ...,
      if (identical(icon_position, "inline-start")) icon,
      label,
      if (identical(icon_position, "inline-end")) icon
    )
  )
}

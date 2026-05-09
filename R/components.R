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

#' Create a badge
#'
#' @param label Badge label.
#' @param variant Visual variant.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_badge <- function(
  label,
  variant = c("default", "secondary", "outline", "destructive"),
  class = NULL
) {
  variant <- match_arg(
    variant,
    c("default", "secondary", "outline", "destructive")
  )

  attach_shinyblocks_deps(
    htmltools::tags$span(
      class = merge_classes(
        "sb-badge",
        paste0("sb-badge-", variant),
        class
      ),
      label
    )
  )
}

#' Create an alert title
#'
#' @param ... Alert title content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_alert_title <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$h5(
      class = merge_classes("sb-alert-title", class),
      `data-sb-child` = "alert-title",
      ...
    )
  )
}

#' Create an alert description
#'
#' @param ... Alert description content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_alert_description <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-alert-description", class),
      `data-sb-child` = "alert-description",
      ...
    )
  )
}

#' Create an alert
#'
#' @param title Alert title. Required for accessibility.
#' @param ... Additional alert body content.
#' @param description Optional alert description.
#' @param icon Optional icon tag or vendored icon name.
#' @param variant Visual variant.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_alert <- function(
  title,
  ...,
  description = NULL,
  icon = "info",
  variant = c("default", "destructive"),
  class = NULL
) {
  if (missing(title) || is.null(title)) {
    stop("`title` is required.", call. = FALSE)
  }

  variant <- match_arg(variant, c("default", "destructive"))
  title_tag <- as_alert_child(title, "alert-title", block_alert_title)
  description_tag <- as_alert_child(
    description,
    "alert-description",
    block_alert_description
  )
  icon_tag <- set_icon_position(icon, "inline-start")

  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes(
        "sb-alert",
        paste0("sb-alert-", variant),
        class
      ),
      role = "alert",
      if (!is.null(icon_tag)) {
        htmltools::tags$div(class = "sb-alert-icon", icon_tag)
      },
      htmltools::tags$div(
        class = "sb-alert-content",
        title_tag,
        description_tag,
        ...
      )
    )
  )
}

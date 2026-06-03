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

#' Create an alert action
#'
#' @param ... Alert action content, such as a `block_button()`.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_alert_action <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-alert-action", class),
      `data-sb-child` = "alert-action",
      ...
    )
  )
}

#' Create an alert
#'
#' @param title Alert title. Required for accessibility.
#' @param ... Additional alert body content.
#' @param description Optional alert description.
#' @param action Optional action content, such as a `block_button()`.
#' @param icon Optional icon tag or vendored icon name.
#' @param variant Visual variant.
#' @param class Additional classes.
#' @param style Optional inline custom styles.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_alert <- function(
  title,
  ...,
  description = NULL,
  action = NULL,
  icon = "info",
  variant = c("default", "destructive", "success", "warning", "info"),
  class = NULL,
  style = NULL
) {
  if (missing(title) || is.null(title)) {
    stop("`title` is required.", call. = FALSE)
  }

  variant <- match_arg(
    variant,
    c("default", "destructive", "success", "warning", "info")
  )
  title_tag <- as_component_child(title, "alert-title", block_alert_title)
  description_tag <- as_component_child(
    description,
    "alert-description",
    block_alert_description
  )
  action_tag <- as_component_child(action, "alert-action", block_alert_action)
  icon_tag <- set_icon_position(icon, "inline-start")

  runtime_component(
    component = "alert",
    props = list(
      variant = variant,
      titleHtml = html_fragment(title_tag),
      descriptionHtml = if (!is.null(description_tag)) {
        html_fragment(description_tag)
      } else {
        NULL
      },
      contentHtml = html_fragment(...),
      iconHtml = if (!is.null(icon_tag)) html_fragment(icon_tag) else NULL,
      actionHtml = if (!is.null(action_tag)) html_fragment(action_tag) else NULL
    ),
    class = class,
    style = style
  )
}

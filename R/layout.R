#' Create a dashboard sidebar
#'
#' @param ... Sidebar content.
#' @param title Optional sidebar title.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family layout
#' @export
block_sidebar <- function(..., title = NULL, class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$aside(
      class = merge_classes("sb-sidebar", class),
      if (!is.null(title)) {
        htmltools::tags$div(class = "sb-sidebar-title", title)
      },
      htmltools::tags$nav(class = "sb-sidebar-nav", ...)
    )
  )
}

#' Create a dashboard header
#'
#' @param ... Header content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family layout
#' @export
block_header <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$header(class = merge_classes("sb-header", class), ...)
  )
}

#' Create a sidebar navigation item
#'
#' @param label Navigation label.
#' @param href Destination URL.
#' @param icon Optional icon tag or vendored icon name.
#' @param selected Whether the item is selected.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_nav_item <- function(
  label,
  href = "#",
  icon = NULL,
  selected = FALSE,
  class = NULL
) {
  icon <- set_icon_position(icon, "inline-start")

  attach_shinyblocks_deps(
    htmltools::tags$a(
      class = merge_classes("sb-nav-item", if (selected) "is-selected", class),
      href = href,
      `aria-current` = if (selected) "page" else NULL,
      `data-sb-child` = "nav-item",
      icon,
      htmltools::tags$span(class = "sb-nav-label", label)
    )
  )
}

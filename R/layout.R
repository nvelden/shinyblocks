#' Create a dashboard sidebar
#'
#' @param ... Sidebar content.
#' @param title Optional sidebar title.
#'
#' @return An `htmltools` tag.
#' @export
block_sidebar <- function(..., title = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$aside(
      class = "sb-sidebar",
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
#'
#' @return An `htmltools` tag.
#' @export
block_header <- function(...) {
  attach_shinyblocks_deps(
    htmltools::tags$header(class = "sb-header", ...)
  )
}

#' Create a sidebar navigation item
#'
#' @param label Navigation label.
#' @param href Destination URL.
#' @param icon Optional icon name.
#' @param selected Whether the item is selected.
#'
#' @return An `htmltools` tag.
#' @export
block_nav_item <- function(label, href = "#", icon = NULL, selected = FALSE) {
  attach_shinyblocks_deps(
    htmltools::tags$a(
      class = paste("sb-nav-item", if (selected) "is-selected"),
      href = href,
      `aria-current` = if (selected) "page" else NULL,
      if (!is.null(icon)) {
        htmltools::tags$span(class = "sb-nav-icon", `data-icon` = icon)
      },
      htmltools::tags$span(class = "sb-nav-label", label)
    )
  )
}

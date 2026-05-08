#' Create a dashboard sidebar
#'
#' @param ... Sidebar content.
#' @param title Optional sidebar title.
#'
#' @return An `htmltools` tag.
#' @export
shadcn_sidebar <- function(..., title = NULL) {
  shiny::tags$aside(
    class = "shadcn-sidebar",
    if (!is.null(title)) shiny::tags$div(class = "shadcn-sidebar-title", title),
    shiny::tags$nav(class = "shadcn-sidebar-nav", ...)
  )
}

#' Create a dashboard header
#'
#' @param ... Header content.
#'
#' @return An `htmltools` tag.
#' @export
shadcn_header <- function(...) {
  shiny::tags$header(class = "shadcn-header", ...)
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
shadcn_nav_item <- function(label, href = "#", icon = NULL, selected = FALSE) {
  shiny::tags$a(
    class = paste("shadcn-nav-item", if (selected) "is-selected"),
    href = href,
    `aria-current` = if (selected) "page" else NULL,
    if (!is.null(icon)) shiny::tags$span(class = "shadcn-nav-icon", `data-icon` = icon),
    shiny::tags$span(class = "shadcn-nav-label", label)
  )
}

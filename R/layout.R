#' Create a dashboard sidebar
#'
#' @param ... Sidebar content.
#' @param title Optional sidebar title.
#' @param collapsible Whether the sidebar can collapse on larger screens.
#' @param collapsed Whether the sidebar starts collapsed on larger screens.
#' @param id Optional sidebar DOM id.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family layout
#' @export
block_sidebar <- function(
  ...,
  title = NULL,
  collapsible = FALSE,
  collapsed = FALSE,
  id = NULL,
  class = NULL
) {
  children <- list(...)

  attach_shinyblocks_deps(
    htmltools::tags$aside(
      id = id,
      class = merge_classes("sb-sidebar", class),
      `data-collapsible` = tolower(as.character(isTRUE(collapsible))),
      `data-collapsed` = tolower(as.character(isTRUE(collapsed))),
      if (!is.null(title)) {
        htmltools::tags$div(
          class = "sb-sidebar-title",
          htmltools::tags$span(class = "sb-sidebar-title-text", title),
          if (isTRUE(collapsible)) {
            htmltools::tags$button(
              class = "sb-sidebar-toggle",
              type = "button",
              `aria-label` = "Toggle sidebar",
              `aria-expanded` = if (isTRUE(collapsed)) "false" else "true",
              block_icon("panel-left")
            )
          }
        )
      },
      sidebar_content(children)
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

#' Create a navigation container
#'
#' @param ... Navigation items.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family navigation
#' @export
block_nav <- function(..., class = NULL) {
  children <- list(...)
  validate_children(children, "nav-item", "block_nav")

  attach_shinyblocks_deps(
    htmltools::tags$nav(
      class = merge_classes("sb-nav", class),
      children
    )
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

sidebar_content <- function(children) {
  if (length(children) == 0) {
    return(NULL)
  }

  if (all(vapply(children, is_nav_item_tag, logical(1)))) {
    return(htmltools::tags$nav(class = "sb-sidebar-nav", children))
  }

  if (length(children) == 1 && is_nav_container_tag(children[[1]])) {
    nav <- children[[1]]
    nav$attribs$class <- merge_classes(nav$attribs$class, "sb-sidebar-nav")
    return(nav)
  }

  children
}

is_nav_item_tag <- function(x) {
  inherits(x, "shiny.tag") &&
    identical(x$attribs[["data-sb-child"]], "nav-item")
}

is_nav_container_tag <- function(x) {
  inherits(x, "shiny.tag") &&
    identical(x$name, "nav")
}

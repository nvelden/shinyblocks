#' Create a shadcn-inspired Shiny page
#'
#' @param ... Page body content.
#' @param title Browser page title.
#' @param sidebar Optional sidebar content.
#' @param header Optional header content.
#'
#' @return An `htmltools` tag list suitable for a Shiny UI.
#' @export
shadcn_page <- function(..., title = NULL, sidebar = NULL, header = NULL) {
  htmltools::tagList(
    shiny::tags$head(
      shiny::tags$title(title %||% "shinyshadcn"),
      shiny::tags$link(rel = "stylesheet", href = "shinyshadcn/shinyshadcn.css")
    ),
    shiny::tags$div(
      class = "shadcn-app",
      sidebar,
      shiny::tags$main(
        class = "shadcn-main",
        header,
        shiny::tags$section(class = "shadcn-content", ...)
      )
    )
  )
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

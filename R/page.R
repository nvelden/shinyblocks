#' Create a modern Shiny page
#'
#' @param ... Page body content.
#' @param title Browser page title.
#' @param sidebar Optional sidebar content.
#' @param header Optional header content.
#'
#' @return An `htmltools` tag list suitable for a Shiny UI.
#' @export
block_page <- function(..., title = NULL, sidebar = NULL, header = NULL) {
  htmltools::tagList(
    shiny::tags$head(
      shiny::tags$title(title %||% "shinyblocks"),
      shiny::tags$link(rel = "stylesheet", href = "shinyblocks/shinyblocks.css")
    ),
    shiny::tags$div(
      class = "sb-app",
      sidebar,
      shiny::tags$main(
        class = "sb-main",
        header,
        shiny::tags$section(class = "sb-content", ...)
      )
    )
  )
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

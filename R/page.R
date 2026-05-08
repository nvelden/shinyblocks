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
  attach_shinyblocks_deps(
    htmltools::tagList(
      htmltools::tags$head(
        htmltools::tags$title(title %||% "shinyblocks")
      ),
      htmltools::tags$div(
        class = "sb-app",
        sidebar,
        htmltools::tags$main(
          class = "sb-main",
          header,
          htmltools::tags$section(class = "sb-content", ...)
        )
      )
    )
  )
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

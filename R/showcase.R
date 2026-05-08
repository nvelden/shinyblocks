#' Run the shinyblocks showcase app
#'
#' @param ... Arguments passed to `shiny::runApp()`.
#'
#' @return The result of `shiny::runApp()`.
#' @export
run_showcase <- function(...) {
  app_dir <- system.file("showcase", package = "shinyblocks", mustWork = TRUE)
  shiny::runApp(app_dir, ...)
}

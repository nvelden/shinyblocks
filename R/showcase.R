#' Run the shinyblocks showcase app
#'
#' The showcase is a development-only asset: it ships in the source tree but is
#' excluded from the built package tarball, so this function only works from a
#' source checkout (e.g. via [devtools::load_all()]). It errors with a clear
#' message when the app cannot be found.
#'
#' @param ... Arguments passed to `shiny::runApp()`.
#'
#' @return The result of `shiny::runApp()`.
#' @export
run_showcase <- function(...) {
  app_dir <- system.file("showcase", package = "shinyblocks")
  if (!nzchar(app_dir) || !dir.exists(app_dir)) {
    stop(
      "The showcase app is a development-only asset and is not bundled with ",
      "the installed package. Run it from a source checkout of shinyblocks ",
      "(e.g. via `devtools::load_all()`).",
      call. = FALSE
    )
  }
  shiny::runApp(app_dir, ...)
}

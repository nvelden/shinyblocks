.onLoad <- function(libname, pkgname) {
  shiny::addResourcePath(
    prefix = "shinyblocks",
    directoryPath = system.file("www", package = pkgname)
  )

  shiny::registerInputHandler("shinyblocks.button", function(val, transport, name) {
    if (is.null(val)) return(NULL)
    class(val) <- c("shinyActionButtonValue", "shiny.actionButton", class(val))
    val
  }, force = TRUE)
}

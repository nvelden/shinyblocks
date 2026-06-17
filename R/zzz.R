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

  # Progress is display-only: its binding declares `type = "shinyblocks.progress"`
  # (so getType()/the payload agree) but reports no value. Register a handler so
  # Shiny accepts the typed message instead of erroring on an unknown type; it
  # always resolves to NULL, keeping `input$<id>` empty.
  shiny::registerInputHandler("shinyblocks.progress", function(val, transport, name) {
    NULL
  }, force = TRUE)
}

.onLoad <- function(libname, pkgname) {
  shiny::addResourcePath(
    prefix = "shinyblocks",
    directoryPath = system.file("www", package = pkgname)
  )
}

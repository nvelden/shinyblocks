.onLoad <- function(libname, pkgname) {
  shiny::addResourcePath(
    prefix = "shinyshadcn",
    directoryPath = system.file("www", package = pkgname)
  )
}

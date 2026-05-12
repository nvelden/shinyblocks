shinyblocks_dependency <- function() {
  if (identical(getOption("shinyblocks.asset_mode"), "app")) {
    htmltools::htmlDependency(
      name = "shinyblocks",
      version = shinyblocks_version(),
      src = c(href = "shinyblocks"),
      stylesheet = c("shinyblocks.css", "shinyblocks-runtime.css"),
      script = c("shinyblocks.js", "shinyblocks-runtime.js"),
      attachment = c(sprite = "icons/sprite.svg")
    )
  } else {
    htmltools::htmlDependency(
      name = "shinyblocks",
      version = shinyblocks_version(),
      src = "www",
      stylesheet = c("shinyblocks.css", "shinyblocks-runtime.css"),
      script = c("shinyblocks.js", "shinyblocks-runtime.js"),
      attachment = c(sprite = "icons/sprite.svg"),
      package = "shinyblocks"
    )
  }
}

attach_shinyblocks_deps <- function(tag) {
  htmltools::attachDependencies(
    tag,
    shinyblocks_dependency(),
    append = TRUE
  )
}

shinyblocks_version <- function() {
  version <- utils::packageDescription("shinyblocks", fields = "Version")

  if (is.na(version)) {
    version <- "0.0.0.9000"
  }

  version
}

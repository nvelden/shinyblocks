shinyblocks_dependency <- function() {
  if (identical(getOption("shinyblocks.asset_mode"), "app")) {
    htmltools::htmlDependency(
      name = "shinyblocks",
      version = shinyblocks_asset_version(),
      src = c(href = "shinyblocks"),
      stylesheet = c("shinyblocks.css", "shinyblocks-runtime.css"),
      script = c("shinyblocks.js", "shinyblocks-runtime.js"),
      attachment = c(sprite = "icons/sprite.svg")
    )
  } else {
    htmltools::htmlDependency(
      name = "shinyblocks",
      version = shinyblocks_asset_version(),
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

shinyblocks_asset_version <- function() {
  version <- shinyblocks_version()
  www <- system.file("www", package = "shinyblocks")
  if (!nzchar(www) && dir.exists("inst/www")) {
    www <- "inst/www"
  }
  if (!nzchar(www)) {
    return(version)
  }

  assets <- file.path(
    www,
    c(
      "shinyblocks.css",
      "shinyblocks-runtime.css",
      "shinyblocks.js",
      "shinyblocks-runtime.js",
      "icons/sprite.svg"
    )
  )
  assets <- assets[file.exists(assets)]
  if (!length(assets)) {
    return(version)
  }

  stamp <- max(as.numeric(file.info(assets)$mtime), na.rm = TRUE)
  if (!is.finite(stamp)) {
    return(version)
  }

  paste0(version, ".", as.integer(stamp))
}

block_favicon_link <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      path <- system.file("www", "favicon.svg", package = "shinyblocks")
      if (!nzchar(path) && file.exists("inst/www/favicon.svg")) {
        path <- "inst/www/favicon.svg"
      }
      if (!nzchar(path) || !file.exists(path)) {
        return(NULL)
      }
      svg <- paste(readLines(path, warn = FALSE), collapse = "")
      cache <<- paste0(
        "data:image/svg+xml;utf8,",
        utils::URLencode(svg, reserved = TRUE)
      )
    }
    htmltools::tags$link(rel = "icon", type = "image/svg+xml", href = cache)
  }
})

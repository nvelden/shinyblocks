.shinyblocks_assets <- c(
  "shinyblocks.css",
  "shinyblocks-runtime.css",
  "shinyblocks.js",
  "shinyblocks-runtime.js",
  "icons/sprite.svg"
)

shinyblocks_www_dir <- function() {
  www <- system.file("www", package = "shinyblocks")
  if (!nzchar(www) && dir.exists("inst/www")) {
    www <- "inst/www"
  }
  if (nzchar(www)) www else NULL
}

shinyblocks_dependency <- function() {
  args <- list(
    name = "shinyblocks",
    version = shinyblocks_asset_version(),
    stylesheet = c("shinyblocks.css", "shinyblocks-runtime.css"),
    script = c("shinyblocks.js", "shinyblocks-runtime.js"),
    attachment = c(sprite = "icons/sprite.svg")
  )
  if (identical(getOption("shinyblocks.asset_mode"), "app")) {
    args$src <- c(href = "shinyblocks")
  } else {
    args$src <- "www"
    args$package <- "shinyblocks"
  }
  do.call(htmltools::htmlDependency, args)
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
  www <- shinyblocks_www_dir()
  if (is.null(www)) {
    return(version)
  }

  assets <- file.path(www, .shinyblocks_assets)
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
      dir <- shinyblocks_www_dir()
      path <- if (!is.null(dir)) file.path(dir, "favicon.svg")
      if (is.null(path) || !file.exists(path)) {
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

#' Create an icon
#'
#' @param name Icon name from the vendored Lucide sprite, or a custom
#'   `htmltools` tag to pass through.
#' @param class Additional classes.
#' @param ... Additional attributes passed to the root `svg` tag.
#'
#' @return An `htmltools` tag.
#' @family icon
#' @export
block_icon <- function(name, class = NULL, ...) {
  icon_tag <- if (inherits(name, "shiny.tag")) {
    name
  } else {
    validate_icon_name(name)

    htmltools::tags$svg(
      class = merge_classes("sb-icon", class),
      `aria-hidden` = "true",
      focusable = "false",
      ...,
      htmltools::tags$use(
        href = sprintf("%s#%s", sprite_href(), icon_symbol_id(name))
      )
    )
  }

  if (inherits(name, "shiny.tag")) {
    icon_tag$attribs$class <- merge_classes(icon_tag$attribs$class, class)
    icon_tag <- do.call(
      htmltools::tagAppendAttributes,
      c(list(tag = icon_tag), list(...))
    )
  }

  attach_shinyblocks_deps(icon_tag)
}

validate_icon_name <- function(name) {
  if (!is.character(name) || length(name) != 1 || is.na(name)) {
    stop(
      "`name` must be a single icon name or an `htmltools` tag.",
      call. = FALSE
    )
  }

  if (!name %in% shinyblocks_icon_names()) {
    stop(
      sprintf(
        "Unknown icon `%s`. Add it to `inst/www/icons/MANIFEST.json` first.",
        name
      ),
      call. = FALSE
    )
  }

  invisible(name)
}

shinyblocks_icon_names <- local({
  cache <- NULL

  function() {
    if (!is.null(cache)) {
      return(cache)
    }

    sprite <- icon_sprite_path()
    lines <- readLines(sprite, warn = FALSE)
    matches <- regmatches(lines, gregexpr('id="[^"]+"', lines, perl = TRUE))
    ids <- unlist(matches, use.names = FALSE)
    cache <<- sub("^sb-icon-", "", sub('^id="([^"]+)"$', "\\1", ids))
    cache
  }
})

icon_sprite_path <- function() {
  path <- system.file("www", "icons", "sprite.svg", package = "shinyblocks")

  if (!nzchar(path)) {
    path <- file.path("inst", "www", "icons", "sprite.svg")
  }

  path
}

sprite_href <- function() {
  if (identical(getOption("shinyblocks.asset_mode"), "app")) {
    return("shinyblocks/icons/sprite.svg")
  }

  sprintf("shinyblocks-%s/icons/sprite.svg", shinyblocks_asset_version())
}

icon_symbol_id <- function(name) {
  paste0("sb-icon-", name)
}

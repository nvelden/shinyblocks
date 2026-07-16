#' Create an icon
#'
#' @param name Icon name from the vendored Lucide sprite, or a custom
#'   `htmltools` tag to pass through.
#' @param size Icon size. One of `"default"` (1rem, the shadcn default),
#'   `"sm"` (0.875rem), `"lg"` (1.5rem), or `"xl"` (2.25rem). Ignored when
#'   `name` is a custom `htmltools` tag.
#' @param class Additional classes.
#' @param color Semantic foreground color.
#' @param ... Additional attributes passed to the root `svg` tag.
#'
#' @return An `htmltools` tag.
#' @family icon
#' @export
block_icon <- function(
  name,
  size = c("default", "sm", "lg", "xl"),
  class = NULL,
  ...,
  color = c("default", "muted", "primary", "destructive", "success", "warning", "info")
) {
  size <- match_arg(size, c("default", "sm", "lg", "xl"))
  size_class <- if (identical(size, "default")) NULL else paste0("sb-icon-size-", size)
  color <- match_arg(color, semantic_color_choices())
  color_class <- if (identical(color, "default")) NULL else paste0("sb-icon-color-", color)

  icon_tag <- if (inherits(name, "shiny.tag")) {
    name
  } else {
    validate_icon_name(name)

    htmltools::tags$svg(
      class = merge_classes("sb-icon", size_class, color_class, class),
      `aria-hidden` = "true",
      focusable = "false",
      ...,
      htmltools::tags$use(
        href = sprintf("%s#%s", sprite_href(), icon_symbol_id(name))
      )
    )
  }

  if (inherits(name, "shiny.tag")) {
    icon_tag$attribs$class <- merge_classes(icon_tag$attribs$class, color_class, class)
    icon_tag <- do.call(
      htmltools::tagAppendAttributes,
      c(list(tag = icon_tag), list(...))
    )
  }

  attach_shinyblocks_deps(icon_tag, scope = FALSE)
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

    manifest <- jsonlite::fromJSON(icon_manifest_path(), simplifyVector = FALSE)
    cache <<- unique(as.character(manifest$icons %||% character()))
    cache
  }
})

icon_manifest_path <- function() {
  path <- system.file("www", "icons", "MANIFEST.json", package = "shinyblocks")

  if (!nzchar(path)) {
    path <- file.path("inst", "www", "icons", "MANIFEST.json")
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

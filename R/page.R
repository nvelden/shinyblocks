#' Create a modern Shiny page
#'
#' @param ... Page body content.
#' @param title Browser page title.
#' @param sidebar Optional [block_sidebar()] on the left: usually the
#'   navigation.
#' @param sidebar_right Optional [block_sidebar()] with `side = "right"`, on
#'   the right of the page, e.g. a settings or details panel. Like the left
#'   sidebar it stays in view at viewport height on larger screens; on small
#'   screens it follows the page content.
#' @param header Optional header content.
#' @param theme_mode Initial theme mode.
#' @param theme Optional `block_theme()` overrides.
#' @param style Optional [block_style()] visual style profile. When supplied,
#'   `data-sb-style="<profile>"` is placed on the `.sb-app` shell and any
#'   profile override `<style>` is injected, so the profile applies page-wide
#'   (including portal overlays).
#' @param favicon The browser tab icon. `NULL` (the default) uses the
#'   shinyblocks icon; a path or URL, e.g. `"favicon.png"` for a file in the
#'   app's `www/` folder, uses that image instead; `FALSE` sets no icon.
#' @param class Additional classes for the app root.
#'
#' @return An `htmltools` tag list suitable for a Shiny UI.
#' @family layout
#' @export
block_page <- function(
  ...,
  title = NULL,
  sidebar = NULL,
  sidebar_right = NULL,
  header = NULL,
  theme_mode = c("system", "light", "dark"),
  theme = NULL,
  style = NULL,
  favicon = NULL,
  class = NULL
) {
  theme_mode <- match_arg(theme_mode, c("system", "light", "dark"))
  favicon_link <- page_favicon_link(favicon)

  data_sb_style <- NULL
  style_tag <- NULL
  if (!is.null(style)) {
    if (!inherits(style, "shinyblocks_style")) {
      stop("`style` must be a `block_style()` object.", call. = FALSE)
    }
    data_sb_style <- style$profile
    style_tag <- style$style
  }

  sidebar <- prepare_sidebar(sidebar, "left")
  sidebar_right <- prepare_sidebar(sidebar_right, "right")
  sidebar_collapsed <- if (!is.null(sidebar)) {
    sidebar$attribs[["data-collapsed"]] %||% "false"
  } else {
    "false"
  }
  sidebar_trigger <- if (!is.null(sidebar)) {
    sidebar_mobile_trigger(sidebar$attribs$id)
  }

  attach_shinyblocks_deps(
    htmltools::tagList(
      htmltools::tags$head(
        # Without it, phones lay the page out at desktop width and the
        # responsive sidebar and layouts never apply
        htmltools::tags$meta(
          name = "viewport",
          content = "width=device-width, initial-scale=1"
        ),
        htmltools::tags$title(title %||% "shinyblocks"),
        favicon_link,
        block_page_chrome_style(),
        block_theme_script(theme_mode),
        theme,
        style_tag
      ),
      htmltools::tags$div(
        class = merge_classes("sb-app", class),
        `data-sb-style` = data_sb_style,
        htmltools::tags$div(
          class = merge_classes(
            "sb-page",
            if (!is.null(sidebar)) "has-sidebar",
            if (!is.null(sidebar_right)) "has-sidebar-right"
          ),
          `data-sidebar-enhanced` = "false",
          `data-sidebar-mobile-open` = "false",
          `data-sidebar-collapsed` = sidebar_collapsed,
          `data-sidebar-right-collapsed` = if (!is.null(sidebar_right)) {
            sidebar_right$attribs[["data-collapsed"]] %||% "false"
          },
          if (!is.null(sidebar)) {
            htmltools::tags$div(
              class = "sb-sidebar-backdrop",
              `aria-hidden` = "true"
            )
          },
          sidebar,
          htmltools::tags$div(
            class = "sb-page-main",
            if (!is.null(header) || !is.null(sidebar_trigger)) {
              htmltools::tags$div(
                class = "sb-header-shell",
                sidebar_trigger,
                header
              )
            },
            block_body(...)
          ),
          sidebar_right
        ),
        runtime_portal_root()
      )
    )
  )
}

#' Create a page body landmark
#'
#' @param ... Body content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family layout
#' @export
block_body <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$main(
      class = merge_classes("sb-body", class),
      ...
    )
  )
}

page_favicon_link <- function(favicon) {
  if (is.null(favicon)) {
    return(block_favicon_link())
  }
  if (isFALSE(favicon)) {
    return(NULL)
  }
  if (!is.character(favicon) || length(favicon) != 1 || is.na(favicon) || !nzchar(favicon)) {
    stop("`favicon` must be `NULL`, `FALSE`, or a single path or URL.", call. = FALSE)
  }
  path <- sub("[?#].*$", "", favicon)
  ext <- tolower(if (grepl("\\.[A-Za-z0-9]+$", path)) sub("^.*\\.", "", path) else "")
  type <- switch(ext,
    svg = "image/svg+xml",
    png = "image/png",
    ico = "image/x-icon",
    gif = "image/gif",
    jpg = ,
    jpeg = "image/jpeg",
    NULL
  )
  htmltools::tags$link(rel = "icon", type = type, href = favicon)
}

# Minimal host-document reset for the page-owning entry point.
#
# The generated ownership reset targets only `.sb-app` and `sb-*` elements, so
# host-package content slots keep their own base styles. `block_page()` is the
# explicit "shinyblocks owns the page" entry point, so it may still reset the
# document `<body>` margin that the
# UA adds (and that the global Preflight used to zero) — without this the
# `.sb-app` shell renders with an 8px gutter around it. Components used
# standalone inside a host app do not emit this, so the host keeps its own
# body styling.
block_page_chrome_style <- function() {
  htmltools::tags$style(
    class = "sb-page-chrome",
    htmltools::HTML("body{margin:0;padding:0}")
  )
}

block_theme_script <- function(theme_mode) {
  script <- sprintf(
    "window.shinyblocksInitialThemeMode = %s;",
    jsonlite::toJSON(theme_mode, auto_unbox = TRUE)
  )

  htmltools::tags$script(htmltools::HTML(script))
}

prepare_sidebar <- function(sidebar, side = c("left", "right")) {
  side <- match_arg(side, c("left", "right"))
  if (is.null(sidebar)) {
    return(NULL)
  }

  arg <- if (side == "right") "sidebar_right" else "sidebar"
  sidebar_side <- if (inherits(sidebar, "shiny.tag")) {
    sidebar$attribs[["data-side"]] %||% "left"
  }
  if (!identical(sidebar_side, side) && (side == "right" || identical(sidebar_side, "right"))) {
    stop(
      sprintf(
        "`%s` must be a `block_sidebar(side = \"%s\")`.",
        arg, side
      ),
      call. = FALSE
    )
  }

  if (is.null(sidebar$attribs$id) || !nzchar(sidebar$attribs$id)) {
    sidebar$attribs$id <- if (side == "right") "sb-sidebar-right" else "sb-sidebar"
  }

  sidebar
}

sidebar_mobile_trigger <- function(sidebar_id) {
  htmltools::tags$button(
    class = "sb-sidebar-mobile-trigger",
    type = "button",
    `aria-label` = "Open sidebar",
    `aria-controls` = sidebar_id,
    `aria-expanded` = "false",
    block_icon("menu")
  )
}

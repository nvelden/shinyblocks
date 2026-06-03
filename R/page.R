#' Create a modern Shiny page
#'
#' @param ... Page body content.
#' @param title Browser page title.
#' @param sidebar Optional sidebar content.
#' @param header Optional header content.
#' @param theme_mode Initial theme mode.
#' @param theme Optional `block_theme()` overrides.
#' @param style Optional [block_style()] visual style profile. When supplied,
#'   `data-sb-style="<profile>"` is placed on the `.sb-app` shell and any
#'   profile override `<style>` is injected, so the profile applies page-wide
#'   (including portal overlays).
#' @param class Additional classes for the app root.
#'
#' @return An `htmltools` tag list suitable for a Shiny UI.
#' @family layout
#' @export
block_page <- function(
  ...,
  title = NULL,
  sidebar = NULL,
  header = NULL,
  theme_mode = c("system", "light", "dark"),
  theme = NULL,
  style = NULL,
  class = NULL
) {
  theme_mode <- match_arg(theme_mode, c("system", "light", "dark"))

  data_sb_style <- NULL
  style_tag <- NULL
  if (!is.null(style)) {
    if (!inherits(style, "shinyblocks_style")) {
      stop("`style` must be a `block_style()` object.", call. = FALSE)
    }
    data_sb_style <- style$profile
    style_tag <- style$style
  }

  sidebar <- prepare_sidebar(sidebar)
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
        htmltools::tags$title(title %||% "shinyblocks"),
        block_favicon_link(),
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
            if (!is.null(sidebar)) "has-sidebar"
          ),
          `data-sidebar-enhanced` = "false",
          `data-sidebar-mobile-open` = "false",
          `data-sidebar-collapsed` = sidebar_collapsed,
          sidebar,
          if (!is.null(sidebar)) {
            htmltools::tags$div(
              class = "sb-sidebar-backdrop",
              `aria-hidden` = "true"
            )
          },
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
          )
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

# Minimal host-document reset for the page-owning entry point.
#
# The Tailwind Preflight reset is scoped to `.sb-app` so it never touches a
# host page (ADR 0022). `block_page()` is the explicit "shinyblocks owns the
# page" entry point, so it may reset the document `<body>` margin that the
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

prepare_sidebar <- function(sidebar) {
  if (is.null(sidebar)) {
    return(NULL)
  }

  if (is.null(sidebar$attribs$id) || !nzchar(sidebar$attribs$id)) {
    sidebar$attribs$id <- "sb-sidebar"
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

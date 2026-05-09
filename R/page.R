#' Create a modern Shiny page
#'
#' @param ... Page body content.
#' @param title Browser page title.
#' @param sidebar Optional sidebar content.
#' @param header Optional header content.
#' @param theme_mode Initial theme mode.
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
  class = NULL
) {
  theme_mode <- match_arg(theme_mode, c("system", "light", "dark"))

  attach_shinyblocks_deps(
    htmltools::tagList(
      htmltools::tags$head(
        htmltools::tags$title(title %||% "shinyblocks"),
        block_theme_script(theme_mode)
      ),
      htmltools::tags$div(
        class = merge_classes("sb-app", class),
        htmltools::tags$div(
          class = merge_classes(
            "sb-page",
            if (!is.null(sidebar)) "has-sidebar"
          ),
          sidebar,
          htmltools::tags$div(
            class = "sb-page-main",
            header,
            block_body(...)
          )
        )
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

block_theme_script <- function(theme_mode) {
  script <- if (identical(theme_mode, "system")) {
    "
(function () {
  try {
    var t = localStorage.getItem('sb-theme');
    if (!t) {
      t = matchMedia('(prefers-color-scheme: dark)').matches
        ? 'dark' : 'light';
    }
    document.documentElement.dataset.theme = t;
  } catch (e) {}
})();
"
  } else {
    sprintf(
      "
(function () {
  document.documentElement.dataset.theme = '%s';
})();
",
      theme_mode
    )
  }

  htmltools::tags$script(htmltools::HTML(script))
}

#' Create a dark mode toggle
#'
#' @param label Button label.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family theme
#' @export
block_dark_mode_toggle <- function(label = "Theme", class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$button(
      class = merge_classes(
        "sb-button",
        "sb-button-outline",
        "sb-button-size-sm",
        "sb-dark-mode-toggle",
        class
      ),
      type = "button",
      `data-sb-theme-toggle` = "true",
      `aria-pressed` = "false",
      htmltools::tags$span(
        class = "sb-dark-mode-icon-light",
        block_icon("sun")
      ),
      htmltools::tags$span(
        class = "sb-dark-mode-icon-dark",
        block_icon("moon")
      ),
      htmltools::tags$span(class = "sb-dark-mode-label", label)
    )
  )
}

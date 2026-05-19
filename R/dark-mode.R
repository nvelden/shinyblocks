#' Create a dark mode toggle
#'
#' @param label Button label.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family theme
#' @export
block_dark_mode_toggle <- function(label = "Theme", class = NULL) {
  block_button(
    label = htmltools::tagList(
      htmltools::tags$span(
        class = "sb-dark-mode-icon-light",
        block_icon("sun")
      ),
      htmltools::tags$span(
        class = "sb-dark-mode-icon-dark",
        block_icon("moon")
      ),
      htmltools::tags$span(class = "sb-dark-mode-label", label)
    ),
    variant = "outline",
    size = "sm",
    class = merge_classes("sb-dark-mode-toggle", class),
    `data-sb-theme-toggle` = "true",
    `aria-pressed` = "false"
  )
}

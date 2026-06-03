#' Create a badge
#'
#' @param label Badge label.
#' @param variant Visual variant.
#' @param size Visual size.
#' @param class Additional classes.
#' @param style Optional inline custom styles.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_badge <- function(
  label,
  variant = c(
    "default", "secondary", "outline", "destructive", "success", "warning",
    "info", "ghost", "link"
  ),
  size = c("default", "sm", "lg"),
  class = NULL,
  style = NULL
) {
  variant <- match_arg(
    variant,
    c(
      "default", "secondary", "outline", "destructive", "success", "warning",
      "info", "ghost", "link"
    )
  )
  size <- match_arg(size, c("default", "sm", "lg"))

  runtime_component(
    component = "badge",
    props = list(
      labelHtml = html_fragment(label),
      variant = variant,
      size = size
    ),
    class = class,
    style = style
  )
}

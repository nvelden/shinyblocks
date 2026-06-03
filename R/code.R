#' Create a code block
#'
#' A pre-formatted code block following the shadcn documentation code
#' surface: bordered frame, monospace text, optional line numbers, and an
#' optional copy-to-clipboard button.
#'
#' @param code The code string to display.
#' @param language Optional programming language name to display when
#'   `header = TRUE`.
#' @param copyable Logical. If `TRUE` (default), displays a
#'   copy-to-clipboard button.
#' @param line_numbers Logical. If `TRUE` (default), displays line numbers.
#' @param header Logical. If `TRUE`, displays an optional header with editor
#'   dots and the language label. Defaults to `FALSE` to match the shadcn
#'   documentation examples.
#' @param variant Visual variant. One of `"default"` (background surface) or
#'   `"outline"` (transparent surface).
#' @param class Additional CSS classes.
#' @param style Optional inline custom styles.
#' @param ... Additional attributes or child elements (passed down).
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_code <- function(
  code,
  language = NULL,
  copyable = TRUE,
  line_numbers = TRUE,
  header = FALSE,
  variant = c("default", "outline"),
  class = NULL,
  style = NULL,
  ...
) {
  if (missing(code) || !is.character(code) || length(code) != 1) {
    stop("`code` must be a single non-empty character string.", call. = FALSE)
  }
  if (!nzchar(code)) {
    stop("`code` must be a single non-empty character string.", call. = FALSE)
  }
  if (
    !is.null(language) &&
      (!is.character(language) || length(language) != 1)
  ) {
    stop("`language` must be NULL or a single character string.", call. = FALSE)
  }

  variant <- match_arg(variant, c("default", "outline"))

  runtime_component(
    component = "code",
    props = list(
      code = code,
      language = if (is.null(language)) NULL else as.character(language),
      copyable = isTRUE(copyable),
      line_numbers = isTRUE(line_numbers),
      header = isTRUE(header),
      variant = variant
    ),
    class = class,
    style = style
  )
}

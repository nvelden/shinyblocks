#' Create a dashboard card
#'
#' @param ... Card body content.
#' @param title Optional card title.
#' @param value Optional primary value.
#'
#' @return An `htmltools` tag.
#' @export
block_card <- function(..., title = NULL, value = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$article(
      class = "sb-card",
      if (!is.null(title)) htmltools::tags$h3(class = "sb-card-title", title),
      if (!is.null(value)) htmltools::tags$div(class = "sb-card-value", value),
      htmltools::tags$div(class = "sb-card-body", ...)
    )
  )
}

#' Create a modern button
#'
#' @param label Button label.
#' @param variant Visual variant.
#' @param ... Additional attributes passed to `htmltools::tags$button`.
#'
#' @return An `htmltools` tag.
#' @export
block_button <- function(
  label,
  variant = c("default", "secondary", "outline", "ghost"),
  ...
) {
  variant <- match.arg(variant)
  attach_shinyblocks_deps(
    htmltools::tags$button(
      class = paste("sb-button", paste0("sb-button-", variant)),
      type = "button",
      ...,
      label
    )
  )
}

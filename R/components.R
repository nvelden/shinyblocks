#' Create a dashboard card
#'
#' @param ... Card body content.
#' @param title Optional card title.
#' @param value Optional primary value.
#'
#' @return An `htmltools` tag.
#' @export
block_card <- function(..., title = NULL, value = NULL) {
  shiny::tags$article(
    class = "sb-card",
    if (!is.null(title)) shiny::tags$h3(class = "sb-card-title", title),
    if (!is.null(value)) shiny::tags$div(class = "sb-card-value", value),
    shiny::tags$div(class = "sb-card-body", ...)
  )
}

#' Create a modern button
#'
#' @param label Button label.
#' @param variant Visual variant.
#' @param ... Additional attributes passed to `shiny::tags$button`.
#'
#' @return An `htmltools` tag.
#' @export
block_button <- function(label, variant = c("default", "secondary", "outline", "ghost"), ...) {
  variant <- match.arg(variant)
  shiny::tags$button(
    class = paste("sb-button", paste0("sb-button-", variant)),
    type = "button",
    ...,
    label
  )
}

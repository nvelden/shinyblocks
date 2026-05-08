#' Create a dashboard card
#'
#' @param ... Card body content.
#' @param title Optional card title.
#' @param value Optional primary value.
#'
#' @return An `htmltools` tag.
#' @export
shadcn_card <- function(..., title = NULL, value = NULL) {
  shiny::tags$article(
    class = "shadcn-card",
    if (!is.null(title)) shiny::tags$h3(class = "shadcn-card-title", title),
    if (!is.null(value)) shiny::tags$div(class = "shadcn-card-value", value),
    shiny::tags$div(class = "shadcn-card-body", ...)
  )
}

#' Create a shadcn-inspired button
#'
#' @param label Button label.
#' @param variant Visual variant.
#' @param ... Additional attributes passed to `shiny::tags$button`.
#'
#' @return An `htmltools` tag.
#' @export
shadcn_button <- function(label, variant = c("default", "secondary", "outline", "ghost"), ...) {
  variant <- match.arg(variant)
  shiny::tags$button(
    class = paste("shadcn-button", paste0("shadcn-button-", variant)),
    type = "button",
    ...,
    label
  )
}

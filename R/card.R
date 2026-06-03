#' Create a dashboard card
#'
#' @param ... Card body content or composed card region tags.
#' @param title Optional card title.
#' @param description Optional card description.
#' @param value Optional primary value.
#' @param footer Optional card footer content.
#' @param class Additional classes.
#' @param style Optional inline custom styles.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card <- function(
  ...,
  title = NULL,
  description = NULL,
  value = NULL,
  footer = NULL,
  class = NULL,
  style = NULL
) {
  title_tag <- as_component_child(title, "card-title", block_card_title)
  description_tag <- as_component_child(
    description,
    "card-description",
    block_card_description
  )
  footer_tag <- as_component_child(footer, "card-footer", block_card_footer)

  header_tag <- if (!is.null(title_tag) || !is.null(description_tag)) {
    block_card_header(title_tag, description_tag)
  }

  content_tag <- block_card_content(
    if (!is.null(value)) {
      htmltools::tags$div(class = "sb-card-value", value)
    },
    ...
  )

  runtime_component(
    component = "card",
    children = list(header_tag, content_tag, footer_tag),
    class = class,
    style = style,
    root_class = merge_classes("sb-card", class)
  )
}

#' Create a card header
#'
#' @param ... Card header content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card_header <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-card-header", class),
      `data-sb-child` = "card-header",
      ...
    )
  )
}

#' Create a card title
#'
#' @param ... Card title content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card_title <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$h3(
      class = merge_classes("sb-card-title", class),
      `data-sb-child` = "card-title",
      ...
    )
  )
}

#' Create a card description
#'
#' @param ... Card description content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card_description <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$p(
      class = merge_classes("sb-card-description", class),
      `data-sb-child` = "card-description",
      ...
    )
  )
}

#' Create card content
#'
#' @param ... Card content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card_content <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-card-content", class),
      `data-sb-child` = "card-content",
      ...
    )
  )
}

#' Create a card footer
#'
#' @param ... Card footer content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_card_footer <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-card-footer", class),
      `data-sb-child` = "card-footer",
      ...
    )
  )
}

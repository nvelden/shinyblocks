#' Create a field group
#'
#' @param ... Field content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_field_group <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-field-group", class),
      `data-sb-child` = "field-group",
      ...
    )
  )
}

#' Create a field wrapper
#'
#' @param ... Field content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_field <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-field", class),
      `data-sb-child` = "field",
      ...
    )
  )
}

#' Create a field label
#'
#' @param ... Label content.
#' @param for Optional input id referenced by the label.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_field_label <- function(..., `for` = NULL, class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$label(
      class = merge_classes("sb-field-label", class),
      `data-sb-child` = "field-label",
      `for` = `for`,
      ...
    )
  )
}

#' Create field helper text
#'
#' @param ... Description content.
#' @param id Optional element id.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_field_description <- function(..., id = NULL, class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$p(
      class = merge_classes("sb-field-description", class),
      `data-sb-child` = "field-description",
      id = id,
      ...
    )
  )
}

#' Create a field set
#'
#' @param ... Field set content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_field_set <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$fieldset(
      class = merge_classes("sb-field-set", class),
      `data-sb-child` = "field-set",
      ...
    )
  )
}

#' Create a field set legend
#'
#' @param ... Legend content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family forms
#' @export
block_field_legend <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$legend(
      class = merge_classes("sb-field-legend", class),
      `data-sb-child` = "field-legend",
      ...
    )
  )
}

#' Mark a field invalid
#'
#' @param field A `block_field()` tag.
#' @param message Validation message shown below the control.
#'
#' @return A modified `htmltools` tag.
#' @family forms
#' @export
block_field_invalid <- function(field, message) {
  if (
    !inherits(field, "shiny.tag") ||
      !identical(field$attribs[["data-sb-child"]], "field")
  ) {
    stop("`field` must be created by `block_field()`.", call. = FALSE)
  }

  message_id <- sprintf("sb-field-error-%s", as.integer(stats::runif(1) * 1e9))
  tag_query <- htmltools::tagQuery(field)

  tag_query$
    addAttrs(`data-invalid` = "true")$
    addClass("sb-field-invalid")

  for (selector in c("input", "select", "textarea", ".sb-runtime-mount")) {
    selected <- tag_query$find(selector)
    selected$each(function(tag, index) {
      tag$attribs[["aria-invalid"]] <- "true"
      tag$attribs[["aria-describedby"]] <- append_idref(
        tag$attribs[["aria-describedby"]],
        message_id
      )
    })
    selected$resetSelected()
  }

  tag_query$append(
    block_field_description(
      message,
      id = message_id,
      class = "sb-field-error"
    )
  )

  tag_query$allTags()
}

#' Create an accordion item
#'
#' A single collapsible section for [block_accordion()]: a trigger button
#' (the `title`) that expands or collapses its body content. Body content is
#' arbitrary Shiny/`htmltools` markup and stays live in the DOM, so reactive
#' outputs inside a closed panel keep working.
#'
#' @param value String identifying the item. Required and must be unique
#'   within an accordion. This is the value reported to `input$<id>` and the
#'   value [update_block_accordion()] opens or closes.
#' @param title Trigger label. A single string, or an `htmltools` tag for
#'   richer content.
#' @param ... Panel body content (`htmltools` tags, Shiny outputs, ...).
#' @param icon Optional leading icon shown before the title: a vendored icon
#'   name (see [block_icon()]) or an `htmltools` tag.
#' @param disabled Whether the item is non-interactive (cannot be toggled).
#' @param class Additional classes for the item wrapper.
#'
#' @return An accordion-item tag consumed by [block_accordion()].
#' @family content
#' @export
block_accordion_item <- function(
  value,
  title,
  ...,
  icon = NULL,
  disabled = FALSE,
  class = NULL
) {
  check_string(value, "value", msg = "`value` must be a single string.")
  if (missing(title) || is.null(title)) {
    stop("`title` must be a single string or an `htmltools` tag.", call. = FALSE)
  }
  if (!is.character(title) && !inherits(title, "shiny.tag")) {
    stop("`title` must be a single string or an `htmltools` tag.", call. = FALSE)
  }
  if (is.character(title)) {
    check_string(title, "title", msg = "`title` must be a single string label.")
  }
  check_flag(disabled, "disabled")

  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-accordion-item", class),
      `data-sb-child` = "accordion-item",
      `data-value` = value,
      `data-state` = "closed",
      `data-disabled` = if (isTRUE(disabled)) "true" else NULL,
      htmltools::tags$h3(
        class = "sb-accordion-header",
        htmltools::tags$button(
          type = "button",
          class = "sb-accordion-trigger",
          `aria-expanded` = "false",
          disabled = if (isTRUE(disabled)) "disabled" else NULL,
          `data-state` = "closed",
          htmltools::tags$span(
            class = "sb-accordion-title",
            set_icon_position(icon, "inline-start"),
            title
          ),
          set_icon_position("chevron-down", "inline-end")
        )
      ),
      htmltools::tags$div(
        class = "sb-accordion-content",
        role = "region",
        `data-state` = "closed",
        inert = "",
        # The middle wrapper is the grid item: `overflow: hidden` + `min-height:
        # 0` let `grid-template-rows: 0fr` collapse it fully. Padding lives on the
        # inner body so it is clipped away when closed (padding on the grid item
        # itself would floor the row at its own height and leak content).
        htmltools::tags$div(
          class = "sb-accordion-content-inner",
          htmltools::tags$div(class = "sb-accordion-content-body", ...)
        )
      )
    )
  )
}

#' Create an accordion
#'
#' A vertically stacked set of collapsible sections built from
#' [block_accordion_item()]. Use it to organize long content into
#' expand/collapse panels (FAQs, grouped settings, filters).
#'
#' The trigger buttons carry `aria-expanded`/`aria-controls`, the chevron
#' rotates on open, and panel height animates. When `id` is supplied the open
#' item value(s) are reported to `input$<id>`: a string (or `NULL`) for
#' `type = "single"`, a character vector for `type = "multiple"`.
#'
#' `...` supports rlang's `!!!` splice operator, so a programmatically built
#' list of items (e.g. one per row of a data frame) can be passed without
#' `do.call()`:
#'
#' ```r
#' items <- lapply(seq_len(nrow(faqs)), function(i) {
#'   block_accordion_item(faqs$value[i], faqs$question[i], faqs$answer[i])
#' })
#' block_accordion(!!!items, id = "faq")
#' ```
#'
#' @param ... [block_accordion_item()] items. Supports `!!!` to splice a list
#'   of items.
#' @param id Optional input id. When supplied, `input$<id>` reports the open
#'   item value(s).
#' @param type `"single"` (at most one item open at a time) or `"multiple"`
#'   (any number open independently). Create-only.
#' @param collapsible For `type = "single"` only: whether the open item can be
#'   collapsed, leaving nothing open. Ignored for `type = "multiple"` (always
#'   collapsible). Create-only.
#' @param open Item value(s) to open initially. For `type = "single"` a single
#'   value or `NULL`; for `type = "multiple"` a character vector. Must match
#'   item values.
#' @param style Inline CSS styles applied to the accordion wrapper.
#' @param class Additional classes for the accordion wrapper.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_accordion <- function(
  ...,
  id = NULL,
  type = c("single", "multiple"),
  collapsible = FALSE,
  open = NULL,
  style = NULL,
  class = NULL
) {
  type <- match_arg(type, c("single", "multiple"))
  check_flag(collapsible, "collapsible")
  if (!is.null(id)) {
    validate_input_id(id)
  }

  # `list2()` (not `list()`) so callers can splice a generated list of items
  # with `block_accordion(!!!items)`.
  items <- rlang::list2(...)
  validate_children(items, "accordion-item", "block_accordion")
  if (!length(items)) {
    stop("`block_accordion()` requires at least one item.", call. = FALSE)
  }

  item_values <- vapply(
    items,
    function(item) item$attribs[["data-value"]],
    character(1)
  )
  if (anyDuplicated(item_values)) {
    stop("`block_accordion()` item values must be unique.", call. = FALSE)
  }

  open_values <- normalize_accordion_open(open, item_values, type)

  # `type = "multiple"` is always collapsible; only single mode honours the flag.
  collapsible_effective <- identical(type, "multiple") || isTRUE(collapsible)

  accordion_id <- id %||% paste0("sb-accordion-", tab_id_suffix(item_values))
  items <- Map(
    function(item, index) {
      apply_accordion_item_state(
        item,
        panel_id = paste0(accordion_id, "-panel-", index),
        trigger_id = paste0(accordion_id, "-trigger-", index),
        open = item$attribs[["data-value"]] %in% open_values
      )
    },
    items,
    seq_along(items)
  )

  attach_shinyblocks_deps(
    htmltools::tags$div(
      id = accordion_id,
      class = merge_classes("sb-accordion", class),
      style = style,
      `data-sb-accordion` = "true",
      `data-sb-accordion-input-id` = id,
      `data-type` = type,
      `data-collapsible` = tolower(as.character(collapsible_effective)),
      items
    )
  )
}

#' Update an accordion from the server
#'
#' Opens or closes items of a [block_accordion()] that was given an `id`,
#' mirroring the click behaviour from the server.
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to [block_accordion()].
#' @param open Item value(s) that should be open after the update. For
#'   `type = "single"` a single value or `NULL`/`character(0)` (closes all);
#'   for `type = "multiple"` a character vector.
#' @param notify Whether Shiny should receive an input event after the update.
#'
#' @return Invisibly returns `NULL`.
#' @family content
#' @export
update_block_accordion <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  open,
  notify = TRUE
) {
  if (is.null(session)) {
    stop("`session` is required.", call. = FALSE)
  }
  if (!is.function(session$sendInputMessage)) {
    stop("`session` must provide a `sendInputMessage()` method.", call. = FALSE)
  }
  validate_input_id(input_id)

  open <- if (missing(open) || is.null(open)) {
    character()
  } else {
    as.character(open)
  }

  target <- if (is.function(session$ns)) session$ns(input_id) else input_id
  runtime_root_session(session)$sendInputMessage(
    target,
    list(open = as.list(open), notify = isTRUE(notify))
  )
  invisible(NULL)
}

# Validate the initial `open` value(s) against known item values and mode.
normalize_accordion_open <- function(open, item_values, type) {
  if (is.null(open)) {
    return(character())
  }
  open <- as.character(open)
  if (identical(type, "single") && length(open) > 1) {
    stop(
      "`open` must be a single value when `type = \"single\"`.",
      call. = FALSE
    )
  }
  if (anyDuplicated(open)) {
    stop("`open` must not contain duplicate values.", call. = FALSE)
  }
  if (any(!open %in% item_values)) {
    stop("`open` must match one of the accordion item values.", call. = FALSE)
  }
  open
}

# Stamp the resolved open/closed state and a11y ids onto a rendered item tag.
apply_accordion_item_state <- function(item, panel_id, trigger_id, open) {
  state <- if (isTRUE(open)) "open" else "closed"
  header <- item$children[[1]]
  trigger <- header$children[[1]]
  content <- item$children[[2]]

  item$attribs[["data-state"]] <- state

  trigger$attribs[["id"]] <- trigger_id
  trigger$attribs[["aria-controls"]] <- panel_id
  trigger$attribs[["aria-expanded"]] <- if (isTRUE(open)) "true" else "false"
  trigger$attribs[["data-state"]] <- state
  header$children[[1]] <- trigger
  item$children[[1]] <- header

  content$attribs[["id"]] <- panel_id
  content$attribs[["aria-labelledby"]] <- trigger_id
  content$attribs[["data-state"]] <- state
  content$attribs[["inert"]] <- if (isTRUE(open)) NULL else ""
  item$children[[2]] <- content

  item
}

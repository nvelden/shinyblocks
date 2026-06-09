#' Create a dialog (Phase 4.4 — Shiny-bound modal with size + footer)
#'
#' A modal dialog rendered into the runtime portal root. Reports its
#' open/closed state to `input$<id>` and accepts server-driven
#' updates through `update_block_dialog()`. A11y behaviors (escape,
#' outside-click, focus trap, focus return, scroll lock) land in 4.3.
#'
#' @param id Required input id. `input$<id>` is `TRUE` when open,
#'   `FALSE` when closed.
#' @param title Required dialog title. Used as the accessible name.
#' @param ... Body content. Serialized to HTML in 4.1/4.2; arbitrary
#'   Shiny children become Shiny-bound in a later sub-phase.
#' @param description Optional description below the title.
#' @param footer Optional footer content (typically action buttons).
#'   Renders below the body in a right-aligned flex row.
#' @param trigger Optional label string. Renders a default-variant
#'   `block_button()` next to the mount node that opens the dialog
#'   when clicked. Pass `NULL` (default) to drive open state purely
#'   from the server with `update_block_dialog()`.
#' @param open Initial open state. Defaults to `FALSE`.
#' @param size Content max-width preset. One of `"sm"`, `"default"`,
#'   `"lg"`, `"xl"`. Defaults to `"default"` (32rem).
#' @param hide_title Whether to visually hide the title while keeping
#'   it available to assistive technology as the dialog's accessible
#'   name. Defaults to `FALSE`.
#' @param class Additional classes for the dialog content container.
#' @param style Optional inline CSS styles for the dialog content container.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_dialog <- function(
  id,
  title,
  ...,
  description = NULL,
  footer = NULL,
  trigger = NULL,
  open = FALSE,
  size = c("default", "sm", "lg", "xl"),
  hide_title = FALSE,
  class = NULL,
  style = NULL
) {
  if (missing(id) || is.null(id)) {
    stop("`id` is required.", call. = FALSE)
  }
  if (missing(title) || is.null(title)) {
    stop("`title` is required.", call. = FALSE)
  }
  if (!is.null(trigger) && (!is.character(trigger) || length(trigger) != 1)) {
    stop("`trigger` must be a single string label or NULL.", call. = FALSE)
  }
  size <- match.arg(size)

  runtime_component(
    component = "dialog",
    input_id = id,
    props = list(
      titleHtml = html_fragment(title),
      descriptionHtml = if (!is.null(description)) {
        html_fragment(description)
      } else {
        NULL
      },
      bodyHtml = html_fragment(...),
      footerHtml = if (!is.null(footer)) html_fragment(footer) else NULL,
      triggerLabel = trigger,
      size = size,
      hideTitle = isTRUE(hide_title)
    ),
    state = list(value = isTRUE(open), open = isTRUE(open)),
    binding = list(input = TRUE),
    class = class,
    style = style
  )
}

#' Update a runtime dialog
#'
#' Send a server-driven update to a `block_dialog()`.
#'
#' @param session Shiny session. Defaults to the current reactive
#'   session.
#' @param input_id Dialog input id (unnamespaced; updaters namespace
#'   via `session$ns()`).
#' @param open Optional boolean. `TRUE` opens, `FALSE` closes.
#' @param title Optional replacement title.
#' @param description Optional replacement description.
#' @param footer Optional replacement footer content. Pass `NULL` to
#'   remove an existing footer.
#' @param size Optional content size: `"sm"`, `"default"`, `"lg"`, `"xl"`.
#' @param class Optional replacement classes for the dialog content container,
#'   or `NULL` to clear.
#' @param style Optional replacement inline CSS styles for the dialog content
#'   container, or `NULL` to clear.
#' @param notify Whether Shiny receives an input event when `open`
#'   changes. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family content
#' @export
update_block_dialog <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  open,
  title,
  description,
  footer,
  size,
  class,
  style,
  notify = TRUE
) {
  html_or_null <- function(value) if (is.null(value)) NULL else html_fragment(value)

  payload <- apply_update_fields(list(), list(
    field("open", transform = isTRUE),
    field("titleHtml", "title", html_or_null),
    field("descriptionHtml", "description", html_or_null),
    field_clearable("footerHtml", "footer", html_fragment),
    field_clearable("className", "class"),
    field_style("style")
  ))

  if (!missing(size)) {
    allowed <- c("default", "sm", "lg", "xl")
    if (!is.character(size) || length(size) != 1 || !(size %in% allowed)) {
      stop(
        sprintf(
          "`size` must be one of %s.",
          paste(shQuote(allowed), collapse = ", ")
        ),
        call. = FALSE
      )
    }
    payload$size <- size
  }

  runtime_input_update(
    session, input_id, "dialog", payload,
    notify_key = "open", notify = notify
  )
}

#' Create a runtime popover
#'
#' A non-modal, portal-rendered popover anchored to a trigger button.
#' Popovers with an `id` report their open/closed state to `input$<id>`
#' and accept server-driven updates through `update_block_popover()`.
#' Popovers without an `id` stay client-only.
#'
#' @param trigger Required label string. Renders a default-variant
#'   `block_button()` that toggles the popover when clicked.
#' @param ... Popover body content. Serialized to HTML.
#' @param id Optional input id. When supplied, `input$<id>` is `TRUE`
#'   when open and `FALSE` when closed.
#' @param side Side of the trigger to anchor on. One of `"bottom"`,
#'   `"top"`, `"left"`, `"right"`. Defaults to `"bottom"`.
#' @param align Alignment along the anchored side. One of `"center"`,
#'   `"start"`, `"end"`. Defaults to `"center"`.
#' @param open Initial open state. Defaults to `FALSE`.
#' @param style Optional inline CSS applied to the popover content
#'   container (string or named list).
#' @param class Additional classes for the popover content container.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_popover <- function(
  trigger,
  ...,
  id = NULL,
  side = c("bottom", "top", "left", "right"),
  align = c("center", "start", "end"),
  open = FALSE,
  style = NULL,
  class = NULL
) {
  if (missing(trigger) || is.null(trigger) || !is.character(trigger) || length(trigger) != 1) {
    stop("`trigger` must be a single string label.", call. = FALSE)
  }
  if (!is.null(id)) {
    validate_input_id(id)
  }
  side <- match.arg(side)
  align <- match.arg(align)

  content_style <- if (!is.null(style)) normalize_runtime_style(style) else NULL

  runtime_component(
    component = "popover",
    input_id = id,
    props = list(
      triggerLabel = trigger,
      bodyHtml = html_fragment(...),
      side = side,
      align = align,
      contentStyle = content_style,
      contentClass = class
    ),
    state = list(value = isTRUE(open), open = isTRUE(open)),
    binding = if (is.null(id)) {
      list(input = FALSE)
    } else {
      list(input = TRUE, type = "shinyblocks.popover")
    }
  )
}

#' Update a runtime popover
#'
#' Send a server-driven update to a `block_popover()`.
#'
#' @param session Shiny session. Defaults to the current reactive
#'   session.
#' @param input_id Popover input id (unnamespaced; updaters namespace
#'   via `session$ns()`).
#' @param open Optional boolean. `TRUE` opens, `FALSE` closes.
#' @param trigger Optional replacement trigger label.
#' @param body Optional replacement body content. Pass `NULL` to clear.
#' @param side Optional side: `"bottom"`, `"top"`, `"left"`, `"right"`.
#' @param align Optional alignment: `"center"`, `"start"`, `"end"`.
#' @param style Optional replacement content style (CSS string or named
#'   list). Pass `NULL` to clear.
#' @param class Optional replacement content classes. Pass `NULL` to
#'   clear.
#' @param notify Whether Shiny receives an input event when `open`
#'   changes. Cosmetic-only updates never notify.
#'
#' @return Invisibly returns `NULL`.
#' @family content
#' @export
update_block_popover <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  open,
  trigger,
  body,
  side,
  align,
  style,
  class,
  notify = TRUE
) {
  payload <- apply_update_fields(list(), list(
    field("open", transform = isTRUE),
    field_clearable("bodyHtml", "body", html_fragment),
    field_style("contentStyle", "style"),
    field_clearable("contentClass", "class")
  ))

  if (!missing(trigger)) {
    if (is.null(trigger) || !is.character(trigger) || length(trigger) != 1) {
      stop("`trigger` must be a single string label.", call. = FALSE)
    }
    payload$triggerLabel <- trigger
  }
  if (!missing(side)) {
    payload$side <- match.arg(side, c("bottom", "top", "left", "right"))
  }
  if (!missing(align)) {
    payload$align <- match.arg(align, c("center", "start", "end"))
  }

  runtime_input_update(
    session, input_id, "popover", payload,
    notify_key = "open", notify = notify
  )
}

#' Create a tooltip
#'
#' Wraps a trigger label with a small floating panel that opens on
#' hover or keyboard focus and closes on leave, blur, or `Escape`. The
#' content panel renders through `[data-shinyblocks-portal-root]` to
#' avoid clipping by ancestor `overflow` or `transform`. Tooltips have
#' no Shiny input binding; treat them as purely presentational.
#'
#' @param trigger Single string label rendered on the trigger button.
#' @param ... Tooltip content. HTML tags or text are accepted and
#'   serialized into the runtime payload.
#' @param side Side relative to the trigger. One of `"bottom"`,
#'   `"top"`, `"left"`, `"right"`. Defaults to `"top"`.
#' @param align Alignment along the anchored side. One of `"center"`,
#'   `"start"`, `"end"`. Defaults to `"center"`.
#' @param delay_duration Milliseconds to wait after hover/focus before
#'   opening. Defaults to `700`.
#' @param style Optional inline CSS applied to the tooltip content
#'   container (string or named list).
#' @param class Additional classes for the tooltip content container.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_tooltip <- function(
  trigger,
  ...,
  side = c("top", "bottom", "left", "right"),
  align = c("center", "start", "end"),
  delay_duration = 700,
  style = NULL,
  class = NULL
) {
  if (missing(trigger) || is.null(trigger) || !is.character(trigger) || length(trigger) != 1) {
    stop("`trigger` must be a single string label.", call. = FALSE)
  }
  side <- match.arg(side)
  align <- match.arg(align)
  if (!is.numeric(delay_duration) || length(delay_duration) != 1 || delay_duration < 0) {
    stop("`delay_duration` must be a non-negative numeric scalar.", call. = FALSE)
  }

  content_style <- if (!is.null(style)) normalize_runtime_style(style) else NULL

  runtime_component(
    component = "tooltip",
    props = list(
      triggerLabel = trigger,
      bodyHtml = html_fragment(...),
      side = side,
      align = align,
      delayDuration = as.integer(delay_duration),
      contentStyle = content_style,
      contentClass = class
    ),
    binding = list(input = FALSE)
  )
}

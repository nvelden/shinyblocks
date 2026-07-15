#' Create a dialog
#'
#' A modal dialog rendered into the runtime portal root. Reports its
#' open/closed state to `input$<id>` and accepts server-driven
#' updates through `update_block_dialog()`. The runtime implements the
#' modal accessibility contract: `Escape` and overlay (outside) click
#' dismiss, focus moves into the dialog on open and returns to the
#' previously focused element on close, `Tab`/`Shift+Tab` cycle within
#' the dialog, and body scroll is locked while open.
#'
#' @param id Required input id. `input$<id>` is `TRUE` when open,
#'   `FALSE` when closed.
#' @param title Required dialog title. Used as the accessible name.
#' @param ... Body content, serialized to HTML. Children are not
#'   Shiny-bound.
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
  check_string(
    trigger, "trigger", null_ok = TRUE,
    msg = "`trigger` must be a single string label or NULL."
  )
  size <- match_arg(size, c("default", "sm", "lg", "xl"))

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
    field_clearable("class"),
    field_style("style")
  ))

  if (!missing(size)) {
    payload$size <- match_arg(size, c("default", "sm", "lg", "xl"))
  }

  runtime_input_update(
    session, input_id, "dialog", payload,
    notify_key = "open", notify = notify
  )
}

#' Create an alert dialog
#'
#' A modal confirmation dialog that requires an explicit confirm or cancel
#' choice. `input$<id>` is initially `NULL` and reports `"confirm"` or
#' `"cancel"` for each outcome. Escape cancels; clicking the backdrop does
#' nothing.
#'
#' @param id Required input id.
#' @param title Required accessible title.
#' @param description Optional supporting description.
#' @param ... Optional body content, serialized to HTML.
#' @param confirm_label Label for the confirmation action.
#' @param cancel_label Label for the cancellation action.
#' @param trigger Optional button label that opens the alert dialog.
#' @param open Initial open state.
#' @param confirm_variant Confirmation button variant: `"default"` or
#'   `"destructive"`.
#' @param size Content max-width preset. One of `"sm"`, `"default"`, `"lg"`,
#'   or `"xl"`.
#' @param class Additional classes for the dialog content container.
#' @param style Optional inline CSS for the dialog content container.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_alert_dialog <- function(
  id,
  title,
  description = NULL,
  ...,
  confirm_label = "Continue",
  cancel_label = "Cancel",
  trigger = NULL,
  open = FALSE,
  confirm_variant = c("default", "destructive"),
  size = c("default", "sm", "lg", "xl"),
  class = NULL,
  style = NULL
) {
  if (missing(id) || is.null(id)) stop("`id` is required.", call. = FALSE)
  if (missing(title) || is.null(title)) stop("`title` is required.", call. = FALSE)
  check_string(confirm_label, "confirm_label")
  check_string(cancel_label, "cancel_label")
  check_string(trigger, "trigger", null_ok = TRUE)
  confirm_variant <- match_arg(confirm_variant, c("default", "destructive"))
  size <- match_arg(size, c("default", "sm", "lg", "xl"))

  runtime_component(
    component = "alert-dialog",
    input_id = id,
    props = list(
      titleHtml = html_fragment(title),
      descriptionHtml = if (is.null(description)) NULL else html_fragment(description),
      bodyHtml = html_fragment(...),
      confirmLabel = confirm_label,
      cancelLabel = cancel_label,
      triggerLabel = trigger,
      confirmVariant = confirm_variant,
      size = size
    ),
    state = list(value = NULL, open = isTRUE(open)),
    binding = list(input = TRUE),
    class = class,
    style = style
  )
}

#' Update an alert dialog
#'
#' @param session Shiny session.
#' @param input_id Alert dialog input id.
#' @param open Optional boolean open state.
#' @param title Optional replacement title.
#' @param description Optional replacement description.
#' @param confirm_label Optional replacement confirmation label.
#' @param cancel_label Optional replacement cancellation label.
#' @param confirm_variant Optional `"default"` or `"destructive"` variant.
#' @param size Optional content size preset.
#' @param class Optional replacement classes, or `NULL` to clear.
#' @param style Optional replacement inline style, or `NULL` to clear.
#'
#' @return Invisibly returns `NULL`.
#' @family content
#' @export
update_block_alert_dialog <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  open,
  title,
  description,
  confirm_label,
  cancel_label,
  confirm_variant,
  size,
  class,
  style
) {
  html_or_null <- function(value) if (is.null(value)) NULL else html_fragment(value)
  payload <- apply_update_fields(list(), list(
    field("open", transform = isTRUE),
    field("titleHtml", "title", html_or_null),
    field("descriptionHtml", "description", html_or_null),
    field("confirmLabel", "confirm_label"),
    field("cancelLabel", "cancel_label"),
    field_clearable("class"),
    field_style("style")
  ))
  if (!missing(confirm_variant)) {
    payload$confirmVariant <- match_arg(confirm_variant, c("default", "destructive"))
  }
  if (!missing(size)) payload$size <- match_arg(size, c("default", "sm", "lg", "xl"))
  runtime_input_update(
    session, input_id, "alert-dialog", payload,
    notify_key = NULL, notify = FALSE
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
  if (missing(trigger)) trigger <- NULL
  check_string(trigger, "trigger", msg = "`trigger` must be a single string label.")
  if (!is.null(id)) {
    validate_input_id(id)
  }
  side <- match_arg(side, c("bottom", "top", "left", "right"))
  align <- match_arg(align, c("center", "start", "end"))

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
    check_string(trigger, "trigger", msg = "`trigger` must be a single string label.")
    payload$triggerLabel <- trigger
  }
  if (!missing(side)) {
    payload$side <- match_arg(side, c("bottom", "top", "left", "right"))
  }
  if (!missing(align)) {
    payload$align <- match_arg(align, c("center", "start", "end"))
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
  if (missing(trigger)) trigger <- NULL
  check_string(trigger, "trigger", msg = "`trigger` must be a single string label.")
  side <- match_arg(side, c("top", "bottom", "left", "right"))
  align <- match_arg(align, c("center", "start", "end"))
  check_number(
    delay_duration, "delay_duration", min = 0,
    msg = "`delay_duration` must be a non-negative numeric scalar."
  )

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

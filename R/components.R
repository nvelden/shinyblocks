#' Create a dashboard card
#'
#' @param ... Card body content or composed card region tags.
#' @param title Optional card title.
#' @param description Optional card description.
#' @param value Optional primary value.
#' @param footer Optional card footer content.
#' @param class Additional classes.
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
  class = NULL
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
    class = merge_classes("sb-card", class)
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

#' Create a modern button
#'
#' @param label Button label.
#' @param variant Visual variant.
#' @param size Button size.
#' @param icon Optional icon tag or vendored icon name.
#' @param icon_position Whether the icon appears before or after the label.
#' @param ... Additional attributes passed to `htmltools::tags$button`. Pass
#'   `id = "..."` here to make the button addressable via
#'   [update_block_button()].
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family action
#' @export
block_button <- function(
  label,
  variant = c(
    "default",
    "secondary",
    "outline",
    "ghost",
    "destructive",
    "link"
  ),
  size = c("default", "sm", "lg", "icon"),
  icon = NULL,
  icon_position = c("inline-start", "inline-end"),
  ...,
  class = NULL
) {
  variant <- match_arg(
    variant,
    c("default", "secondary", "outline", "ghost", "destructive", "link")
  )
  size <- match_arg(size, c("default", "sm", "lg", "icon"))
  icon_position <- match_arg(
    icon_position,
    c("inline-start", "inline-end"),
    "icon_position"
  )
  attrs <- named_attrs(list(...))
  disabled <- isTRUE(attrs$disabled) || identical(attrs$disabled, NA)
  attrs$disabled <- NULL
  input_id <- if (is.null(attrs$id)) NULL else as.character(attrs$id)
  attrs$id <- NULL
  if (!is.null(attrs$style)) {
    attrs$style <- normalize_runtime_style(attrs$style)
  }

  icon_name <- NULL
  icon_html <- NULL
  if (!is.null(icon)) {
    if (inherits(icon, "shiny.tag")) {
      icon$attribs[["data-icon"]] <- icon_position
      icon_html <- html_fragment(icon)
    } else {
      validate_icon_name(icon)
      icon_name <- icon
    }
  }

  binding <- if (is.null(input_id)) list() else list(
    input = FALSE,
    type = "shinyblocks.button"
  )

  runtime_component(
    component = "button",
    props = list(
      labelHtml = html_fragment(label),
      variant = variant,
      size = size,
      iconName = icon_name,
      iconHtml = icon_html,
      iconPosition = icon_position,
      spriteHref = sprite_href(),
      attrs = attrs,
      disabled = disabled
    ),
    input_id = input_id,
    binding = binding,
    class = class
  )
}

#' Update a runtime button
#'
#' Send a runtime message to a [block_button()] created with `id = "..."`.
#' Any argument left unspecified is preserved on the client. Pass `NULL` for
#' `icon` or `style` to clear them.
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_button()` (via `id = "..."`).
#' @param label Optional replacement label.
#' @param variant Optional new visual variant.
#' @param size Optional new size.
#' @param icon Optional vendored icon name, `shiny.tag`, or `NULL` to clear.
#' @param icon_position Optional `"inline-start"` / `"inline-end"`.
#' @param disabled Optional disabled state.
#' @param style Optional inline CSS styles, or `NULL` to clear.
#' @param class Optional replacement classes for the wrapper.
#'
#' @return Invisibly returns `NULL`.
#' @family action
#' @export
update_block_button <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  label,
  variant,
  size,
  icon,
  icon_position,
  disabled,
  style,
  class
) {
  if (is.null(session)) {
    stop("`session` is required.", call. = FALSE)
  }
  if (!is.function(session$ns)) {
    stop("`session` must provide an `ns()` method.", call. = FALSE)
  }
  if (!is.function(session$sendInputMessage)) {
    stop("`session` must provide a `sendInputMessage()` method.", call. = FALSE)
  }

  validate_input_id(input_id)
  payload <- list()

  if (!missing(label)) {
    payload$labelHtml <- html_fragment(label)
  }
  if (!missing(variant)) {
    variant <- match_arg(
      variant,
      c("default", "secondary", "outline", "ghost", "destructive", "link")
    )
    payload$variant <- variant
  }
  if (!missing(size)) {
    size <- match_arg(size, c("default", "sm", "lg", "icon"))
    payload$size <- size
  }
  if (!missing(icon_position)) {
    icon_position <- match_arg(
      icon_position,
      c("inline-start", "inline-end"),
      "icon_position"
    )
    payload$iconPosition <- icon_position
  }
  if (!missing(icon)) {
    if (is.null(icon)) {
      payload["iconName"] <- list(NULL)
      payload["iconHtml"] <- list(NULL)
    } else if (inherits(icon, "shiny.tag")) {
      pos <- payload$iconPosition %||% "inline-start"
      icon$attribs[["data-icon"]] <- pos
      payload["iconName"] <- list(NULL)
      payload$iconHtml <- html_fragment(icon)
    } else {
      validate_icon_name(icon)
      payload$iconName <- icon
      payload["iconHtml"] <- list(NULL)
    }
    payload$spriteHref <- sprite_href()
  }
  if (!missing(disabled)) {
    payload$disabled <- isTRUE(disabled)
  }
  if (!missing(style)) {
    payload["style"] <- list(if (is.null(style)) NULL else normalize_runtime_style(style))
  }
  if (!missing(class)) {
    payload["class"] <- list(class)
  }

  message_target <- runtime_mount_id("button", session$ns(input_id))
  session$sendInputMessage(message_target, payload)
  invisible(NULL)
}

#' Create a badge
#'
#' @param label Badge label.
#' @param variant Visual variant.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_badge <- function(
  label,
  variant = c("default", "secondary", "outline", "destructive"),
  class = NULL
) {
  variant <- match_arg(
    variant,
    c("default", "secondary", "outline", "destructive")
  )

  runtime_component(
    component = "badge",
    props = list(
      labelHtml = html_fragment(label),
      variant = variant
    ),
    class = class
  )
}

#' Create an alert title
#'
#' @param ... Alert title content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_alert_title <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$h5(
      class = merge_classes("sb-alert-title", class),
      `data-sb-child` = "alert-title",
      ...
    )
  )
}

#' Create an alert description
#'
#' @param ... Alert description content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_alert_description <- function(..., class = NULL) {
  attach_shinyblocks_deps(
    htmltools::tags$div(
      class = merge_classes("sb-alert-description", class),
      `data-sb-child` = "alert-description",
      ...
    )
  )
}

#' Create an alert
#'
#' @param title Alert title. Required for accessibility.
#' @param ... Additional alert body content.
#' @param description Optional alert description.
#' @param icon Optional icon tag or vendored icon name.
#' @param variant Visual variant.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_alert <- function(
  title,
  ...,
  description = NULL,
  icon = "info",
  variant = c("default", "destructive"),
  class = NULL
) {
  if (missing(title) || is.null(title)) {
    stop("`title` is required.", call. = FALSE)
  }

  variant <- match_arg(variant, c("default", "destructive"))
  title_tag <- as_component_child(title, "alert-title", block_alert_title)
  description_tag <- as_component_child(
    description,
    "alert-description",
    block_alert_description
  )
  icon_tag <- set_icon_position(icon, "inline-start")

  runtime_component(
    component = "alert",
    props = list(
      variant = variant,
      titleHtml = html_fragment(title_tag),
      descriptionHtml = if (!is.null(description_tag)) {
        html_fragment(description_tag)
      } else {
        NULL
      },
      contentHtml = html_fragment(...),
      iconHtml = if (!is.null(icon_tag)) html_fragment(icon_tag) else NULL
    ),
    class = class
  )
}

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
  class = NULL
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
    class = class
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
  notify = TRUE
) {
  if (is.null(session)) {
    stop("`session` is required.", call. = FALSE)
  }
  if (!is.function(session$ns)) {
    stop("`session` must provide an `ns()` method.", call. = FALSE)
  }
  if (!is.function(session$sendInputMessage)) {
    stop("`session` must provide a `sendInputMessage()` method.", call. = FALSE)
  }

  validate_input_id(input_id)
  payload <- list()

  if (!missing(open)) {
    payload$open <- isTRUE(open)
  }
  if (!missing(title)) {
    payload$titleHtml <- if (is.null(title)) NULL else html_fragment(title)
  }
  if (!missing(description)) {
    payload$descriptionHtml <- if (is.null(description)) NULL else html_fragment(description)
  }
  if (!missing(footer)) {
    payload["footerHtml"] <- list(if (is.null(footer)) NULL else html_fragment(footer))
  }
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

  payload$notify <- isTRUE(notify) && "open" %in% names(payload)
  message_target <- runtime_mount_id("dialog", session$ns(input_id))

  session$sendInputMessage(message_target, payload)
  invisible(NULL)
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
  if (is.null(session)) {
    stop("`session` is required.", call. = FALSE)
  }
  if (!is.function(session$ns)) {
    stop("`session` must provide an `ns()` method.", call. = FALSE)
  }
  if (!is.function(session$sendInputMessage)) {
    stop("`session` must provide a `sendInputMessage()` method.", call. = FALSE)
  }

  validate_input_id(input_id)
  payload <- list()

  if (!missing(open)) {
    payload$open <- isTRUE(open)
  }
  if (!missing(trigger)) {
    if (is.null(trigger) || !is.character(trigger) || length(trigger) != 1) {
      stop("`trigger` must be a single string label.", call. = FALSE)
    }
    payload$triggerLabel <- trigger
  }
  if (!missing(body)) {
    payload["bodyHtml"] <- list(if (is.null(body)) NULL else html_fragment(body))
  }
  if (!missing(side)) {
    payload$side <- match.arg(side, c("bottom", "top", "left", "right"))
  }
  if (!missing(align)) {
    payload$align <- match.arg(align, c("center", "start", "end"))
  }
  if (!missing(style)) {
    payload["contentStyle"] <- list(if (is.null(style)) NULL else normalize_runtime_style(style))
  }
  if (!missing(class)) {
    payload["contentClass"] <- list(class)
  }

  payload$notify <- isTRUE(notify) && "open" %in% names(payload)
  message_target <- runtime_mount_id("popover", session$ns(input_id))

  session$sendInputMessage(message_target, payload)
  invisible(NULL)
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

#' Create a value box
#'
#' @param title Value box title.
#' @param value Primary value.
#' @param ... Additional value box body content.
#' @param description Optional value box description.
#' @param icon Optional icon tag or vendored icon name.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_value_box <- function(
  title,
  value,
  ...,
  description = NULL,
  icon = NULL,
  class = NULL
) {
  icon_tag <- set_icon_position(icon, "inline-start")

  runtime_component(
    component = "value-box",
    props = list(
      titleHtml = html_fragment(title),
      valueHtml = html_fragment(value),
      descriptionHtml = if (!is.null(description)) html_fragment(description) else NULL,
      contentHtml = html_fragment(...),
      iconHtml = if (!is.null(icon_tag)) html_fragment(icon_tag) else NULL
    ),
    class = class
  )
}

#' Create a separator
#'
#' @param orientation Separator orientation.
#' @param decorative Whether the separator is decorative only.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_separator <- function(
  orientation = c("horizontal", "vertical"),
  decorative = TRUE,
  class = NULL
) {
  orientation <- match_arg(
    orientation,
    c("horizontal", "vertical"),
    "orientation"
  )

  runtime_component(
    component = "separator",
    props = list(
      orientation = orientation,
      decorative = isTRUE(decorative)
    ),
    class = class
  )
}

#' Create a skeleton placeholder
#'
#' @param class Additional classes.
#' @param ... Additional attributes passed to `htmltools::tags$div`.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_skeleton <- function(class = NULL, ...) {
  attrs <- named_attrs(list(...))
  if (!is.null(attrs$style)) {
    attrs$style <- normalize_runtime_style(attrs$style)
  }
  extra_class <- attrs[["class"]]
  class <- if (is.null(class) && is.null(extra_class)) {
    NULL
  } else {
    merge_classes(class, extra_class)
  }
  attrs[["class"]] <- NULL

  runtime_component(
    component = "skeleton",
    props = list(
      attrs = attrs
    ),
    class = class
  )
}

#' Create a spinner
#'
#' @param label Accessible label.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_spinner <- function(label = "Loading", class = NULL) {
  runtime_component(
    component = "spinner",
    props = list(
      label = label
    ),
    class = class
  )
}

#' Create an empty state
#'
#' @param title Empty-state title.
#' @param ... Additional empty-state body content.
#' @param description Optional description.
#' @param icon Optional icon tag or vendored icon name.
#' @param action Optional action content.
#' @param class Additional classes.
#'
#' @return An `htmltools` tag.
#' @family content
#' @export
block_empty <- function(
  title,
  ...,
  description = NULL,
  icon = NULL,
  action = NULL,
  class = NULL
) {
  icon_tag <- set_icon_position(icon, "inline-start")

  runtime_component(
    component = "empty",
    props = list(
      titleHtml = html_fragment(title),
      descriptionHtml = if (!is.null(description)) html_fragment(description) else NULL,
      contentHtml = html_fragment(...),
      iconHtml = if (!is.null(icon_tag)) html_fragment(icon_tag) else NULL,
      actionHtml = if (!is.null(action)) html_fragment(action) else NULL
    ),
    class = class
  )
}

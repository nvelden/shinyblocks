TASK_BUTTON_VARIANTS <- c(
  "default",
  "secondary",
  "outline",
  "ghost",
  "destructive",
  "link"
)
# No "icon" size: a task button always carries a text label (and busy label),
# which would clip inside the fixed-width icon button. Icon-only is intentionally
# unsupported; use block_button() for an icon-only trigger.
TASK_BUTTON_SIZES <- c("default", "sm", "lg")
TASK_BUTTON_ICON_POSITIONS <- c("inline-start", "inline-end")
TASK_BUTTON_STATES <- c("ready", "busy")

# Normalize an icon argument (a vendored icon name or a `shiny.tag`) into the
# `iconName` / `iconHtml` payload pair the runtime understands. Mirrors the
# inline logic in `R/button.R`.
task_button_icon <- function(icon, icon_position) {
  if (is.null(icon)) {
    return(list(name = NULL, html = NULL))
  }
  if (inherits(icon, "shiny.tag")) {
    icon$attribs[["data-icon"]] <- icon_position
    return(list(name = NULL, html = html_fragment(icon)))
  }
  validate_icon_name(icon)
  list(name = icon, html = NULL)
}

#' Create a task button with automatic busy state
#'
#' An action button that locks itself the instant it is clicked, shows a busy
#' label and spinner while work runs, and reports a `shinyActionButtonValue`
#' (usable exactly like [shiny::actionButton()]). By default it returns to the
#' ready state after the reactive flush that the click triggered; pass
#' `auto_reset = FALSE` to keep it busy until you release it with
#' [update_block_task_button()].
#'
#' Inspired by shadcn's Button visuals and bslib's `input_task_button()`
#' behavior.
#'
#' @param input_id Input id. Required, because the busy/ready behavior depends
#'   on a Shiny input binding. Read the click count with `input[[input_id]]`.
#' @param label Button label (ready state).
#' @param label_busy Accessible and visible label shown while busy.
#' @param variant Visual variant.
#' @param size Button size: one of `"default"`, `"sm"`, or `"lg"`.
#' @param icon Optional ready-state icon: a vendored icon name or `shiny.tag`.
#' @param icon_busy Optional busy-state icon: a vendored icon name or
#'   `shiny.tag`. Defaults to a spinner when `NULL`.
#' @param icon_position Whether the icon appears before or after the label.
#' @param auto_reset When `TRUE` (default), the button returns to ready after
#'   the reactive flush triggered by the click, unless the server has taken
#'   manual control via [update_block_task_button()].
#' @param ... Additional attributes passed to the button. Pass `disabled = TRUE`
#'   to render disabled.
#' @param class Additional classes merged onto the runtime button element.
#'
#' @return An `htmltools` tag.
#' @family action
#' @seealso [update_block_task_button()]
#' @export
block_task_button <- function(
  input_id,
  label,
  # Keep the ellipsis locale-independent. A literal non-ASCII character in R
  # source triggers the portable-code check under R CMD check.
  label_busy = "Processing\u2026",
  variant = TASK_BUTTON_VARIANTS,
  size = TASK_BUTTON_SIZES,
  icon = NULL,
  icon_busy = NULL,
  icon_position = TASK_BUTTON_ICON_POSITIONS,
  auto_reset = TRUE,
  ...,
  class = NULL
) {
  validate_input_id(input_id)

  if (
    !is.character(label_busy) ||
      length(label_busy) != 1 ||
      is.na(label_busy)
  ) {
    stop("`label_busy` must be a non-missing length-one string.", call. = FALSE)
  }

  auto_reset <- validate_flag(auto_reset, "auto_reset")

  variant <- match_arg(variant, TASK_BUTTON_VARIANTS)
  size <- match_arg(size, TASK_BUTTON_SIZES)
  icon_position <- match_arg(
    icon_position,
    TASK_BUTTON_ICON_POSITIONS,
    "icon_position"
  )

  attrs <- named_attrs(list(...))
  if (!is.null(attrs$id)) {
    stop(
      "Pass the button id via `input_id`, not `...`.",
      call. = FALSE
    )
  }
  disabled <- isTRUE(attrs$disabled) || identical(attrs$disabled, NA)
  attrs$disabled <- NULL
  # Style flows through the dedicated `style` prop (the same channel the updater
  # uses), not through `attrs`, so a later `update_block_task_button(style =)`
  # is not clobbered by a stale spread of the initial attrs.
  style <- if (is.null(attrs$style)) {
    NULL
  } else {
    normalize_runtime_style(attrs$style)
  }
  attrs$style <- NULL

  ready_icon <- task_button_icon(icon, icon_position)
  busy_icon <- task_button_icon(icon_busy, icon_position)

  runtime_component(
    component = "task-button",
    props = list(
      labelHtml = html_fragment(label),
      labelBusy = label_busy,
      variant = variant,
      size = size,
      iconName = ready_icon$name,
      iconHtml = ready_icon$html,
      iconBusyName = busy_icon$name,
      iconBusyHtml = busy_icon$html,
      iconPosition = icon_position,
      spriteHref = sprite_href(),
      attrs = attrs,
      style = style,
      disabled = disabled,
      autoReset = auto_reset
    ),
    input_id = input_id,
    state = list(value = 0L, state = "ready"),
    binding = list(input = TRUE, type = "shinyblocks.task_button"),
    class = class
  )
}

#' Update a runtime task button
#'
#' Send a runtime message to a [block_task_button()]. Any argument left
#' unspecified is preserved on the client. Pass `NULL` for `icon`, `icon_busy`,
#' `style`, or `class` to clear them.
#'
#' Setting `state = "busy"` takes manual control: an automatic reset scheduled
#' by a click will not release the button. Send `state = "ready"` to release it.
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param input_id Input id passed to `block_task_button()`.
#' @param state Optional `"ready"` or `"busy"`.
#' @param label Optional replacement ready-state label.
#' @param label_busy Optional replacement busy label.
#' @param variant Optional new visual variant.
#' @param size Optional new size.
#' @param icon Optional vendored icon name, `shiny.tag`, or `NULL` to clear.
#' @param icon_busy Optional busy icon name, `shiny.tag`, or `NULL` to clear.
#' @param icon_position Optional `"inline-start"` / `"inline-end"`.
#' @param disabled Optional disabled state.
#' @param style Optional inline CSS styles, or `NULL` to clear.
#' @param class Optional replacement classes merged onto the runtime button
#'   element. Pass `NULL` to clear.
#'
#' @return Invisibly returns `NULL`.
#' @family action
#' @seealso [block_task_button()]
#' @export
update_block_task_button <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  state,
  label,
  label_busy,
  variant,
  size,
  icon,
  icon_busy,
  icon_position,
  disabled,
  style,
  class
) {
  payload <- list()

  state_supplied <- !missing(state)
  if (state_supplied) {
    state <- match_arg(state, TASK_BUTTON_STATES)
    payload$state <- state
  }
  if (!missing(label)) {
    payload$labelHtml <- html_fragment(label)
  }
  if (!missing(label_busy)) {
    if (
      !is.character(label_busy) ||
        length(label_busy) != 1 ||
        is.na(label_busy)
    ) {
      stop(
        "`label_busy` must be a non-missing length-one string.",
        call. = FALSE
      )
    }
    payload$labelBusy <- label_busy
  }
  if (!missing(variant)) {
    payload$variant <- match_arg(variant, TASK_BUTTON_VARIANTS)
  }
  if (!missing(size)) {
    payload$size <- match_arg(size, TASK_BUTTON_SIZES)
  }
  if (!missing(icon_position)) {
    icon_position <- match_arg(
      icon_position,
      TASK_BUTTON_ICON_POSITIONS,
      "icon_position"
    )
    payload$iconPosition <- icon_position
  }
  if (!missing(icon)) {
    pos <- payload$iconPosition %||% "inline-start"
    parts <- task_button_icon(icon, pos)
    payload["iconName"] <- list(parts$name)
    payload["iconHtml"] <- list(parts$html)
    payload$spriteHref <- sprite_href()
  }
  if (!missing(icon_busy)) {
    pos <- payload$iconPosition %||% "inline-start"
    parts <- task_button_icon(icon_busy, pos)
    payload["iconBusyName"] <- list(parts$name)
    payload["iconBusyHtml"] <- list(parts$html)
    payload$spriteHref <- sprite_href()
  }

  payload <- apply_update_fields(
    payload,
    list(
      field("disabled", transform = isTRUE),
      field_style("style"),
      field_clearable("class")
    )
  )

  runtime_input_update(
    session,
    input_id,
    "task-button",
    payload,
    notify_key = NULL
  )

  # Record manual control only after the update has been validated and
  # dispatched. Doing it earlier would let a validation error below (e.g. an
  # invalid `variant`) abort the send while leaving the input permanently marked
  # manual, so its next click could never auto-reset.
  if (state_supplied) {
    key <- session$ns(input_id)
    if (identical(state, "ready")) {
      task_button_clear_manual(session, key)
    } else {
      task_button_mark_manual(session, key)
    }
  }

  invisible(NULL)
}

# --- Session-local manual-reset map --------------------------------------
#
# Tracks which task buttons the server has put under manual control. Stored in
# the root session's `userData` (module session proxies delegate `userData` to
# the root by reference), keyed by the fully namespaced input id, so two
# concurrent sessions using the same local id stay independent. Uses a base R
# environment; no new package dependency.

task_button_manual_env <- function(session) {
  store <- session$userData[["sb_manual_task_button_reset"]]
  if (is.null(store)) {
    store <- new.env(parent = emptyenv())
    session$userData[["sb_manual_task_button_reset"]] <- store
  }
  store
}

task_button_mark_manual <- function(session, key) {
  if (is.null(session)) {
    return(invisible(NULL))
  }
  assign(key, TRUE, envir = task_button_manual_env(session))
  invisible(NULL)
}

task_button_clear_manual <- function(session, key) {
  if (is.null(session)) {
    return(invisible(NULL))
  }
  store <- task_button_manual_env(session)
  if (exists(key, envir = store, inherits = FALSE)) {
    rm(list = key, envir = store)
  }
  invisible(NULL)
}

task_button_is_manual <- function(session, key) {
  if (is.null(session)) {
    return(FALSE)
  }
  store <- task_button_manual_env(session)
  isTRUE(exists(key, envir = store, inherits = FALSE)) &&
    isTRUE(get(key, envir = store, inherits = FALSE))
}

# --- Session-local mount-id map ------------------------------------------
#
# Tracks the last client mount id seen for each namespaced input id. When a
# value report carries a mount id different from the stored one, a *new*
# component instance has bound to a reused id (renderUI/removeUI/insertUI), so
# any manual state left by the previous instance is stale and must be dropped.

task_button_mount_env <- function(session) {
  store <- session$userData[["sb_task_button_mount_ids"]]
  if (is.null(store)) {
    store <- new.env(parent = emptyenv())
    session$userData[["sb_task_button_mount_ids"]] <- store
  }
  store
}

# Returns TRUE when `mount_id` is a new instance for `key` (and records it).
# A NULL mount id (e.g. an older client or a direct unit-test call) is treated
# as "not new" so behavior is unchanged when no mount id is reported.
task_button_is_new_mount <- function(session, key, mount_id) {
  if (is.null(session) || is.null(mount_id)) {
    return(FALSE)
  }
  store <- task_button_mount_env(session)
  seen <- if (exists(key, envir = store, inherits = FALSE)) {
    get(key, envir = store, inherits = FALSE)
  } else {
    NULL
  }
  if (identical(seen, mount_id)) {
    return(FALSE)
  }
  assign(key, mount_id, envir = store)
  TRUE
}

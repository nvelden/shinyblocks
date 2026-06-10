# Monotonic counter for auto-generated toast ids. Server-generated ids stay
# stable so `dismiss_toast()` can target a specific toast later.
toast_id_state <- new.env(parent = emptyenv())
toast_id_state$next_id <- 0L

next_toast_id <- function() {
  toast_id_state$next_id <- toast_id_state$next_id + 1L
  paste0("sb-toast-", toast_id_state$next_id)
}

toast_positions <- c(
  "top-left", "top-center", "top-right",
  "bottom-left", "bottom-center", "bottom-right"
)

toast_variants <- c("default", "destructive", "success", "warning", "info")

validate_toast_duration <- function(duration) {
  if (
    !is.numeric(duration) ||
      length(duration) != 1 ||
      is.na(duration) ||
      !is.finite(duration)
  ) {
    stop(
      "`duration` must be a single finite number (milliseconds).",
      call. = FALSE
    )
  }

  as.numeric(duration)
}

validate_toast_flag <- function(value, arg) {
  if (!is.logical(value) || length(value) != 1 || is.na(value)) {
    stop(sprintf("`%s` must be `TRUE` or `FALSE`.", arg), call. = FALSE)
  }

  value
}

validate_toast_id <- function(value, arg) {
  if (
    !is.character(value) ||
      length(value) != 1 ||
      is.na(value) ||
      !nzchar(value)
  ) {
    stop(sprintf("`%s` must be a non-empty string.", arg), call. = FALSE)
  }

  value
}

#' Create a toast notification region
#'
#' Mounts a single, portal-rendered region that displays transient toast
#' notifications fired from the server with [show_toast()]. Unlike
#' [block_alert()], a toaster is not inline content: place one (per position)
#' near the top of your app body, then call [show_toast()] to push messages.
#'
#' `input$<id>` reports the most recent toast lifecycle event as a list with
#' `action` (`"show"` or `"dismiss"`), `id` (the toast id, or `NULL` when all
#' toasts are dismissed), and `seq` (a monotonic counter). The counter
#' guarantees the value changes on every show and dismiss — including
#' auto-dismiss, the close button, and `Escape` — so server observers always
#' fire.
#'
#' @param id Required input id. Targets this toaster from [show_toast()] and
#'   [dismiss_toast()], and reports toast lifecycle events to `input$<id>`.
#' @param position Screen corner/edge the stack anchors to. One of
#'   `"top-left"`, `"top-center"`, `"top-right"`, `"bottom-left"`,
#'   `"bottom-center"`, `"bottom-right"`. Defaults to `"bottom-right"`.
#' @param class Additional classes for the toaster region.
#' @param style Optional inline custom styles for the toaster region.
#'
#' @return An `htmltools` tag.
#' @family content
#' @seealso [show_toast()], [dismiss_toast()]
#' @export
block_toaster <- function(
  id,
  position = c(
    "bottom-right", "bottom-center", "bottom-left",
    "top-right", "top-center", "top-left"
  ),
  class = NULL,
  style = NULL
) {
  if (missing(id) || is.null(id)) {
    stop("`id` is required.", call. = FALSE)
  }
  validate_input_id(id)
  position <- match_arg(position, toast_positions)

  runtime_component(
    component = "toaster",
    input_id = id,
    props = list(position = position),
    state = list(value = NULL),
    binding = list(input = TRUE, type = "shinyblocks.toaster"),
    class = class,
    style = style
  )
}

# Normalize a single `show_toast()` call into the runtime toast object.
build_toast <- function(
  title,
  description,
  variant,
  icon,
  duration,
  dismissible,
  id
) {
  if (missing(title) || is.null(title)) {
    stop("`title` is required.", call. = FALSE)
  }
  variant <- match_arg(variant, toast_variants)
  duration <- validate_toast_duration(duration)
  dismissible <- validate_toast_flag(dismissible, "dismissible")
  if (!is.null(id)) {
    id <- validate_toast_id(id, "id")
  }

  title_tag <- as_component_child(title, "alert-title", block_alert_title)
  description_tag <- as_component_child(
    description,
    "alert-description",
    block_alert_description
  )
  icon_tag <- set_icon_position(icon, "inline-start")

  list(
    id = if (is.null(id)) next_toast_id() else id,
    variant = variant,
    titleHtml = html_fragment(title_tag),
    descriptionHtml = if (!is.null(description_tag)) {
      html_fragment(description_tag)
    } else {
      NULL
    },
    iconHtml = if (!is.null(icon_tag)) html_fragment(icon_tag) else NULL,
    duration = duration,
    dismissible = dismissible
  )
}

#' Update a toaster region
#'
#' Send a server-driven update to a [block_toaster()]. Currently supports moving
#' the region to a different screen position without re-mounting it.
#'
#' @param session Shiny session. Defaults to the current reactive session.
#' @param toaster_id Target [block_toaster()] id.
#' @param position New screen anchor. One of `"top-left"`, `"top-center"`,
#'   `"top-right"`, `"bottom-left"`, `"bottom-center"`, `"bottom-right"`.
#'
#' @return Invisibly returns `NULL`.
#' @family content
#' @seealso [block_toaster()], [show_toast()], [dismiss_toast()]
#' @export
update_block_toaster <- function(
  session = shiny::getDefaultReactiveDomain(),
  toaster_id,
  position
) {
  if (missing(toaster_id)) {
    stop("`toaster_id` is required.", call. = FALSE)
  }

  payload <- list(action = "config")
  if (!missing(position)) {
    payload$position <- match_arg(position, toast_positions)
  }

  runtime_input_update(
    session, toaster_id, "toaster", payload,
    notify_key = NULL
  )
  invisible(NULL)
}

#' Show a toast notification
#'
#' Pushes a transient toast onto a [block_toaster()] from the server. Toasts
#' stack, auto-dismiss after `duration`, and reuse the [block_alert()] visual
#' variants and icon system.
#'
#' @param session Shiny session. Defaults to the current reactive session.
#' @param toaster_id Target [block_toaster()] id (unnamespaced; namespaced via
#'   `session$ns()`).
#' @param title Toast title. Required.
#' @param description Optional secondary text.
#' @param variant Visual variant. One of `"default"`, `"destructive"`,
#'   `"success"`, `"warning"`, `"info"`. Defaults to `"default"`.
#' @param icon Optional icon tag or vendored icon name. Defaults to `"info"`.
#'   Pass `NULL` for no icon.
#' @param duration Finite milliseconds before auto-dismiss. Use `0` (or a
#'   negative value) to keep the toast until dismissed. Defaults to `5000`.
#' @param dismissible Scalar logical; whether the toast shows a close button.
#'   Defaults to `TRUE`.
#' @param id Optional stable non-empty toast id. Auto-generated when omitted;
#'   supply one to target the toast later with [dismiss_toast()].
#'
#' @return Invisibly returns the toast `id`.
#' @family content
#' @seealso [block_toaster()], [dismiss_toast()]
#' @export
show_toast <- function(
  session = shiny::getDefaultReactiveDomain(),
  toaster_id,
  title,
  description = NULL,
  variant = "default",
  icon = "info",
  duration = 5000,
  dismissible = TRUE,
  id = NULL
) {
  if (missing(toaster_id)) {
    stop("`toaster_id` is required.", call. = FALSE)
  }
  toast <- build_toast(
    title = title,
    description = description,
    variant = variant,
    icon = icon,
    duration = duration,
    dismissible = dismissible,
    id = id
  )

  runtime_input_update(
    session, toaster_id, "toaster",
    list(action = "add", toast = toast),
    notify_key = "toast"
  )
  invisible(toast$id)
}

#' Dismiss a toast notification
#'
#' Removes a toast from a [block_toaster()] before it auto-dismisses. With no
#' `toast_id`, clears every visible toast.
#'
#' @param session Shiny session. Defaults to the current reactive session.
#' @param toaster_id Target [block_toaster()] id.
#' @param toast_id Non-empty id of the toast to dismiss (as returned by
#'   [show_toast()]). `NULL` dismisses all toasts.
#'
#' @return Invisibly returns `NULL`.
#' @family content
#' @seealso [block_toaster()], [show_toast()]
#' @export
dismiss_toast <- function(
  session = shiny::getDefaultReactiveDomain(),
  toaster_id,
  toast_id = NULL
) {
  if (missing(toaster_id)) {
    stop("`toaster_id` is required.", call. = FALSE)
  }
  if (!is.null(toast_id)) {
    toast_id <- validate_toast_id(toast_id, "toast_id")
  }

  payload <- list(action = "dismiss")
  payload["toastId"] <- list(toast_id)

  runtime_input_update(
    session, toaster_id, "toaster", payload,
    notify_key = "action"
  )
  invisible(NULL)
}

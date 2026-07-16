runtime_input_update <- function(
  session,
  input_id,
  component,
  payload,
  notify_key = "value",
  notify = TRUE
) {
  notify <- validate_flag(notify, "notify")
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

  if (!is.null(notify_key)) {
    payload$notify <- notify && notify_key %in% names(payload)
  }

  # `session$ns()` resolves the fully namespaced input id; baking it into the
  # mount-id slug yields the runtime element's DOM id (the routing target).
  message_target <- runtime_mount_id(component, session$ns(input_id))

  # Deliver via the root session. A `moduleServer` session proxy re-namespaces
  # the first arg of its own `sendInputMessage()`, which would double-prefix an
  # already-namespaced target and silently drop the update (issue #63). The root
  # `ShinySession$ns` is identity, so the ns-baked target routes unchanged.
  runtime_root_session(session)$sendInputMessage(message_target, payload)
  invisible(NULL)
}

# Walk up to the root `ShinySession`. Shiny exposes `rootScope()` on real
# sessions (returning the root for both top-level and module-proxy sessions);
# mock/test sessions without it fall back to the session as given.
runtime_root_session <- function(session) {
  if (is.function(session$rootScope)) {
    root <- session$rootScope()
    if (!is.null(root) && is.function(root$sendInputMessage)) {
      return(root)
    }
  }
  session
}

payload_set_if_present <- function(payload, name, value, transform = NULL) {
  payload[[name]] <- if (is.null(transform)) value else transform(value)
  payload
}

payload_set_clearable <- function(payload, name, value, transform = NULL) {
  payload[name] <- list(
    if (is.null(value)) {
      NULL
    } else if (is.null(transform)) {
      value
    } else {
      transform(value)
    }
  )
  payload
}

payload_set_style <- function(payload, name, style) {
  payload_set_clearable(payload, name, style, normalize_runtime_style)
}

# Spec-driven payload assembly for `update_block_*()` helpers.
#
# Every updater turns its supplied arguments into a runtime payload by running
# the same three setters above under a `!missing()` guard. The `field*()`
# constructors capture that mapping as data — payload key, source argument
# (defaults to the key), setter, optional transform — so each updater lists its
# plain fields instead of repeating the guard/setter boilerplate. Fields needing
# bespoke validation (match.arg, range checks) stay inline in the caller.
field <- function(key, arg = key, transform = NULL) {
  list(key = key, arg = arg, method = "if_present", transform = transform)
}
field_clearable <- function(key, arg = key, transform = NULL) {
  list(key = key, arg = arg, method = "clearable", transform = transform)
}
field_style <- function(key, arg = key) {
  list(key = key, arg = arg, method = "style", transform = NULL)
}

# Apply `fields` to `payload`, reading values from the calling updater. Only
# arguments the caller explicitly supplied are emitted: `match.call()` on the
# parent frame lists them exactly as `missing()` would, so defaulted arguments
# are skipped.
apply_update_fields <- function(
  payload,
  fields,
  supplied = NULL,
  env = parent.frame()
) {
  if (is.null(supplied)) {
    supplied <- names(match.call(
      definition = sys.function(-1L),
      call = sys.call(-1L),
      envir = parent.frame(2L)
    ))[-1L]
  }
  for (f in fields) {
    if (!f$arg %in% supplied) {
      next
    }
    value <- get(f$arg, envir = env)
    payload <- switch(
      f$method,
      if_present = payload_set_if_present(payload, f$key, value, f$transform),
      clearable = payload_set_clearable(payload, f$key, value, f$transform),
      style = payload_set_style(payload, f$key, value)
    )
  }
  payload
}

supplied_args <- function(call = match.call()) names(call)[-1L]

# Shared transform: a text input's value coerces to a string, treating NULL as
# an empty string rather than dropping the field.
as_text_value <- function(value) if (is.null(value)) "" else as.character(value)

normalize_width_style <- function(width, default = NULL) {
  if (is.null(width)) {
    return(default)
  }
  paste0("width:", htmltools::validateCssUnit(width), ";")
}

hidden_native_input <- function(
  input_id,
  type,
  class,
  value = NULL,
  checked = FALSE,
  disabled = FALSE,
  style = "display:none",
  tabindex = "-1",
  aria_hidden = TRUE
) {
  htmltools::tags$input(
    id = input_id,
    type = type,
    class = class,
    tabindex = tabindex,
    `aria-hidden` = if (isTRUE(aria_hidden)) "true" else NULL,
    `data-shiny-no-bind-input` = "",
    style = style,
    value = value,
    checked = if (isTRUE(checked)) NA else NULL,
    disabled = if (isTRUE(disabled)) NA else NULL
  )
}

hidden_native_textarea <- function(
  input_id,
  class,
  value = "",
  style = "display:none"
) {
  htmltools::tags$textarea(
    id = input_id,
    class = class,
    tabindex = "-1",
    `aria-hidden` = "true",
    `data-shiny-no-bind-input` = "",
    style = style,
    value
  )
}

native_file_input <- function(
  input_id,
  multiple = FALSE,
  accept = NULL,
  disabled = FALSE
) {
  htmltools::tagList(
    htmltools::tags$input(
      id = input_id,
      type = "file",
      class = "shiny-input-file sb-file-input-native",
      # Visually hidden but kept in the a11y tree; the styled button is the sole
      # tab stop and forwards activation via `native.click()`, so the input
      # itself must not be a second (invisible) tab stop.
      tabindex = "-1",
      multiple = if (isTRUE(multiple)) NA else NULL,
      accept = accept,
      disabled = if (isTRUE(disabled)) NA else NULL
    ),
    htmltools::tags$div(
      id = paste0(input_id, "_progress"),
      class = "progress active shiny-file-input-progress sb-file-input-progress",
      htmltools::tags$div(class = "progress-bar")
    )
  )
}

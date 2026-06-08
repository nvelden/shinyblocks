runtime_input_update <- function(
  session,
  input_id,
  component,
  payload,
  notify_key = "value",
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

  if (!is.null(notify_key)) {
    payload$notify <- isTRUE(notify) && notify_key %in% names(payload)
  }

  message_target <- runtime_mount_id(component, session$ns(input_id))
  session$sendInputMessage(message_target, payload)
  invisible(NULL)
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

hidden_native_textarea <- function(input_id, class, value = "", style = "display:none") {
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

native_file_input <- function(input_id, multiple = FALSE, accept = NULL, disabled = FALSE) {
  htmltools::tagList(
    htmltools::tags$input(
      id = input_id,
      type = "file",
      class = "shiny-input-file sb-file-input-native",
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

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

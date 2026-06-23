.onLoad <- function(libname, pkgname) {
  shiny::addResourcePath(
    prefix = "shinyblocks",
    directoryPath = system.file("www", package = pkgname)
  )

  shiny::registerInputHandler("shinyblocks.button", function(val, transport, name) {
    if (is.null(val)) return(NULL)
    class(val) <- c("shinyActionButtonValue", "shiny.actionButton", class(val))
    val
  }, force = TRUE)

  # Task button: the browser reports `{ value: <clickCount>, autoReset: <bool> }`.
  # We expose the numeric click count as a `shinyActionButtonValue` (so it reads
  # like `actionButton()`), and — when the click requested an automatic reset —
  # schedule a single post-flush callback that returns the button to ready,
  # unless the server has taken manual control via `update_block_task_button()`.
  shiny::registerInputHandler("shinyblocks.task_button", function(val, session, name) {
    if (is.null(val)) return(NULL)

    count <- val[["value"]]
    auto_reset <- isTRUE(val[["autoReset"]])

    if (auto_reset && !is.null(session) && is.function(session$onFlush)) {
      target <- runtime_mount_id("task-button", name)
      session$onFlush(once = TRUE, function() {
        if (task_button_is_manual(session, name)) return(invisible(NULL))
        session$sendInputMessage(target, list(state = "ready"))
      })
    }

    count <- if (is.null(count)) 0L else as.numeric(count)
    class(count) <- c("shinyActionButtonValue", "shiny.actionButton", class(count))
    count
  }, force = TRUE)

  # Progress is display-only: its binding declares `type = "shinyblocks.progress"`
  # (so getType()/the payload agree) but reports no value. Register a handler so
  # Shiny accepts the typed message instead of erroring on an unknown type; it
  # always resolves to NULL, keeping `input$<id>` empty.
  shiny::registerInputHandler("shinyblocks.progress", function(val, transport, name) {
    NULL
  }, force = TRUE)
}

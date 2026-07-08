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
    count_num <- if (is.null(count)) 0 else as.numeric(count)

    # Drop stale manual state when a *new* component instance binds to a reused
    # input id. Each client mount reports a unique mount id; when it differs from
    # the last one seen for this id, a previous instance — possibly left
    # manual-busy via update_block_task_button() and then removed by
    # renderUI/removeUI/insertUI — has been replaced. Its manual flag would
    # otherwise suppress the fresh instance's automatic reset forever. The mount
    # id changes even when the click count is unchanged (so it survives Shiny's
    # value deduplication), which a count-based check cannot.
    if (task_button_is_new_mount(session, name, val[["mountId"]])) {
      task_button_clear_manual(session, name)
    }

    if (auto_reset && !is.null(session) && is.function(session$onFlush)) {
      target <- runtime_mount_id("task-button", name)
      session$onFlush(once = TRUE, function() {
        if (task_button_is_manual(session, name)) return(invisible(NULL))
        session$sendInputMessage(target, list(state = "ready"))
      })
    }

    class(count_num) <- c("shinyActionButtonValue", "shiny.actionButton", class(count_num))
    count_num
  }, force = TRUE)

  # Number inputs (`block_input(type = "number")`) report their raw text; the
  # typed handler converts it so `input$<id>` behaves like `numericInput()`:
  # empty or unparseable text is NA, everything else a numeric scalar.
  shiny::registerInputHandler("shinyblocks.number", function(val, transport, name) {
    if (is.null(val)) return(NULL)
    val <- as.character(val)
    if (length(val) != 1 || !nzchar(trimws(val))) return(NA_real_)
    suppressWarnings(as.numeric(val))
  }, force = TRUE)

  # Progress is display-only: its binding declares `type = "shinyblocks.progress"`
  # (so getType()/the payload agree) but reports no value. Register a handler so
  # Shiny accepts the typed message instead of erroring on an unknown type; it
  # always resolves to NULL, keeping `input$<id>` empty.
  shiny::registerInputHandler("shinyblocks.progress", function(val, transport, name) {
    NULL
  }, force = TRUE)

  # Multiple-open accordions report an array of open item values. Coerce it to a
  # plain character vector so `input$<id>` is `character(0)` when nothing is open
  # instead of an empty list. Single-open accordions use no type (scalar/NULL).
  shiny::registerInputHandler("shinyblocks.accordion", function(val, transport, name) {
    if (is.null(val)) return(character(0))
    as.character(unlist(val))
  }, force = TRUE)
}

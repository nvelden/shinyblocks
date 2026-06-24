# A fake session sufficient for the task-button input handler and updater:
# `ns` namespaces ids, `onFlush` records the registered callback so the test can
# fire it, `sendInputMessage` captures runtime messages, and `userData` is a
# real environment (where the manual-reset map lives).
fake_task_session <- function(ns = identity) {
  messages <- list()
  flush_cbs <- list()
  session <- new.env(parent = emptyenv())
  session$ns <- ns
  session$userData <- new.env(parent = emptyenv())
  session$sendInputMessage <- function(input_id, payload) {
    messages[[length(messages) + 1L]] <<- list(input_id = input_id, payload = payload)
  }
  session$onFlush <- function(fun, once = TRUE) {
    flush_cbs[[length(flush_cbs) + 1L]] <<- fun
    invisible(NULL)
  }
  session$rootScope <- function() session
  list(
    session = session,
    messages = function() messages,
    fire_flush = function() for (cb in flush_cbs) cb(),
    flush_count = function() length(flush_cbs)
  )
}

task_button_handler <- function() {
  handlers <- get("inputHandlers", envir = asNamespace("shiny"))
  handlers$get("shinyblocks.task_button")
}

test_that("block_task_button() emits a required input id and task_button binding", {
  tag <- block_task_button("run", "Run analysis")
  html <- render_html(tag)

  expect_match(html, 'data-sb-component="task-button"', fixed = TRUE)
  expect_match(html, 'data-sb-input-id="run"', fixed = TRUE)
  expect_match(html, 'id="sb-runtime-task-button-run"', fixed = TRUE)
  expect_match(html, '"binding":\\{"input":true,"type":"shinyblocks\\.task_button"\\}')
})

test_that("block_task_button() payload carries label, busy label, and auto_reset", {
  payload <- runtime_payload_from(block_task_button(
    "run", "Run", label_busy = "Working…", auto_reset = FALSE
  ))
  expect_match(payload$props$labelHtml, "Run", fixed = TRUE)
  expect_identical(payload$props$labelBusy, "Working…")
  expect_false(payload$props$autoReset)
  expect_identical(payload$state$state, "ready")
})

test_that("block_task_button() forwards ... attributes and routes style to props", {
  payload <- runtime_payload_from(block_task_button(
    "run", "Go",
    title = "Run it",
    `aria-label` = "Run the analysis",
    `data-test` = "tb",
    style = "min-width: 10rem;"
  ))
  # Passthrough attrs reach the button via props$attrs ...
  expect_identical(payload$props$attrs$title, "Run it")
  expect_identical(payload$props$attrs$`aria-label`, "Run the analysis")
  expect_identical(payload$props$attrs$`data-test`, "tb")
  # ... while style is normalized onto the dedicated style channel, not attrs.
  expect_null(payload$props$attrs$style)
  expect_identical(payload$props$style$minWidth, "10rem")
})

test_that("block_task_button() validates its arguments", {
  expect_error(block_task_button("", "x"), "non-empty string")
  expect_error(block_task_button("id", "x", label_busy = c("a", "b")), "length-one string")
  expect_error(block_task_button("id", "x", label_busy = NA_character_), "length-one string")
  expect_error(block_task_button("id", "x", auto_reset = NA), "length-one logical")
  expect_error(block_task_button("id", "x", auto_reset = c(TRUE, FALSE)), "length-one logical")
  expect_error(block_task_button("id", "x", variant = "nope"), "must be one of")
  expect_error(block_task_button("id", "x", size = "huge"), "must be one of")
  expect_error(block_task_button("id", "x", id = "y"), "via `input_id`")
})

test_that("block_task_button() serializes icon names and tags", {
  named <- runtime_payload_from(block_task_button("run", "Go", icon = "check"))
  expect_identical(named$props$iconName, "check")
  expect_null(named$props$iconHtml)

  tagged <- runtime_payload_from(block_task_button(
    "run", "Go", icon = htmltools::tags$span("x")
  ))
  expect_null(tagged$props$iconName)
  expect_match(tagged$props$iconHtml, "x", fixed = TRUE)
})

test_that("update_block_task_button() emits only supplied fields", {
  capture <- local_input_message_session()
  update_block_task_button(capture$session, "run", label = "Done", variant = "secondary")
  payload <- capture$last_payload()

  expect_identical(capture$messages()[[1]]$input_id, "sb-runtime-task-button-run")
  expect_match(payload$labelHtml, "Done", fixed = TRUE)
  expect_identical(payload$variant, "secondary")
  expect_false("size" %in% names(payload))
  expect_false("disabled" %in% names(payload))
})

test_that("update_block_task_button() emits the full set of supplied fields", {
  capture <- local_input_message_session()
  update_block_task_button(
    capture$session, "run",
    label_busy = "Working…",
    size = "lg",
    icon_position = "inline-end"
  )
  payload <- capture$last_payload()

  expect_identical(payload$labelBusy, "Working…")
  expect_identical(payload$size, "lg")
  expect_identical(payload$iconPosition, "inline-end")
})

test_that("update_block_task_button() validates label_busy", {
  capture <- local_input_message_session()
  expect_error(
    update_block_task_button(capture$session, "run", label_busy = c("a", "b")),
    "length-one string"
  )
})

test_that("update_block_task_button() clears style and class via NULL", {
  capture <- local_input_message_session()
  update_block_task_button(capture$session, "run", style = NULL, class = NULL)
  payload <- capture$last_payload()

  expect_true("style" %in% names(payload))
  expect_null(payload$style)
  expect_true("class" %in% names(payload))
  expect_null(payload$class)
})

test_that("block_task_button() namespaces the mount id under a module", {
  ns <- shiny::NS("mod")
  html <- render_html(block_task_button(ns("run"), "Run"))
  expect_match(html, 'data-sb-input-id="mod-run"', fixed = TRUE)
  expect_match(html, 'id="sb-runtime-task-button-mod-run"', fixed = TRUE)
})

test_that("update_block_task_button() clears icons via NULL", {
  capture <- local_input_message_session()
  update_block_task_button(capture$session, "run", icon = NULL, icon_busy = NULL)
  payload <- capture$last_payload()

  expect_true("iconName" %in% names(payload))
  expect_null(payload$iconName)
  expect_true("iconBusyName" %in% names(payload))
  expect_null(payload$iconBusyName)
})

test_that("update_block_task_button(state=) toggles the manual-reset map", {
  ctx <- fake_task_session()
  session <- ctx$session

  update_block_task_button(session, "run", state = "busy")
  expect_true(task_button_is_manual(session, "run"))

  update_block_task_button(session, "run", state = "ready")
  expect_false(task_button_is_manual(session, "run"))
})

test_that("a failed update does not poison the manual-reset map", {
  ctx <- fake_task_session()
  session <- ctx$session

  # A later invalid argument must abort the whole update — including the manual
  # mark — so the input is not left permanently suppressed from auto-reset.
  expect_error(
    update_block_task_button(session, "run", state = "busy", variant = "invalid"),
    "must be one of"
  )
  expect_false(task_button_is_manual(session, "run"))
  expect_length(ctx$messages(), 0)

  # A valid update still records manual control.
  update_block_task_button(session, "run", state = "busy", variant = "secondary")
  expect_true(task_button_is_manual(session, "run"))
})

test_that("manual-reset map is isolated per session and keyed by namespaced id", {
  a <- fake_task_session()$session
  b <- fake_task_session()$session
  task_button_mark_manual(a, "run")
  expect_true(task_button_is_manual(a, "run"))
  expect_false(task_button_is_manual(b, "run"))

  # Module namespacing: the updater keys by session$ns(input_id).
  mod <- fake_task_session(ns = function(id) paste0("mod-", id))$session
  update_block_task_button(mod, "run", state = "busy")
  expect_true(task_button_is_manual(mod, "mod-run"))
  expect_false(task_button_is_manual(mod, "run"))
})

test_that("input handler returns a classed click count", {
  handler <- task_button_handler()
  out <- handler(list(value = 3, autoReset = FALSE), NULL, "run")
  expect_equal(as.numeric(out), 3)
  expect_s3_class(out, "shinyActionButtonValue")
  expect_s3_class(out, "shiny.actionButton")
  expect_null(handler(NULL, NULL, "run"))
})

test_that("input handler schedules an auto-reset that respects manual control", {
  handler <- task_button_handler()

  # auto_reset = TRUE, not under manual control: the flush sends state = ready.
  ctx <- fake_task_session()
  handler(list(value = 1, autoReset = TRUE), ctx$session, "run")
  expect_identical(ctx$flush_count(), 1L)
  ctx$fire_flush()
  msgs <- ctx$messages()
  expect_identical(msgs[[length(msgs)]]$input_id, "sb-runtime-task-button-run")
  expect_identical(msgs[[length(msgs)]]$payload$state, "ready")

  # Manual control set before the flush fires: no reset is sent.
  ctx2 <- fake_task_session()
  handler(list(value = 1, autoReset = TRUE), ctx2$session, "run")
  task_button_mark_manual(ctx2$session, "run")
  ctx2$fire_flush()
  expect_length(ctx2$messages(), 0)

  # auto_reset = FALSE: no flush callback is scheduled at all.
  ctx3 <- fake_task_session()
  handler(list(value = 1, autoReset = FALSE), ctx3$session, "run")
  expect_identical(ctx3$flush_count(), 0L)
})

test_that("block_task_button() renders a stable tag", {
  # Pin the sprite href to its stable app-mode path so the snapshot does not
  # churn on the build-time asset version.
  withr::local_options(shinyblocks.asset_mode = "app")
  expect_snapshot(cat(render_html(block_task_button(
    "run", "Run analysis", label_busy = "Working", variant = "secondary"
  ))))
})

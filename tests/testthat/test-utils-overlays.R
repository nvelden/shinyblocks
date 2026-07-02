test_that("update_block_dialog sends input binding messages", {
  capture <- local_input_message_session()

  expect_invisible(
    update_block_dialog(
      capture$session,
      "confirm",
      open = TRUE,
      title = "New title",
      description = "Updated copy.",
      notify = TRUE
    )
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-dialog-confirm")
  expect_identical(message$payload$open, TRUE)
  expect_match(message$payload$titleHtml, "New title", fixed = TRUE)
  expect_match(message$payload$descriptionHtml, "Updated copy.", fixed = TRUE)
  expect_identical(message$payload$notify, TRUE)
})

test_that("cosmetic update_block_dialog messages do not notify", {
  capture <- local_input_message_session()

  update_block_dialog(capture$session, "confirm", title = "Renamed")
  message <- capture$last_payload()
  expect_identical(message$notify, FALSE)
  expect_match(message$titleHtml, "Renamed", fixed = TRUE)
  expect_null(message$open)
})

test_that("update_block_dialog requires a session with the right hooks", {
  expect_error(update_block_dialog(NULL, "confirm"), "session")
  expect_error(
    update_block_dialog(list(), "confirm"),
    "ns"
  )
})

test_that("block_dialog emits a runtime payload with input id and open state", {
  payload <- runtime_payload_from(
    block_dialog(
      id = "confirm",
      title = "Are you sure?",
      description = "This cannot be undone.",
      "Body content.",
      trigger = "Delete account",
      open = FALSE,
      class = "custom-dialog",
      style = "max-width: 42rem;"
    )
  )

  expect_identical(payload$component, "dialog")
  expect_identical(payload$id, "confirm")
  expect_identical(payload$state$value, FALSE)
  expect_identical(payload$state$open, FALSE)
  expect_identical(payload$binding$input, TRUE)
  expect_match(payload$props$titleHtml, "Are you sure?", fixed = TRUE)
  expect_match(payload$props$descriptionHtml, "cannot be undone", fixed = TRUE)
  expect_match(payload$props$bodyHtml, "Body content.", fixed = TRUE)
  expect_identical(payload$props$triggerLabel, "Delete account")
  expect_identical(payload$className, "custom-dialog")
  expect_identical(payload$style$maxWidth, "42rem")
})

test_that("block_dialog requires id and title", {
  expect_error(block_dialog(title = "X"), "`id` is required", fixed = TRUE)
  expect_error(block_dialog(id = "x"), "`title` is required", fixed = TRUE)
})

test_that("block_popover emits a runtime payload with trigger and body", {
  payload <- runtime_payload_from(
    block_popover(
      id = "details",
      trigger = "Show details",
      htmltools::tags$p("Hello"),
      side = "top",
      align = "end",
      open = TRUE
    )
  )

  expect_identical(payload$component, "popover")
  expect_identical(payload$props$triggerLabel, "Show details")
  expect_match(payload$props$bodyHtml, "Hello", fixed = TRUE)
  expect_identical(payload$props$side, "top")
  expect_identical(payload$props$align, "end")
  expect_identical(payload$state$open, TRUE)
  expect_identical(payload$binding$input, TRUE)
  expect_identical(payload$binding$type, "shinyblocks.popover")
})

test_that("block_popover requires a string trigger", {
  expect_error(block_popover(trigger = NULL), "`trigger`", fixed = TRUE)
  expect_error(block_popover(trigger = c("a", "b")), "single string", fixed = TRUE)
})

test_that("block_popover rejects invalid side and align", {
  expect_error(block_popover(trigger = "x", side = "diagonal"), "must be one of")
  expect_error(block_popover(trigger = "x", align = "weird"), "must be one of")
})

test_that("block_tooltip emits a runtime payload with trigger and body", {
  payload <- runtime_payload_from(
    block_tooltip(
      trigger = "Hover me",
      htmltools::tags$p("Hello"),
      side = "bottom",
      align = "start",
      delay_duration = 500
    )
  )

  expect_identical(payload$component, "tooltip")
  expect_identical(payload$props$triggerLabel, "Hover me")
  expect_match(payload$props$bodyHtml, "Hello", fixed = TRUE)
  expect_identical(payload$props$side, "bottom")
  expect_identical(payload$props$align, "start")
  expect_identical(payload$props$delayDuration, 500L)
  expect_identical(payload$binding$input, FALSE)
})

test_that("block_tooltip rejects bad trigger, side, align, and delay", {
  expect_error(block_tooltip(trigger = NULL), "`trigger`", fixed = TRUE)
  expect_error(block_tooltip(trigger = c("a", "b")), "single string", fixed = TRUE)
  expect_error(block_tooltip(trigger = "x", side = "diagonal"), "must be one of")
  expect_error(block_tooltip(trigger = "x", align = "weird"), "must be one of")
  expect_error(
    block_tooltip(trigger = "x", delay_duration = -1),
    "non-negative",
    fixed = TRUE
  )
})

test_that("block_popover without id is client-only", {
  payload <- runtime_payload_from(block_popover(trigger = "Open"))

  expect_identical(payload$binding$input, FALSE)
  expect_false("type" %in% names(payload$binding))
})

test_that("update_block_popover sends input binding messages", {
  capture <- local_input_message_session()

  update_block_popover(
    capture$session,
    "details",
    open = TRUE,
    trigger = "Updated label",
    body = htmltools::tags$p("Updated body"),
    side = "left",
    align = "start",
    style = "max-width: 18rem;",
    class = "custom-popover"
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-popover-details")
  expect_identical(message$payload$open, TRUE)
  expect_identical(message$payload$triggerLabel, "Updated label")
  expect_match(message$payload$bodyHtml, "Updated body", fixed = TRUE)
  expect_identical(message$payload$side, "left")
  expect_identical(message$payload$align, "start")
  expect_identical(message$payload$contentStyle$maxWidth, "18rem")
  expect_identical(message$payload$contentClass, "custom-popover")
  expect_identical(message$payload$notify, TRUE)
})

test_that("cosmetic update_block_popover messages do not notify", {
  capture <- local_input_message_session(ns = function(id) paste0("module-", id))

  update_block_popover(capture$session, "details", class = "custom")

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-popover-module-details")
  expect_identical(message$payload$class, NULL)
  expect_identical(message$payload$contentClass, "custom")
  expect_identical(message$payload$notify, FALSE)
})

test_that("update_block_popover clears clearable fields", {
  capture <- local_input_message_session()

  update_block_popover(
    capture$session,
    "details",
    body = NULL,
    style = NULL,
    class = NULL
  )

  message <- capture$last_payload()
  expect_true("bodyHtml" %in% names(message))
  expect_true("contentStyle" %in% names(message))
  expect_true("contentClass" %in% names(message))
  expect_null(message$bodyHtml)
  expect_null(message$contentStyle)
  expect_null(message$contentClass)
})

test_that("update_block_popover validates session and enums", {
  capture <- local_input_message_session()

  expect_error(update_block_popover(NULL, "details"), "session")
  expect_error(update_block_popover(capture$session, "details", side = "diagonal"), "one of")
  expect_error(update_block_popover(capture$session, "details", align = "weird"), "one of")
})

test_that("block_dialog forwards hide_title to props", {
  payload <- runtime_payload_from(
    block_dialog(id = "x", title = "Hidden", hide_title = TRUE)
  )
  expect_identical(payload$props$hideTitle, TRUE)
})

test_that("block_dialog defaults to size = 'default' and forwards size + footer", {
  default_payload <- runtime_payload_from(
    block_dialog(id = "x", title = "T")
  )
  expect_identical(default_payload$props$size, "default")
  expect_null(default_payload$props$footerHtml)

  sized_payload <- runtime_payload_from(
    block_dialog(
      id = "x",
      title = "T",
      size = "lg",
      footer = htmltools::tags$span("Action")
    )
  )
  expect_identical(sized_payload$props$size, "lg")
  expect_match(sized_payload$props$footerHtml, "Action", fixed = TRUE)
})

test_that("block_dialog rejects unknown size values", {
  expect_error(
    block_dialog(id = "x", title = "T", size = "huge"),
    "must be one of"
  )
})

test_that("update_block_dialog forwards size and footer", {
  capture <- local_input_message_session()

  update_block_dialog(
    capture$session,
    "confirm",
    size = "xl",
    footer = htmltools::tags$button("OK")
  )

  message <- capture$last_payload()
  expect_identical(message$size, "xl")
  expect_match(message$footerHtml, "OK", fixed = TRUE)
  expect_identical(message$notify, FALSE)
})

test_that("update_block_dialog forwards class and style", {
  capture <- local_input_message_session()

  update_block_dialog(
    capture$session,
    "confirm",
    class = "custom-dialog",
    style = "border: 2px dashed red;"
  )

  message <- capture$last_payload()
  expect_identical(message$class, "custom-dialog")
  expect_identical(message$style$border, "2px dashed red")
  expect_identical(message$notify, FALSE)
})

test_that("update_block_dialog clears footer when passed NULL", {
  capture <- local_input_message_session()

  update_block_dialog(capture$session, "confirm", footer = NULL)
  message <- capture$last_payload()
  expect_true("footerHtml" %in% names(message))
  expect_null(message$footerHtml)
})

test_that("update_block_dialog rejects invalid size values", {
  capture <- local_input_message_session()
  expect_error(
    update_block_dialog(capture$session, "confirm", size = "huge"),
    "size"
  )
})

test_that("block_toaster emits a runtime payload with input id and position", {
  payload <- runtime_payload_from(
    block_toaster(
      "notes",
      position = "top-center",
      class = "custom-toaster",
      style = "z-index: 200;"
    )
  )

  expect_identical(payload$component, "toaster")
  expect_identical(payload$id, "notes")
  expect_identical(payload$props$position, "top-center")
  expect_identical(payload$binding$input, TRUE)
  expect_identical(payload$binding$type, "shinyblocks.toaster")
  expect_identical(payload$className, "custom-toaster")
})

test_that("block_toaster defaults to bottom-right and validates inputs", {
  payload <- runtime_payload_from(block_toaster("notes"))
  expect_identical(payload$props$position, "bottom-right")

  expect_error(block_toaster(), "`id` is required", fixed = TRUE)
  expect_error(block_toaster("notes", position = "middle"))
  expect_error(block_toaster(123))
})

test_that("show_toast sends an add message and returns the toast id", {
  capture <- local_input_message_session()

  id <- show_toast(
    capture$session,
    "notes",
    title = "Saved",
    description = "Your changes are safe.",
    variant = "success",
    duration = 4000,
    id = "toast-1"
  )

  expect_identical(id, "toast-1")

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-toaster-notes")

  toast <- message$payload$toast
  expect_identical(message$payload$action, "add")
  expect_identical(message$payload$notify, TRUE)
  expect_identical(toast$id, "toast-1")
  expect_identical(toast$variant, "success")
  expect_identical(toast$duration, 4000)
  expect_true(toast$dismissible)
  expect_match(toast$titleHtml, "Saved", fixed = TRUE)
  expect_match(toast$descriptionHtml, "safe", fixed = TRUE)
  expect_false(is.null(toast$iconHtml))
})

test_that("show_toast auto-generates monotonic ids when none supplied", {
  capture <- local_input_message_session()

  first <- show_toast(capture$session, "notes", title = "One")
  second <- show_toast(capture$session, "notes", title = "Two")

  expect_match(first, "^sb-toast-[0-9]+$")
  expect_match(second, "^sb-toast-[0-9]+$")
  expect_false(identical(first, second))
})

test_that("show_toast can drop the icon and keep toasts until dismissed", {
  capture <- local_input_message_session()

  show_toast(
    capture$session,
    "notes",
    title = "Sticky",
    icon = NULL,
    duration = 0
  )

  toast <- capture$last_payload()$toast
  expect_null(toast$iconHtml)
  expect_identical(toast$duration, 0)
})

test_that("show_toast validates title, variant, duration, dismissible, and id", {
  capture <- local_input_message_session()

  expect_error(show_toast(capture$session, "notes"), "`title` is required", fixed = TRUE)
  expect_error(
    show_toast(capture$session, "notes", title = "x", variant = "neon")
  )
  expect_error(
    show_toast(capture$session, "notes", title = "x", duration = "soon"),
    "duration"
  )
  expect_error(
    show_toast(capture$session, "notes", title = "x", duration = Inf),
    "finite"
  )
  expect_error(
    show_toast(capture$session, "notes", title = "x", dismissible = NA),
    "`dismissible` must be `TRUE` or `FALSE`",
    fixed = TRUE
  )
  expect_error(
    show_toast(capture$session, "notes", title = "x", dismissible = "false"),
    "`dismissible` must be `TRUE` or `FALSE`",
    fixed = TRUE
  )
  expect_error(
    show_toast(capture$session, "notes", title = "x", id = c("a", "b")),
    "`id` must be a non-empty string",
    fixed = TRUE
  )
  expect_error(
    show_toast(capture$session, "notes", title = "x", id = ""),
    "`id` must be a non-empty string",
    fixed = TRUE
  )
  expect_error(show_toast(capture$session, title = "x"), "`toaster_id` is required", fixed = TRUE)
})

test_that("dismiss_toast targets a single toast or clears all", {
  capture <- local_input_message_session()

  dismiss_toast(capture$session, "notes", "toast-1")
  one <- capture$last_payload()
  expect_identical(one$action, "dismiss")
  expect_identical(one$toastId, "toast-1")
  expect_identical(one$notify, TRUE)

  dismiss_toast(capture$session, "notes")
  all <- capture$last_payload()
  expect_identical(all$action, "dismiss")
  expect_null(all$toastId)
})

test_that("dismiss_toast requires a toaster id", {
  capture <- local_input_message_session()
  expect_error(dismiss_toast(capture$session), "`toaster_id` is required", fixed = TRUE)
})

test_that("dismiss_toast validates toast ids", {
  capture <- local_input_message_session()

  expect_error(
    dismiss_toast(capture$session, "notes", c("toast-1", "toast-2")),
    "`toast_id` must be a non-empty string",
    fixed = TRUE
  )
  expect_error(
    dismiss_toast(capture$session, "notes", ""),
    "`toast_id` must be a non-empty string",
    fixed = TRUE
  )
})

test_that("update_block_toaster sends a config message with the new position", {
  capture <- local_input_message_session()

  update_block_toaster(capture$session, "notes", position = "top-center")
  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-toaster-notes")
  expect_identical(message$payload$action, "config")
  expect_identical(message$payload$position, "top-center")
})

test_that("update_block_toaster validates position and requires a toaster id", {
  capture <- local_input_message_session()

  expect_error(
    update_block_toaster(capture$session, "notes", position = "middle")
  )
  expect_error(
    update_block_toaster(capture$session),
    "`toaster_id` is required",
    fixed = TRUE
  )
})

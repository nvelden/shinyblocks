# block_progress() — R API + payload (Slice 1)

test_that("block_progress emits a progress runtime payload with defaults", {
  bar <- block_progress("job")
  payload <- runtime_payload_from(bar)

  expect_identical(payload$component, "progress")
  expect_identical(payload$id, "job")
  expect_equal(payload$state$value, 0)
  expect_equal(payload$state$min, 0)
  expect_equal(payload$state$max, 1)
  expect_false(payload$state$indeterminate)
  expect_identical(payload$props$variant, "default")
  expect_false(payload$props$showValue)
  expect_true(payload$binding$input)
  expect_identical(payload$binding$type, "shinyblocks.progress")
  # Omitted text fields stay absent so the runtime renders nothing.
  expect_null(payload$props$message)
  expect_null(payload$props$detail)
  expect_null(payload$props$label)
})

test_that("block_progress carries text fields, variant, and class/style", {
  bar <- block_progress(
    "job",
    value = 0.6,
    message = "Importing rows...",
    detail = "12 of 20",
    label = "Upload",
    show_value = TRUE,
    variant = "success",
    class = "extra",
    style = "margin-top:4px;"
  )
  payload <- runtime_payload_from(bar)

  expect_identical(payload$props$message, "Importing rows...")
  expect_identical(payload$props$detail, "12 of 20")
  expect_identical(payload$props$label, "Upload")
  expect_true(payload$props$showValue)
  expect_identical(payload$props$variant, "success")
  expect_equal(payload$state$value, 0.6)
  expect_match(render_html(bar), "sb-progress")
  expect_match(render_html(bar), "extra")
})

test_that("block_progress clamps value into [min, max]", {
  expect_equal(runtime_payload_from(block_progress("j", value = 5))$state$value, 1)
  expect_equal(runtime_payload_from(block_progress("j", value = -5))$state$value, 0)
  expect_equal(
    runtime_payload_from(block_progress("j", value = 50, min = 0, max = 100))$state$value,
    50
  )
})

test_that("block_progress applies width to the mount style", {
  html <- render_html(block_progress("job", width = 240))
  expect_match(html, "width:240px", fixed = TRUE)
})

test_that("block_progress merges width and a user style string on the mount div", {
  html <- render_html(block_progress("job", width = 240, style = "margin-top:4px"))
  expect_match(html, 'style="width:240px;margin-top:4px;"', fixed = TRUE)
})

test_that("block_progress accepts a named list style using CSS property names", {
  # List keys are CSS property names (kebab-case), not React camelCase.
  html <- render_html(block_progress("job", style = list("margin-top" = "4px")))
  expect_match(html, "margin-top:4px;", fixed = TRUE)
})

test_that("block_progress rejects an empty id", {
  expect_error(block_progress(""), "non-empty")
})

test_that("block_progress validates numerics: finite scalars and min < max", {
  expect_error(block_progress("j", value = Inf), "finite scalar")
  expect_error(block_progress("j", min = NA_real_), "finite scalar")
  expect_error(block_progress("j", max = c(1, 2)), "finite scalar")
  expect_error(block_progress("j", min = 1, max = 1), "`min` must be less than `max`")
  expect_error(block_progress("j", min = 2, max = 1), "`min` must be less than `max`")
})

test_that("block_progress rejects bad variant and non-scalar logicals", {
  expect_error(block_progress("j", variant = "nope"), "must be one of")
  expect_error(block_progress("j", show_value = c(TRUE, FALSE)), "single TRUE or FALSE")
  expect_error(block_progress("j", indeterminate = NA), "single TRUE or FALSE")
})

test_that("block_progress rejects non-string text fields", {
  expect_error(block_progress("j", message = 1), "single string")
  expect_error(block_progress("j", detail = c("a", "b")), "single string")
})

test_that("update_block_progress sends only supplied fields to the namespaced target", {
  mock <- local_input_message_session(ns = function(x) paste0("mod-", x))
  update_block_progress(mock$session, "job", value = 0.5, message = "Working")

  msg <- mock$last_message()
  expect_identical(msg$input_id, "sb-runtime-progress-mod-job")
  expect_identical(msg$payload$value, 0.5)
  expect_identical(msg$payload$message, "Working")
  # Untouched fields are absent from the payload (preserve client state).
  expect_false("detail" %in% names(msg$payload))
  expect_false("min" %in% names(msg$payload))
  expect_false("variant" %in% names(msg$payload))
})

test_that("update_block_progress distinguishes omitted (preserve) from NULL (clear)", {
  mock <- local_input_message_session()
  update_block_progress(mock$session, "job", message = NULL, detail = NULL)

  payload <- mock$last_payload()
  expect_true("message" %in% names(payload))
  expect_null(payload$message)
  expect_true("detail" %in% names(payload))
  expect_null(payload$detail)
})

test_that("update_block_progress errors on NULL numeric fields", {
  mock <- local_input_message_session()
  expect_error(
    update_block_progress(mock$session, "job", value = NULL),
    "cannot be NULL"
  )
  expect_error(
    update_block_progress(mock$session, "job", min = NULL),
    "cannot be NULL"
  )
})

test_that("update_block_progress validates min < max when both supplied", {
  mock <- local_input_message_session()
  expect_error(
    update_block_progress(mock$session, "job", min = 5, max = 1),
    "`min` must be less than `max`"
  )
})

test_that("update_block_progress carries logical and variant fields", {
  mock <- local_input_message_session()
  update_block_progress(
    mock$session, "job",
    show_value = TRUE, indeterminate = TRUE, variant = "warning"
  )

  payload <- mock$last_payload()
  expect_true(payload$showValue)
  expect_true(payload$indeterminate)
  expect_identical(payload$variant, "warning")
})

test_that("inc_block_progress defaults amount to 0.1 and accepts negatives", {
  mock <- local_input_message_session()

  inc_block_progress(mock$session, "job")
  payload <- mock$last_payload()
  expect_identical(payload$action, "increment")
  expect_identical(payload$amount, 0.1)

  inc_block_progress(mock$session, "job", amount = -0.25, message = "Rolling back")
  payload <- mock$last_payload()
  expect_identical(payload$amount, -0.25)
  expect_identical(payload$message, "Rolling back")
})

test_that("inc_block_progress rejects non-finite amount", {
  mock <- local_input_message_session()
  expect_error(inc_block_progress(mock$session, "job", amount = Inf), "finite scalar")
})

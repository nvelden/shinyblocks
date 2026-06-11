# block_date_picker() — R API + payload (Slice 1)

test_that("block_date_picker emits a date-picker runtime payload", {
  picker <- block_date_picker("dob", value = "2026-06-10")
  payload <- runtime_payload_from(picker)

  expect_identical(payload$component, "date-picker")
  expect_identical(payload$id, "dob")
  expect_identical(payload$state$value, "2026-06-10")
  expect_true(payload$binding$input)
  expect_identical(payload$binding$type, "shinyblocks.date-picker")
  expect_identical(payload$props$placeholder, "Pick a date")
  expect_identical(payload$props$format, "yyyy-mm-dd")
  expect_identical(payload$props$weekstart, 0L)
  expect_false(payload$props$disabled)
  expect_false(payload$props$invalid)
})

test_that("block_date_picker renders a hidden ISO native text input", {
  html <- render_html(block_date_picker("dob", value = "2026-06-10"))

  expect_match(html, 'data-sb-component="date-picker"', fixed = TRUE)
  expect_match(html, 'id="dob"', fixed = TRUE)
  expect_match(html, 'class="sb-date-picker-native"', fixed = TRUE)
  expect_match(html, 'type="text"', fixed = TRUE)
  expect_match(html, 'value="2026-06-10"', fixed = TRUE)
})

test_that("block_date_picker starts empty when value is NULL", {
  picker <- block_date_picker("dob")
  payload <- runtime_payload_from(picker)

  expect_identical(payload$state$value, "")
  expect_match(render_html(picker), 'class="sb-date-picker-native"', fixed = TRUE)
})

test_that("block_date_picker normalizes Date and POSIX values to ISO", {
  from_date <- runtime_payload_from(
    block_date_picker("d", value = as.Date("2026-06-10"))
  )
  from_posix <- runtime_payload_from(
    block_date_picker("d", value = as.POSIXct("2026-06-10 13:45:00", tz = "UTC"))
  )

  expect_identical(from_date$state$value, "2026-06-10")
  expect_identical(from_posix$state$value, "2026-06-10")
})

test_that("block_date_picker carries normalized min/max bounds", {
  payload <- runtime_payload_from(
    block_date_picker(
      "d",
      value = "2026-06-10",
      min = as.Date("2026-01-01"),
      max = "2026-12-31"
    )
  )

  expect_identical(payload$props$min, "2026-01-01")
  expect_identical(payload$props$max, "2026-12-31")
})

test_that("block_date_picker rejects invalid date strings", {
  expect_error(block_date_picker("d", value = "not-a-date"), "valid `yyyy-mm-dd`")
  expect_error(block_date_picker("d", value = "2026-02-30"), "valid `yyyy-mm-dd`")
})

test_that("block_date_picker enforces min <= max", {
  expect_error(
    block_date_picker("d", min = "2026-12-31", max = "2026-01-01"),
    "`min` must not be after `max`"
  )
})

test_that("block_date_picker rejects out-of-bounds value", {
  expect_error(
    block_date_picker("d", value = "2025-12-31", min = "2026-01-01"),
    "before `min`"
  )
  expect_error(
    block_date_picker("d", value = "2027-01-01", max = "2026-12-31"),
    "after `max`"
  )
})

test_that("block_date_picker validates weekstart", {
  expect_error(block_date_picker("d", weekstart = 7), "between 0")
  expect_error(block_date_picker("d", weekstart = -1), "between 0")
  expect_error(block_date_picker("d", weekstart = 1.5), "between 0")

  payload <- runtime_payload_from(block_date_picker("d", weekstart = 1))
  expect_identical(payload$props$weekstart, 1L)
})

test_that("block_date_picker carries disabled, invalid, and width", {
  picker <- block_date_picker(
    "d",
    disabled = TRUE,
    invalid = TRUE,
    width = "12rem"
  )
  payload <- runtime_payload_from(picker)

  expect_true(payload$props$disabled)
  expect_true(payload$props$invalid)
  expect_match(render_html(picker), "width:12rem;", fixed = TRUE)
})

test_that("date-picker is a registered runtime component", {
  expect_true("date-picker" %in% local_internal()$RUNTIME_COMPONENT_NAMES)
})

# update_block_date_picker() ------------------------------------------------

test_that("update_block_date_picker sends a normalized value with notify", {
  cap <- local_input_message_session()
  update_block_date_picker(cap$session, "dob", value = as.Date("2026-06-10"))

  msg <- cap$last_message()
  expect_identical(msg$input_id, "sb-runtime-date-picker-dob")
  expect_identical(msg$payload$value, "2026-06-10")
  expect_true(msg$payload$notify)
})

test_that("update_block_date_picker clear sends an explicit empty value", {
  cap <- local_input_message_session()
  update_block_date_picker(cap$session, "dob", value = "2026-06-10", clear = TRUE)

  payload <- cap$last_payload()
  expect_identical(payload$value, "")
  expect_true(payload$notify)
})

test_that("update_block_date_picker leaves value untouched when omitted", {
  cap <- local_input_message_session()
  update_block_date_picker(cap$session, "dob", disabled = TRUE)

  payload <- cap$last_payload()
  expect_false("value" %in% names(payload))
  expect_true(payload$disabled)
})

test_that("update_block_date_picker can clear min/max bounds", {
  cap <- local_input_message_session()
  update_block_date_picker(cap$session, "dob", min = NULL, max = "2026-12-31")

  payload <- cap$last_payload()
  expect_true("min" %in% names(payload))
  expect_null(payload$min)
  expect_identical(payload$max, "2026-12-31")
})

test_that("update_block_date_picker suppresses notify for cosmetic-only updates", {
  cap <- local_input_message_session()
  update_block_date_picker(cap$session, "dob", value = "2026-06-10", notify = FALSE)

  expect_false(cap$last_payload()$notify)
})

test_that("update_block_date_picker rejects invalid replacement dates", {
  cap <- local_input_message_session()
  expect_error(
    update_block_date_picker(cap$session, "dob", value = "nope"),
    "valid `yyyy-mm-dd`"
  )
})

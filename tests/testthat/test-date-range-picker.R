# block_date_range_picker() — R API + payload (Slice 1)

test_that("block_date_range_picker emits a date-range-picker runtime payload", {
  picker <- block_date_range_picker("stay", start = "2026-06-01", end = "2026-06-07")
  payload <- runtime_payload_from(picker)

  expect_identical(payload$component, "date-range-picker")
  expect_identical(payload$id, "stay")
  expect_identical(payload$state$start, "2026-06-01")
  expect_identical(payload$state$end, "2026-06-07")
  expect_true(payload$binding$input)
  expect_identical(payload$binding$type, "shinyblocks.date-range-picker")
  expect_identical(payload$props$placeholder, "Pick a date range")
  expect_identical(payload$props$separator, eval(formals(block_date_range_picker)$separator))
  expect_identical(payload$props$format, "yyyy-mm-dd")
  expect_identical(payload$props$weekstart, 0L)
  expect_false(payload$props$disabled)
  expect_false(payload$props$invalid)
})

test_that("block_date_range_picker renders a hidden delimited ISO native input", {
  html <- render_html(
    block_date_range_picker("stay", start = "2026-06-01", end = "2026-06-07")
  )

  expect_match(html, 'data-sb-component="date-range-picker"', fixed = TRUE)
  expect_match(html, 'id="stay"', fixed = TRUE)
  expect_match(html, 'class="sb-date-range-picker-native"', fixed = TRUE)
  expect_match(html, 'type="text"', fixed = TRUE)
  expect_match(html, 'value="2026-06-01/2026-06-07"', fixed = TRUE)
})

test_that("block_date_range_picker starts empty when start and end are NULL", {
  picker <- block_date_range_picker("stay")
  payload <- runtime_payload_from(picker)

  expect_identical(payload$state$start, "")
  expect_identical(payload$state$end, "")
  expect_match(render_html(picker), 'value=""', fixed = TRUE)
})

test_that("block_date_range_picker rejects a single endpoint at construction", {
  expect_error(
    block_date_range_picker("stay", start = "2026-06-01"),
    "both `start` and `end`"
  )
  expect_error(
    block_date_range_picker("stay", end = "2026-06-07"),
    "both `start` and `end`"
  )
})

test_that("block_date_range_picker normalizes Date and POSIX endpoints to ISO", {
  payload <- runtime_payload_from(
    block_date_range_picker(
      "stay",
      start = as.Date("2026-06-01"),
      end = as.POSIXct("2026-06-07 13:45:00", tz = "UTC")
    )
  )

  expect_identical(payload$state$start, "2026-06-01")
  expect_identical(payload$state$end, "2026-06-07")
})

test_that("block_date_range_picker swaps a reversed start/end", {
  payload <- runtime_payload_from(
    block_date_range_picker("stay", start = "2026-06-07", end = "2026-06-01")
  )

  expect_identical(payload$state$start, "2026-06-01")
  expect_identical(payload$state$end, "2026-06-07")
})

test_that("block_date_range_picker carries normalized min/max bounds", {
  payload <- runtime_payload_from(
    block_date_range_picker(
      "stay",
      start = "2026-06-01",
      end = "2026-06-07",
      min = as.Date("2026-01-01"),
      max = "2026-12-31"
    )
  )

  expect_identical(payload$props$min, "2026-01-01")
  expect_identical(payload$props$max, "2026-12-31")
})

test_that("block_date_range_picker enforces min <= max", {
  expect_error(
    block_date_range_picker("stay", min = "2026-12-31", max = "2026-01-01"),
    "`min` must not be after `max`"
  )
})

test_that("block_date_range_picker rejects out-of-bounds endpoints", {
  expect_error(
    block_date_range_picker(
      "stay", start = "2025-12-31", end = "2026-06-07", min = "2026-01-01"
    ),
    "`start` must not be before `min`"
  )
  expect_error(
    block_date_range_picker(
      "stay", start = "2026-06-01", end = "2027-01-01", max = "2026-12-31"
    ),
    "`end` must not be after `max`"
  )
})

test_that("block_date_range_picker rejects invalid date strings", {
  expect_error(
    block_date_range_picker("stay", start = "nope", end = "2026-06-07"),
    "valid `yyyy-mm-dd`"
  )
})

test_that("block_date_range_picker validates weekstart", {
  expect_error(block_date_range_picker("stay", weekstart = 7), "between 0")

  payload <- runtime_payload_from(block_date_range_picker("stay", weekstart = 1))
  expect_identical(payload$props$weekstart, 1L)
})

test_that("block_date_range_picker carries disabled, invalid, and width", {
  picker <- block_date_range_picker(
    "stay",
    disabled = TRUE,
    invalid = TRUE,
    width = "16rem"
  )
  payload <- runtime_payload_from(picker)

  expect_true(payload$props$disabled)
  expect_true(payload$props$invalid)
  expect_match(render_html(picker), "width:16rem;", fixed = TRUE)
})

test_that("date-range-picker is a registered runtime component", {
  expect_true("date-range-picker" %in% local_internal()$RUNTIME_COMPONENT_NAMES)
})

# update_block_date_range_picker() ------------------------------------------

test_that("update_block_date_range_picker sends a normalized range with notify", {
  cap <- local_input_message_session()
  update_block_date_range_picker(
    cap$session, "stay",
    start = as.Date("2026-06-01"), end = "2026-06-07"
  )

  msg <- cap$last_message()
  expect_identical(msg$input_id, "sb-runtime-date-range-picker-stay")
  expect_identical(msg$payload$start, "2026-06-01")
  expect_identical(msg$payload$end, "2026-06-07")
  expect_true(msg$payload$notify)
})

test_that("update_block_date_range_picker can update one endpoint", {
  cap <- local_input_message_session()
  update_block_date_range_picker(cap$session, "stay", end = "2026-06-09")

  payload <- cap$last_payload()
  expect_false("start" %in% names(payload))
  expect_identical(payload$end, "2026-06-09")
  expect_true(payload$notify)
})

test_that("update_block_date_range_picker clear sends an explicit empty range", {
  cap <- local_input_message_session()
  update_block_date_range_picker(
    cap$session, "stay",
    start = "2026-06-01", end = "2026-06-07", clear = TRUE
  )

  payload <- cap$last_payload()
  expect_identical(payload$start, "")
  expect_identical(payload$end, "")
  expect_true(payload$notify)
})

test_that("update_block_date_range_picker leaves range untouched when omitted", {
  cap <- local_input_message_session()
  update_block_date_range_picker(cap$session, "stay", disabled = TRUE)

  payload <- cap$last_payload()
  expect_false("start" %in% names(payload))
  expect_false("end" %in% names(payload))
  expect_true(payload$disabled)
  expect_false(payload$notify)
})

test_that("update_block_date_range_picker can clear min/max bounds", {
  cap <- local_input_message_session()
  update_block_date_range_picker(cap$session, "stay", min = NULL, max = "2026-12-31")

  payload <- cap$last_payload()
  expect_true("min" %in% names(payload))
  expect_null(payload$min)
  expect_identical(payload$max, "2026-12-31")
})

test_that("update_block_date_range_picker suppresses notify when asked", {
  cap <- local_input_message_session()
  update_block_date_range_picker(
    cap$session, "stay",
    start = "2026-06-01", end = "2026-06-07", notify = FALSE
  )

  expect_false(cap$last_payload()$notify)
})

test_that("update_block_date_range_picker rejects invalid replacement dates", {
  cap <- local_input_message_session()
  expect_error(
    update_block_date_range_picker(cap$session, "stay", start = "nope"),
    "valid `yyyy-mm-dd`"
  )
})

test_that("update_block_date_range_picker enforces min <= max in the same call", {
  cap <- local_input_message_session()
  expect_error(
    update_block_date_range_picker(
      cap$session, "stay", min = "2026-12-31", max = "2026-01-01"
    ),
    "`min` must not be after `max`."
  )
})

test_that("update_block_date_range_picker rejects an endpoint outside supplied bounds", {
  cap <- local_input_message_session()
  expect_error(
    update_block_date_range_picker(
      cap$session, "stay", start = "2027-01-01", max = "2026-12-31"
    ),
    "`start` must not be after `max`."
  )
  expect_error(
    update_block_date_range_picker(
      cap$session, "stay", end = "2025-01-01", min = "2026-01-01"
    ),
    "`end` must not be before `min`."
  )
})

test_that("update_block_date_range_picker swaps a reversed start/end", {
  cap <- local_input_message_session()
  update_block_date_range_picker(
    cap$session, "stay", start = "2026-06-07", end = "2026-06-01"
  )

  payload <- cap$last_payload()
  expect_identical(payload$start, "2026-06-01")
  expect_identical(payload$end, "2026-06-07")
})

test_that("update_block_date_range_picker rejects vector separator/placeholder", {
  cap <- local_input_message_session()
  expect_error(
    update_block_date_range_picker(cap$session, "stay", separator = c(" - ", " to ")),
    "`separator` must be a single string."
  )
  expect_error(
    update_block_date_range_picker(cap$session, "stay", placeholder = c("a", "b")),
    "`placeholder` must be a single string."
  )
})

# Constructor scalar validation -----------------------------------------------

test_that("block_date_range_picker rejects vector separator/placeholder", {
  expect_error(
    block_date_range_picker("rng", separator = c(" - ", " to ")),
    "`separator` must be a single string."
  )
  expect_error(
    block_date_range_picker("rng", placeholder = c("a", "b")),
    "`placeholder` must be a single string."
  )
})

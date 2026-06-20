test_that("update_block_select maps clearable NULL fields", {
  capture <- local_input_message_session()

  expect_invisible(
    update_block_select(
      capture$session,
      "plan",
      selected = NULL,
      placeholder = NULL,
      class = NULL
    )
  )

  message <- capture$last_payload()
  expect_identical(message$selected, "")
  expect_null(message$placeholder)
  expect_null(message$class)
  expect_identical(message$notify, TRUE)
})

test_that("cosmetic update_block_select messages do not notify", {
  capture <- local_input_message_session(ns = function(id) paste0("module-", id))

  update_block_select(capture$session, "plan", width = "12rem")

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-select-module-plan")
  expect_identical(message$payload$width, "12rem")
  expect_identical(message$payload$notify, FALSE)
})

test_that("update_block_select validates selected replacement choices", {
  capture <- local_input_message_session()
  session <- capture$session

  expect_error(
    update_block_select(
      session,
      "plan",
      selected = "team",
      choices = c(Free = "free", Pro = "pro")
    ),
    "`selected` must match one of `choices`"
  )
})

test_that("update_block_select sends vector selections", {
  capture <- local_input_message_session()

  update_block_select(
    capture$session,
    "plan",
    selected = c("free", "team"),
    choices = c(Free = "free", Pro = "pro", Team = "team")
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-select-plan")
  expect_identical(message$payload$selected, c("free", "team"))
  expect_identical(message$payload$notify, TRUE)
})

test_that("update_block_select can clear multiple selections", {
  capture <- local_input_message_session()

  update_block_select(capture$session, "plan", selected = character(0))

  message <- capture$last_payload()
  expect_identical(message$selected, character(0))
  expect_identical(message$notify, TRUE)
})

test_that("update_block_select rejects missing selected values", {
  capture <- local_input_message_session()

  expect_error(
    update_block_select(capture$session, "plan", selected = NA_character_),
    "`selected` must not contain missing values"
  )
})

test_that("block_textarea validates rows", {
  expect_error(
    block_textarea("notes", rows = 0),
    "`rows` must be a positive number"
  )
})

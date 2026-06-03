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

  expect_snapshot(error = TRUE, {
    update_block_select(
      session,
      "plan",
      selected = "team",
      choices = c(Free = "free", Pro = "pro")
    )
  })
})

test_that("block_textarea validates rows", {
  expect_snapshot(error = TRUE, {
    block_textarea("notes", rows = 0)
  })
})

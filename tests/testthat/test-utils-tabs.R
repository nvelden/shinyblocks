test_that("update_block_tabs sends a custom message", {
  capture <- local_custom_message_session()

  expect_invisible(update_block_tabs(capture$session, "account_tabs", selected = "usage"))
  message <- capture$last_message()

  expect_identical(message$type, "sb:tabs")
  expect_identical(
    message$payload,
    list(id = "account_tabs", selected = "usage", notify = TRUE)
  )
})

test_that("update_block_tabs respects namespaces and notify", {
  capture <- local_custom_message_session()
  capture$session$ns <- function(id) paste0("mod-", id)

  update_block_tabs(
    capture$session,
    "account_tabs",
    selected = "settings",
    notify = FALSE
  )

  expect_identical(
    capture$last_message()$payload,
    list(id = "mod-account_tabs", selected = "settings", notify = FALSE)
  )
})

test_that("update_block_tabs validates inputs", {
  capture <- local_custom_message_session()

  expect_error(
    update_block_tabs(NULL, "account_tabs", selected = "usage"),
    "`session` is required"
  )
  expect_error(
    update_block_tabs(list(), "account_tabs", selected = "usage"),
    "sendCustomMessage"
  )
  expect_error(update_block_tabs(capture$session, "", selected = "usage"), "input_id")
  expect_error(update_block_tabs(capture$session, "account_tabs", selected = ""), "`selected`")
})

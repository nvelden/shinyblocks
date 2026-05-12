test_session <- function() {
  sent <- new.env(parent = emptyenv())
  session <- new.env(parent = emptyenv())
  session$ns <- function(id) paste0("module-", id)
  session$sendCustomMessage <- function(type, message) {
    sent$type <- type
    sent$message <- message
  }

  list(session = session, sent = sent)
}

test_that("runtime_update() sends a namespaced custom message", {
  ns <- local_internal()
  fixture <- test_session()

  ns$runtime_update(
    session = fixture$session,
    input_id = "choice",
    component = "select",
    value = "a"
  )

  expect_identical(fixture$sent$type, "sb:update")
  expect_identical(fixture$sent$message$id, "module-choice")
  expect_identical(fixture$sent$message$component, "select")
  expect_identical(fixture$sent$message$updates$value, "a")
  expect_identical(fixture$sent$message$notify, FALSE)
  expect_type(fixture$sent$message$revision, "integer")
})

test_that("runtime_update() preserves omitted fields and clearable NULL", {
  ns <- local_internal()
  fixture <- test_session()

  ns$runtime_update(
    session = fixture$session,
    input_id = "choice",
    component = "select",
    value = NULL,
    notify = TRUE,
    clearable = "value"
  )

  expect_named(fixture$sent$message$updates, "value")
  expect_null(fixture$sent$message$updates$value)
  expect_identical(fixture$sent$message$notify, TRUE)
})

test_that("runtime_update() rejects non-clearable NULL fields", {
  ns <- local_internal()
  fixture <- test_session()

  expect_snapshot(
    ns$runtime_update(
      session = fixture$session,
      input_id = "choice",
      component = "select",
      value = NULL
    ),
    error = TRUE
  )
})

test_that("runtime_update_message() validates sessions and ids", {
  ns <- local_internal()

  expect_snapshot(
    ns$runtime_update_message(
      session = NULL,
      input_id = "choice",
      component = "select"
    ),
    error = TRUE
  )
  expect_snapshot(
    ns$runtime_update_message(
      session = test_session()$session,
      input_id = "",
      component = "select"
    ),
    error = TRUE
  )
})

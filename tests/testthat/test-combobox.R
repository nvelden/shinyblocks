test_that("block_combobox emits a runtime combobox payload", {
  combobox <- block_combobox(
    "plan",
    choices = c(Free = "free", Pro = "pro"),
    selected = "pro",
    placeholder = "Choose a plan",
    search_placeholder = "Filter plans...",
    empty_message = "No plan found.",
    width = "16rem",
    class = "custom",
    size = "lg",
    style = "margin-top: 1rem;",
    invalid = TRUE
  )
  html <- render_html(combobox)
  payload <- runtime_payload_from(combobox)

  expect_identical(tag_attr(combobox, "class"), "sb-runtime-mount")
  expect_match(html, 'data-sb-component="combobox"', fixed = TRUE)
  expect_match(html, '<select id="plan" class="sb-select-native"', fixed = TRUE)
  expect_match(html, "data-shiny-no-bind-input", fixed = TRUE)
  expect_match(html, '<option value="pro" selected', fixed = TRUE)
  expect_identical(payload$id, "plan")
  expect_identical(payload$state$value, "pro")
  expect_identical(payload$props$choices[[1]]$value, "free")
  expect_identical(payload$props$choices[[2]]$label, "Pro")
  expect_identical(payload$props$placeholder, "Choose a plan")
  expect_identical(payload$props$searchPlaceholder, "Filter plans...")
  expect_identical(payload$props$emptyMessage, "No plan found.")
  expect_identical(payload$props$width, "16rem")
  expect_identical(payload$props$style$marginTop, "1rem")
  expect_identical(payload$props$size, "lg")
  expect_identical(payload$props$invalid, TRUE)
  expect_identical(payload$binding$type, "shinyblocks.combobox")
})

test_that("block_combobox search/empty text default when not supplied", {
  payload <- runtime_payload_from(block_combobox(
    "plan",
    choices = c("Free", "Pro")
  ))
  expect_identical(payload$props$searchPlaceholder, "Search...")
  expect_identical(payload$props$emptyMessage, "No results found.")
})

test_that("block_combobox defaults to first choice unless a placeholder is present", {
  combobox <- runtime_payload_from(block_combobox(
    "plan",
    choices = c("Free", "Pro")
  ))
  placeholder <- runtime_payload_from(
    block_combobox("plan", choices = c("Free", "Pro"), placeholder = "Choose")
  )

  expect_identical(combobox$state$value, "Free")
  expect_identical(placeholder$state$value, "")
})

test_that("block_combobox emits a multiple runtime combobox payload", {
  combobox <- block_combobox(
    "plan",
    choices = c(Free = "free", Pro = "pro", Team = "team"),
    selected = c("free", "team"),
    placeholder = "Choose plans",
    multiple = TRUE,
    max_items = 2
  )
  html <- render_html(combobox)
  payload <- runtime_payload_from(combobox)

  expect_match(html, '<select id="plan" class="sb-select-native"', fixed = TRUE)
  expect_match(html, " multiple", fixed = TRUE)
  expect_match(html, '<option value="free" selected', fixed = TRUE)
  expect_match(html, '<option value="team" selected', fixed = TRUE)
  expect_identical(payload$component, "combobox")
  expect_identical(payload$state$value, list("free", "team"))
  expect_identical(payload$props$multiple, TRUE)
  expect_identical(payload$props$maxItems, 2L)
  expect_identical(payload$binding$type, "shinyblocks.combobox")
})

test_that("block_combobox rejects an unknown selected value", {
  expect_error(
    block_combobox(
      "plan",
      choices = c(Free = "free", Pro = "pro"),
      selected = "z"
    ),
    "must match one of"
  )
})

test_that("block_combobox rejects non-string search/empty text", {
  expect_error(
    block_combobox(
      "plan",
      choices = c("Free", "Pro"),
      search_placeholder = c("a", "b")
    ),
    "search_placeholder"
  )
  expect_error(
    block_combobox("plan", choices = c("Free", "Pro"), empty_message = 1),
    "empty_message"
  )
})

test_that("block_combobox rejects malformed logical flags", {
  expect_snapshot(error = TRUE, {
    block_combobox("plan", c("Free", "Pro"), disabled = "yes")
  })
  expect_snapshot(error = TRUE, {
    block_combobox("plan", c("Free", "Pro"), invalid = NA)
  })
  expect_snapshot(error = TRUE, {
    block_combobox("plan", c("Free", "Pro"), multiple = 1)
  })
})

test_that("update_block_combobox sends input binding messages", {
  capture <- local_input_message_session()

  expect_invisible(
    update_block_combobox(
      capture$session,
      "plan",
      selected = "pro",
      choices = c(Free = "free", Pro = "pro"),
      placeholder = "Choose",
      search_placeholder = "Filter...",
      empty_message = "Nothing here.",
      disabled = TRUE,
      width = "16rem",
      class = "custom-combobox",
      size = "lg",
      invalid = TRUE,
      notify = TRUE
    )
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-combobox-plan")
  expect_identical(message$payload$selected, "pro")
  expect_identical(message$payload$choices[[2]]$label, "Pro")
  expect_identical(message$payload$placeholder, "Choose")
  expect_identical(message$payload$searchPlaceholder, "Filter...")
  expect_identical(message$payload$emptyMessage, "Nothing here.")
  expect_identical(message$payload$disabled, TRUE)
  expect_identical(message$payload$width, "16rem")
  expect_identical(message$payload$class, "custom-combobox")
  expect_identical(message$payload$size, "lg")
  expect_identical(message$payload$invalid, TRUE)
  expect_identical(message$payload$notify, TRUE)
})

test_that("update_block_combobox rejects a selected value outside new choices", {
  capture <- local_input_message_session()
  expect_error(
    update_block_combobox(
      capture$session,
      "plan",
      choices = c(Free = "free", Pro = "pro"),
      selected = "team"
    ),
    "must match one of"
  )
})

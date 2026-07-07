test_that("block_button(id =) emits a runtime input id and shinyblocks.button binding", {
  tag <- block_button("Continue", id = "confirm")
  html <- as.character(htmltools::renderTags(tag)$html)

  expect_match(html, 'data-sb-component="button"', fixed = TRUE)
  expect_match(html, 'data-sb-input-id="confirm"', fixed = TRUE)
  expect_match(html, 'id="sb-runtime-button-confirm"', fixed = TRUE)
  expect_match(html, '"binding":\\{"input":true,"type":"shinyblocks\\.button"\\}')
  # id moved into the runtime mount; it must not leak onto inner attrs
  expect_false(grepl('"attrs":\\{[^}]*"id"', html))
})

test_that("block_button() without id omits binding and input-id markers", {
  tag <- block_button("Continue")
  html <- as.character(htmltools::renderTags(tag)$html)
  expect_false(grepl("data-sb-input-id", html, fixed = TRUE))
  expect_false(grepl("shinyblocks.button", html, fixed = TRUE))
})

test_that("update_block_button sends input binding messages", {
  capture <- local_input_message_session()

  expect_invisible(
    update_block_button(
      capture$session,
      "confirm",
      label = "Save",
      variant = "destructive",
      size = "lg",
      icon = "check",
      icon_position = "inline-end",
      disabled = TRUE,
      style = "min-width: 10rem;",
      class = "custom-button"
    )
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-button-confirm")
  expect_match(message$payload$labelHtml, "Save", fixed = TRUE)
  expect_identical(message$payload$variant, "destructive")
  expect_identical(message$payload$size, "lg")
  expect_identical(message$payload$iconName, "check")
  expect_null(message$payload$iconHtml)
  expect_identical(message$payload$iconPosition, "inline-end")
  expect_identical(message$payload$disabled, TRUE)
  expect_identical(message$payload$style$minWidth, "10rem")
  expect_identical(message$payload$class, "custom-button")
})

test_that("update_block_button clears icon and style via NULL", {
  capture <- local_input_message_session()

  update_block_button(capture$session, "confirm", icon = NULL, style = NULL)

  message <- capture$last_payload()
  expect_true("iconName" %in% names(message))
  expect_null(message$iconName)
  expect_true("iconHtml" %in% names(message))
  expect_null(message$iconHtml)
  expect_true("style" %in% names(message))
  expect_null(message$style)
})

test_that("update_block_*() routes via root session under a module (issue #63)", {
  capture <- local_module_message_session("mod")

  update_block_progress(capture$session, "load", value = 40)

  # The mount-id slug already bakes in the module namespace; routing through the
  # root session must not re-namespace it (no `mod-sb-runtime-...` double prefix).
  expect_identical(capture$last_target(), "sb-runtime-progress-mod-load")
})

test_that("update_block_select sends input binding messages", {
  capture <- local_input_message_session()

  expect_invisible(
    update_block_select(
      capture$session,
      "plan",
      selected = "pro",
      choices = c(Free = "free", Pro = "pro"),
      placeholder = "Choose",
      disabled = TRUE,
      width = "16rem",
      class = "custom-select",
      size = "lg",
      invalid = TRUE,
      notify = TRUE
    )
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-select-plan")
  expect_identical(message$payload$selected, "pro")
  expect_identical(message$payload$choices[[2]]$label, "Pro")
  expect_identical(message$payload$placeholder, "Choose")
  expect_identical(message$payload$disabled, TRUE)
  expect_identical(message$payload$width, "16rem")
  expect_identical(message$payload$class, "custom-select")
  expect_identical(message$payload$size, "lg")
  expect_identical(message$payload$invalid, TRUE)
  expect_identical(message$payload$notify, TRUE)
})

test_that("update_block_checkbox sends input binding messages", {
  capture <- local_input_message_session()

  expect_invisible(
    update_block_checkbox(
      capture$session,
      "agree",
      checked = TRUE,
      disabled = TRUE,
      style = "border: 2px dashed red;",
      class = "custom-checkbox",
      notify = TRUE
    )
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-checkbox-agree")
  expect_identical(message$payload$checked, TRUE)
  expect_identical(message$payload$disabled, TRUE)
  expect_identical(message$payload$style$border, "2px dashed red")
  expect_identical(message$payload$class, "custom-checkbox")
  expect_identical(message$payload$notify, TRUE)
})

test_that("cosmetic update_block_checkbox messages do not notify", {
  capture <- local_input_message_session()

  update_block_checkbox(capture$session, "agree", class = "renamed")
  message <- capture$last_payload()
  expect_identical(message$notify, FALSE)
  expect_null(message$checked)
})

test_that("update_block_switch sends input binding messages", {
  capture <- local_input_message_session()

  expect_invisible(
    update_block_switch(
      capture$session,
      "alerts",
      checked = TRUE,
      disabled = TRUE,
      size = "lg",
      style = "border: 2px dashed red;",
      class = "custom-switch",
      notify = TRUE
    )
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-switch-alerts")
  expect_identical(message$payload$checked, TRUE)
  expect_identical(message$payload$disabled, TRUE)
  expect_identical(message$payload$size, "lg")
  expect_identical(message$payload$style$border, "2px dashed red")
  expect_identical(message$payload$class, "custom-switch")
  expect_identical(message$payload$notify, TRUE)
})

test_that("cosmetic update_block_switch messages do not notify", {
  capture <- local_input_message_session()

  update_block_switch(capture$session, "alerts", class = "renamed")
  message <- capture$last_payload()
  expect_identical(message$notify, FALSE)
  expect_null(message$checked)
})

test_that("update_block_toggle_group sends input binding messages", {
  capture <- local_input_message_session()

  expect_invisible(
    update_block_toggle_group(
      capture$session,
      "view",
      selected = "grid",
      choices = c(List = "list", Grid = "grid"),
      icons = list(grid = "layout-grid"),
      disabled = "list",
      variant = "outline",
      size = "lg",
      class = "custom-toggle",
      notify = TRUE
    )
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-toggle-group-view")
  expect_identical(as.character(message$payload$selected), "grid")
  expect_identical(message$payload$choices[[2]]$label, "Grid")
  expect_identical(message$payload$choices[[2]]$icon, "layout-grid")
  expect_identical(message$payload$disabled, FALSE)
  expect_identical(as.character(message$payload$disabledValues), "list")
  expect_identical(message$payload$variant, "outline")
  expect_identical(message$payload$size, "lg")
  expect_identical(message$payload$class, "custom-toggle")
  expect_identical(message$payload$notify, TRUE)
})

test_that("update_block_toggle_group clears the selection via NULL", {
  capture <- local_input_message_session()

  update_block_toggle_group(capture$session, "view", selected = NULL)
  payload <- capture$last_payload()
  expect_true("selected" %in% names(payload))
  expect_null(payload$selected)
  expect_identical(payload$notify, TRUE)
})

test_that("update_block_toggle_group rejects icons without choices", {
  capture <- local_input_message_session()

  expect_error(
    update_block_toggle_group(
      capture$session, "view", icons = list(a = "list")
    ),
    "`icons` requires `choices`"
  )
})

test_that("cosmetic update_block_toggle_group messages do not notify", {
  capture <- local_input_message_session()

  update_block_toggle_group(capture$session, "view", class = "renamed")
  message <- capture$last_payload()
  expect_identical(message$notify, FALSE)
  expect_null(message$selected)
})

test_that("update_block_slider sends input binding messages", {
  capture <- local_input_message_session()

  expect_invisible(
    update_block_slider(
      capture$session,
      "volume",
      value = c(25, 75),
      min = 0,
      max = 100,
      step = 5,
      orientation = "vertical",
      show_value = TRUE,
      min_label = "Quiet",
      max_label = "Loud",
      disabled = TRUE,
      invalid = TRUE,
      style = "max-width: 20rem;",
      class = "custom-slider",
      notify = TRUE
    )
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-slider-volume")
  expect_identical(message$payload$value, c(25, 75))
  expect_identical(message$payload$min, 0)
  expect_identical(message$payload$max, 100)
  expect_identical(message$payload$step, 5)
  expect_identical(message$payload$orientation, "vertical")
  expect_identical(message$payload$showValue, TRUE)
  expect_identical(message$payload$minLabel, "Quiet")
  expect_identical(message$payload$maxLabel, "Loud")
  expect_identical(message$payload$disabled, TRUE)
  expect_identical(message$payload$invalid, TRUE)
  expect_identical(message$payload$style$maxWidth, "20rem")
  expect_identical(message$payload$class, "custom-slider")
  expect_identical(message$payload$notify, TRUE)
})

test_that("cosmetic update_block_slider messages do not notify", {
  capture <- local_input_message_session()

  update_block_slider(capture$session, "volume", class = "renamed")
  message <- capture$last_payload()
  expect_identical(message$notify, FALSE)
  expect_null(message$value)
})

test_that("update_block_file_input targets the file-input mount and never notifies", {
  capture <- local_input_message_session()

  expect_invisible(
    update_block_file_input(
      capture$session,
      "upload",
      variant = "dropzone",
      button_label = "Choose",
      placeholder = "Pick a file",
      dropzone_label = "Drop it",
      dropzone_hint = "CSV only",
      accept = c(".csv", "text/csv"),
      multiple = TRUE,
      disabled = TRUE,
      invalid = TRUE,
      style = "max-width: 20rem;",
      class = "custom-file",
      reset = TRUE
    )
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-file-input-upload")
  expect_identical(message$payload$variant, "dropzone")
  expect_identical(message$payload$buttonLabel, "Choose")
  expect_identical(message$payload$placeholder, "Pick a file")
  expect_identical(message$payload$dropzoneLabel, "Drop it")
  expect_identical(message$payload$dropzoneHint, "CSV only")
  expect_identical(message$payload$accept, ".csv,text/csv")
  expect_identical(message$payload$multiple, TRUE)
  expect_identical(message$payload$disabled, TRUE)
  expect_identical(message$payload$invalid, TRUE)
  expect_identical(message$payload$style$maxWidth, "20rem")
  expect_identical(message$payload$class, "custom-file")
  expect_identical(message$payload$reset, TRUE)
  # File inputs carry no runtime value, so they never emit a notify flag.
  expect_null(message$payload$notify)
})

test_that("update_block_file_input clears accept and validates it", {
  capture <- local_input_message_session()

  update_block_file_input(capture$session, "upload", accept = NULL)
  expect_true("accept" %in% names(capture$last_payload()))
  expect_null(capture$last_payload()$accept)

  expect_error(
    update_block_file_input(capture$session, "upload", accept = 1),
    "`accept` must be NULL or a character vector"
  )
})

test_that("update_block_file_input sets dropzone icon name and content html", {
  capture <- local_input_message_session()

  update_block_file_input(
    capture$session,
    "upload",
    dropzone_icon = "upload",
    dropzone_content = htmltools::tags$strong("Drop")
  )
  payload <- capture$last_payload()
  expect_identical(payload$dropzoneIconName, "upload")
  expect_null(payload$dropzoneIconHtml)
  expect_true(nzchar(payload$spriteHref))
  expect_match(payload$dropzoneContentHtml, "<strong>Drop</strong>", fixed = TRUE)
})

test_that("update_block_file_input clears dropzone icon and content", {
  capture <- local_input_message_session()

  update_block_file_input(
    capture$session,
    "upload",
    dropzone_icon = NULL,
    dropzone_content = NULL
  )
  payload <- capture$last_payload()
  expect_true("dropzoneIconName" %in% names(payload))
  expect_null(payload$dropzoneIconName)
  expect_true("dropzoneContentHtml" %in% names(payload))
  expect_null(payload$dropzoneContentHtml)
})

test_that("updaters work when called through a dots-forwarding wrapper", {
  capture <- local_input_message_session()

  wrapper <- function(...) update_block_input(capture$session, "txt", ...)
  expect_invisible(wrapper(value = "forwarded", disabled = TRUE))

  message <- capture$last_message()
  expect_identical(message$payload$value, "forwarded")
  expect_identical(message$payload$disabled, TRUE)
  expect_identical(message$payload$notify, TRUE)

  # Two levels of forwarding resolve the dots in the right frame too.
  outer <- function(...) wrapper(...)
  expect_invisible(outer(placeholder = "deep"))
  expect_identical(capture$last_message()$payload$placeholder, "deep")
})

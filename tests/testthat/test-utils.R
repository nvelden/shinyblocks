test_that("merge_classes deduplicates class names", {
  ns <- local_internal()

  expect_identical(
    ns$merge_classes("sb-header custom", "custom", NULL, ""),
    "sb-header custom"
  )
  expect_null(ns$merge_classes(NULL, ""))
})

test_that("match_arg reports allowed values", {
  ns <- local_internal()

  expect_identical(
    ns$match_arg("light", c("system", "light", "dark"), "theme_mode"),
    "light"
  )

  expect_snapshot(error = TRUE, {
    ns$match_arg("auto", c("system", "light", "dark"), "theme_mode")
  })
})

test_that("validate_children accepts only tagged child items", {
  ns <- local_internal()
  item <- htmltools::tags$div(`data-sb-child` = "nav-item")
  invalid <- htmltools::tags$div()

  expect_invisible(ns$validate_children(list(item), "nav-item", "block_nav"))

  expect_snapshot(error = TRUE, {
    ns$validate_children(list(invalid), "nav-item", "block_nav")
  })
})

test_that("validate_icon_name reports unknown icons", {
  ns <- local_internal()

  expect_snapshot(error = TRUE, {
    ns$validate_icon_name("not-an-icon")
  })
})

test_that("block_button validates variant and size", {
  expect_snapshot(error = TRUE, {
    block_button("Save", variant = "primary")
  })

  expect_snapshot(error = TRUE, {
    block_button("Save", size = "xl")
  })
})

test_that("block_switch validates size", {
  expect_snapshot(error = TRUE, {
    block_switch("alerts", "Alerts", size = "xl")
  })
})

test_that("block_badge validates variant", {
  expect_snapshot(error = TRUE, {
    block_badge("New", variant = "primary")
  })
})

test_that("block_alert validates required title and variant", {
  expect_snapshot(error = TRUE, {
    block_alert(NULL)
  })

  expect_snapshot(error = TRUE, {
    block_alert("Notice", variant = "urgent")
  })
})

test_that("block_value_box validates variant", {
  expect_snapshot(error = TRUE, {
    block_value_box("Revenue", "$42k", variant = "success")
  })
})

test_that("block_separator validates orientation", {
  expect_snapshot(error = TRUE, {
    block_separator(orientation = "diagonal")
  })
})

test_that("block_nav validates child types", {
  expect_snapshot(error = TRUE, {
    block_nav(htmltools::tags$div("Bad child"))
  })
})

test_that("block_field_invalid validates field input", {
  expect_snapshot(error = TRUE, {
    block_field_invalid(htmltools::tags$div("Bad field"), "Nope")
  })
})

test_that("block_select validates choices and selected value", {
  expect_snapshot(error = TRUE, {
    block_select("plan", choices = character())
  })

  expect_snapshot(error = TRUE, {
    block_select("plan", choices = c("Free", "Pro"), selected = "Team")
  })

  expect_snapshot(error = TRUE, {
    block_select("plan", choices = c("Free", "Pro"), size = "xl")
  })

  expect_error(
    block_select("plan", choices = c(None = "", Free = "free")),
    "placeholder sentinel"
  )

  expect_error(
    block_select("plan", choices = c(Free = "free", AlsoFree = "free")),
    "must be unique"
  )
})

test_that("validate_select_choice_values rejects invalid values", {
  expect_error(
    validate_select_choice_values(c("free", "")),
    "placeholder sentinel"
  )
  expect_error(
    validate_select_choice_values(c("free", "pro", "free")),
    "must be unique"
  )
  expect_invisible(validate_select_choice_values(c("free", "pro")))
})

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

test_that("update_block_dialog sends input binding messages", {
  capture <- local_input_message_session()

  expect_invisible(
    update_block_dialog(
      capture$session,
      "confirm",
      open = TRUE,
      title = "New title",
      description = "Updated copy.",
      notify = TRUE
    )
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-dialog-confirm")
  expect_identical(message$payload$open, TRUE)
  expect_match(message$payload$titleHtml, "New title", fixed = TRUE)
  expect_match(message$payload$descriptionHtml, "Updated copy.", fixed = TRUE)
  expect_identical(message$payload$notify, TRUE)
})

test_that("cosmetic update_block_dialog messages do not notify", {
  capture <- local_input_message_session()

  update_block_dialog(capture$session, "confirm", title = "Renamed")
  message <- capture$last_payload()
  expect_identical(message$notify, FALSE)
  expect_match(message$titleHtml, "Renamed", fixed = TRUE)
  expect_null(message$open)
})

test_that("update_block_dialog requires a session with the right hooks", {
  expect_error(update_block_dialog(NULL, "confirm"), "session")
  expect_error(
    update_block_dialog(list(), "confirm"),
    "ns"
  )
})

test_that("block_dialog emits a runtime payload with input id and open state", {
  payload <- runtime_payload_from(
    block_dialog(
      id = "confirm",
      title = "Are you sure?",
      description = "This cannot be undone.",
      "Body content.",
      trigger = "Delete account",
      open = FALSE,
      class = "custom-dialog",
      style = "max-width: 42rem;"
    )
  )

  expect_identical(payload$component, "dialog")
  expect_identical(payload$id, "confirm")
  expect_identical(payload$state$value, FALSE)
  expect_identical(payload$state$open, FALSE)
  expect_identical(payload$binding$input, TRUE)
  expect_match(payload$props$titleHtml, "Are you sure?", fixed = TRUE)
  expect_match(payload$props$descriptionHtml, "cannot be undone", fixed = TRUE)
  expect_match(payload$props$bodyHtml, "Body content.", fixed = TRUE)
  expect_identical(payload$props$triggerLabel, "Delete account")
  expect_identical(payload$className, "custom-dialog")
  expect_identical(payload$style$maxWidth, "42rem")
})

test_that("block_dialog requires id and title", {
  expect_error(block_dialog(title = "X"), "`id` is required", fixed = TRUE)
  expect_error(block_dialog(id = "x"), "`title` is required", fixed = TRUE)
})

test_that("block_popover emits a runtime payload with trigger and body", {
  payload <- runtime_payload_from(
    block_popover(
      id = "details",
      trigger = "Show details",
      htmltools::tags$p("Hello"),
      side = "top",
      align = "end",
      open = TRUE
    )
  )

  expect_identical(payload$component, "popover")
  expect_identical(payload$props$triggerLabel, "Show details")
  expect_match(payload$props$bodyHtml, "Hello", fixed = TRUE)
  expect_identical(payload$props$side, "top")
  expect_identical(payload$props$align, "end")
  expect_identical(payload$state$open, TRUE)
  expect_identical(payload$binding$input, TRUE)
  expect_identical(payload$binding$type, "shinyblocks.popover")
})

test_that("block_popover requires a string trigger", {
  expect_error(block_popover(trigger = NULL), "`trigger`", fixed = TRUE)
  expect_error(block_popover(trigger = c("a", "b")), "single string", fixed = TRUE)
})

test_that("block_popover rejects invalid side and align", {
  expect_error(block_popover(trigger = "x", side = "diagonal"), "should be one of")
  expect_error(block_popover(trigger = "x", align = "weird"), "should be one of")
})

test_that("block_tooltip emits a runtime payload with trigger and body", {
  payload <- runtime_payload_from(
    block_tooltip(
      trigger = "Hover me",
      htmltools::tags$p("Hello"),
      side = "bottom",
      align = "start",
      delay_duration = 500
    )
  )

  expect_identical(payload$component, "tooltip")
  expect_identical(payload$props$triggerLabel, "Hover me")
  expect_match(payload$props$bodyHtml, "Hello", fixed = TRUE)
  expect_identical(payload$props$side, "bottom")
  expect_identical(payload$props$align, "start")
  expect_identical(payload$props$delayDuration, 500L)
  expect_identical(payload$binding$input, FALSE)
})

test_that("block_tooltip rejects bad trigger, side, align, and delay", {
  expect_error(block_tooltip(trigger = NULL), "`trigger`", fixed = TRUE)
  expect_error(block_tooltip(trigger = c("a", "b")), "single string", fixed = TRUE)
  expect_error(block_tooltip(trigger = "x", side = "diagonal"), "should be one of")
  expect_error(block_tooltip(trigger = "x", align = "weird"), "should be one of")
  expect_error(
    block_tooltip(trigger = "x", delay_duration = -1),
    "non-negative",
    fixed = TRUE
  )
})

test_that("block_popover without id is client-only", {
  payload <- runtime_payload_from(block_popover(trigger = "Open"))

  expect_identical(payload$binding$input, FALSE)
  expect_false("type" %in% names(payload$binding))
})

test_that("update_block_popover sends input binding messages", {
  capture <- local_input_message_session()

  update_block_popover(
    capture$session,
    "details",
    open = TRUE,
    trigger = "Updated label",
    body = htmltools::tags$p("Updated body"),
    side = "left",
    align = "start",
    style = "max-width: 18rem;",
    class = "custom-popover"
  )

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-popover-details")
  expect_identical(message$payload$open, TRUE)
  expect_identical(message$payload$triggerLabel, "Updated label")
  expect_match(message$payload$bodyHtml, "Updated body", fixed = TRUE)
  expect_identical(message$payload$side, "left")
  expect_identical(message$payload$align, "start")
  expect_identical(message$payload$contentStyle$maxWidth, "18rem")
  expect_identical(message$payload$contentClass, "custom-popover")
  expect_identical(message$payload$notify, TRUE)
})

test_that("cosmetic update_block_popover messages do not notify", {
  capture <- local_input_message_session(ns = function(id) paste0("module-", id))

  update_block_popover(capture$session, "details", class = "custom")

  message <- capture$last_message()
  expect_identical(message$input_id, "sb-runtime-popover-module-details")
  expect_identical(message$payload$class, NULL)
  expect_identical(message$payload$contentClass, "custom")
  expect_identical(message$payload$notify, FALSE)
})

test_that("update_block_popover clears clearable fields", {
  capture <- local_input_message_session()

  update_block_popover(
    capture$session,
    "details",
    body = NULL,
    style = NULL,
    class = NULL
  )

  message <- capture$last_payload()
  expect_true("bodyHtml" %in% names(message))
  expect_true("contentStyle" %in% names(message))
  expect_true("contentClass" %in% names(message))
  expect_null(message$bodyHtml)
  expect_null(message$contentStyle)
  expect_null(message$contentClass)
})

test_that("update_block_popover validates session and enums", {
  capture <- local_input_message_session()

  expect_error(update_block_popover(NULL, "details"), "session")
  expect_error(update_block_popover(capture$session, "details", side = "diagonal"), "one of")
  expect_error(update_block_popover(capture$session, "details", align = "weird"), "one of")
})

test_that("block_dialog forwards hide_title to props", {
  payload <- runtime_payload_from(
    block_dialog(id = "x", title = "Hidden", hide_title = TRUE)
  )
  expect_identical(payload$props$hideTitle, TRUE)
})

test_that("block_dialog defaults to size = 'default' and forwards size + footer", {
  default_payload <- runtime_payload_from(
    block_dialog(id = "x", title = "T")
  )
  expect_identical(default_payload$props$size, "default")
  expect_null(default_payload$props$footerHtml)

  sized_payload <- runtime_payload_from(
    block_dialog(
      id = "x",
      title = "T",
      size = "lg",
      footer = htmltools::tags$span("Action")
    )
  )
  expect_identical(sized_payload$props$size, "lg")
  expect_match(sized_payload$props$footerHtml, "Action", fixed = TRUE)
})

test_that("block_dialog rejects unknown size values", {
  expect_error(
    block_dialog(id = "x", title = "T", size = "huge"),
    "should be one of"
  )
})

test_that("update_block_dialog forwards size and footer", {
  capture <- local_input_message_session()

  update_block_dialog(
    capture$session,
    "confirm",
    size = "xl",
    footer = htmltools::tags$button("OK")
  )

  message <- capture$last_payload()
  expect_identical(message$size, "xl")
  expect_match(message$footerHtml, "OK", fixed = TRUE)
  expect_identical(message$notify, FALSE)
})

test_that("update_block_dialog forwards class and style", {
  capture <- local_input_message_session()

  update_block_dialog(
    capture$session,
    "confirm",
    class = "custom-dialog",
    style = "border: 2px dashed red;"
  )

  message <- capture$last_payload()
  expect_identical(message$className, "custom-dialog")
  expect_identical(message$style$border, "2px dashed red")
  expect_identical(message$notify, FALSE)
})

test_that("update_block_dialog clears footer when passed NULL", {
  capture <- local_input_message_session()

  update_block_dialog(capture$session, "confirm", footer = NULL)
  message <- capture$last_payload()
  expect_true("footerHtml" %in% names(message))
  expect_null(message$footerHtml)
})

test_that("update_block_dialog rejects invalid size values", {
  capture <- local_input_message_session()
  expect_error(
    update_block_dialog(capture$session, "confirm", size = "huge"),
    "size"
  )
})

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

test_that("block_theme validates named and known tokens", {
  expect_snapshot(error = TRUE, {
    block_theme("bad")
  })

  expect_snapshot(error = TRUE, {
    block_theme(not_a_token = "red")
  })
})

test_that("block_theme emits every built-in semantic palette", {
  declarations <- function(values) {
    paste(sprintf("--%s: %s;", names(values), unlist(values)), collapse = "")
  }

  expect_identical(
    shinyblocks:::theme_preset_names(),
    c("neutral", "stone", "zinc", "mauve", "olive", "mist", "taupe")
  )

  for (preset in shinyblocks:::theme_preset_names()) {
    values <- shinyblocks:::theme_preset(preset)
    css <- as.character(block_theme(preset = preset))

    expect_match(
      css,
      paste0(".sb-app{", declarations(values$light), "}"),
      fixed = TRUE
    )
    expect_match(
      css,
      paste0(
        '[data-theme="dark"] .sb-app{',
        declarations(values$dark),
        "}"
      ),
      fixed = TRUE
    )
    expect_false("radius" %in% names(values$light))
    expect_false("radius" %in% names(values$dark))
  }
})

test_that("every palette exposes the same semantic token set in light and dark", {
  # Palette conformance matrix: no palette may silently drop a semantic token,
  # and every palette's light pack must match its dark pack name-for-name. This
  # keeps the palette sweep (tools/theme/check-theme-response.mjs) honest.
  reference <- names(shinyblocks:::theme_preset("neutral")$light)
  expect_true(length(reference) > 0)

  for (preset in shinyblocks:::theme_preset_names()) {
    values <- shinyblocks:::theme_preset(preset)
    expect_setequal(names(values$light), reference)
    expect_setequal(names(values$dark), reference)
  }
})

test_that("block_theme presets layer under explicit overrides", {
  css <- as.character(block_theme(
    preset = "olive",
    primary = "red",
    dark = list(primary = "blue"),
    scope = ".demo"
  ))

  expect_match(css, ".demo{--background: oklch(1 0 0);", fixed = TRUE)
  expect_match(css, "--primary: red;", fixed = TRUE)
  expect_match(
    css,
    '[data-theme="dark"] .demo{--background: oklch(0.153 0.006 107.1);',
    fixed = TRUE
  )
  expect_match(css, "--primary: blue;", fixed = TRUE)
  expect_false(grepl("--radius:", css, fixed = TRUE))
})

test_that("block_theme validates preset names", {
  expect_error(block_theme(), "requires a `preset`")
  expect_error(block_theme(preset = "unknown"), "Unknown theme preset")
  expect_error(block_theme(preset = c("olive", "taupe")), "one supported palette")
  expect_error(block_theme(preset = ""), "one supported palette")
})

test_that("block_theme defaults to page-wide selectors", {
  css <- as.character(block_theme(primary = "red"))
  expect_true(grepl(".sb-app{", css, fixed = TRUE))
  expect_true(grepl(".sb-app [data-shinyblocks-root]", css, fixed = TRUE))
  expect_true(grepl(
    ".sb-app [data-shinyblocks-portal-root]",
    css,
    fixed = TRUE
  ))
})

test_that("block_theme confines overrides to scope when supplied", {
  css <- as.character(block_theme(primary = "red", scope = ".demo"))
  expect_true(grepl(".demo{--primary: red;}", css, fixed = TRUE))
  expect_true(grepl(".demo [data-shinyblocks-root]", css, fixed = TRUE))
  expect_true(grepl(".demo [data-shinyblocks-portal-root]", css, fixed = TRUE))
  # The page-wide selector must NOT appear when a scope is given.
  expect_false(grepl(".sb-app{", css, fixed = TRUE))
})

test_that("block_theme rejects an invalid scope", {
  expect_error(
    block_theme(primary = "red", scope = c(".a", ".b")),
    "single non-empty CSS selector"
  )
  expect_error(
    block_theme(primary = "red", scope = ""),
    "single non-empty CSS selector"
  )
})

test_that("block_theme dark overrides emit data-theme=dark rules", {
  css <- as.character(block_theme(
    primary = "red",
    dark = list(primary = "blue"),
    scope = ".demo"
  ))
  # Light/base value applies in both modes.
  expect_true(grepl(".demo{--primary: red;}", css, fixed = TRUE))
  # Dark value applies only under [data-theme="dark"].
  expect_true(grepl("[data-theme=\"dark\"] .demo{--primary: blue;}", css, fixed = TRUE))
  expect_true(grepl(
    "[data-theme=\"dark\"] .demo [data-shinyblocks-root]",
    css,
    fixed = TRUE
  ))
})

test_that("block_theme accepts dark-only overrides", {
  css <- as.character(block_theme(dark = list(primary = "blue")))
  # No light/base rule: style content begins straight with the dark selector.
  expect_true(grepl(">[data-theme", css, fixed = TRUE))
  expect_false(grepl(">.sb-app", css, fixed = TRUE))
  expect_true(grepl("[data-theme=\"dark\"] .sb-app{--primary: blue;}", css, fixed = TRUE))
})

test_that("block_theme validates dark token names and shape", {
  expect_error(block_theme(dark = list(not_a_token = "red")), "Unknown theme token")
  expect_error(block_theme(dark = list("red")), "non-empty named list")
  expect_error(block_theme(dark = list()), "non-empty named list")
})

test_that("block_theme_presets exposes the built-in palette names", {
  expect_identical(block_theme_presets(), shinyblocks:::theme_preset_names())
  expect_length(block_theme_presets(), 7L)
  expect_true(all(c("neutral", "olive", "taupe") %in% block_theme_presets()))
})

test_that("update_block_theme sends a custom message", {
  capture <- local_custom_message_session()

  expect_invisible(update_block_theme(capture$session, mode = "dark"))
  message <- capture$last_message()
  expect_identical(message$type, "sb:theme")
  expect_identical(message$payload$mode, "dark")
})

test_that("update_block_theme requires a session", {
  expect_snapshot(error = TRUE, {
    update_block_theme(NULL)
  })
})

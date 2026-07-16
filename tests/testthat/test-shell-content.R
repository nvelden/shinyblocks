test_that("badge variants map to runtime props", {
  destructive <- runtime_payload_from(
    block_badge("Blocked", variant = "destructive")
  )
  success <- runtime_payload_from(block_badge("Synced", variant = "success"))
  warning <- runtime_payload_from(block_badge("Review", variant = "warning"))
  info <- runtime_payload_from(block_badge("Active", variant = "info"))
  outline <- runtime_payload_from(block_badge("Draft", variant = "outline"))
  ghost <- runtime_payload_from(block_badge("Quiet", variant = "ghost"))
  link <- runtime_payload_from(block_badge(
    "Docs",
    variant = "link",
    size = "lg"
  ))

  expect_identical(destructive$props$variant, "destructive")
  expect_identical(success$props$variant, "success")
  expect_identical(warning$props$variant, "warning")
  expect_identical(info$props$variant, "info")
  expect_identical(outline$props$variant, "outline")
  expect_identical(ghost$props$variant, "ghost")
  expect_identical(link$props$variant, "link")
  expect_identical(link$props$size, "lg")
})

test_that("badge classes pass through the runtime payload", {
  badge <- runtime_payload_from(block_badge("New", class = "custom"))

  expect_identical(badge$className, "custom")
  expect_identical(badge$props$variant, "default")
  expect_identical(badge$props$size, "default")
})

test_that("card flat arguments compose into card regions", {
  card <- render_html(
    block_card(
      title = "Revenue",
      description = "Last 30 days",
      value = "$42k",
      footer = block_button("View report"),
      "Up 12% month over month."
    )
  )

  expect_match(card, 'class="sb-card-header"', fixed = TRUE)
  expect_match(card, 'class="sb-card-title"', fixed = TRUE)
  expect_match(card, 'class="sb-card-description"', fixed = TRUE)
  expect_match(card, 'class="sb-card-content"', fixed = TRUE)
  expect_match(card, 'class="sb-card-footer"', fixed = TRUE)
  expect_match(card, 'class="sb-card-value"', fixed = TRUE)
})

test_that("card composition helpers render expected child markers", {
  header <- block_card_header(
    block_card_title("Revenue"),
    block_card_description("Last 30 days")
  )
  content <- block_card_content("Chart")
  footer <- block_card_footer(block_button("Open"))
  card <- block_card(header, content, footer, class = "custom")

  expect_identical(tag_attr(header, "data-sb-child"), "card-header")
  expect_identical(tag_attr(content, "data-sb-child"), "card-content")
  expect_identical(tag_attr(footer, "data-sb-child"), "card-footer")

  styled_card <- block_card(
    "Body",
    class = "custom",
    style = "max-width: 20rem;"
  )
  card_html <- render_html(card)
  expect_match(card_html, 'class="sb-card custom"', fixed = TRUE)
  # Cards are plain markup now, not a runtime React mount: the card's own tag
  # carries no runtime-root attributes (nested blocks like a footer button may
  # still be runtime mounts).
  expect_identical(tag_attr(card, "class"), "sb-card custom")
  expect_null(tag_attr(card, "data-shinyblocks-root"))
  expect_identical(tag_attr(card, "data-shinyblocks-scope"), "")
  expect_null(tag_attr(card, "data-sb-component"))
  expect_identical(tag_attr(styled_card, "style"), "max-width: 20rem;")
  expect_identical(tag_attr(styled_card, "class"), "sb-card custom")
})

test_that("R-side composition primitives establish standalone token scopes", {
  tags <- list(
    block_card("Body"),
    block_tabs(block_tab("One", "Panel")),
    block_field("Field"),
    block_input_group("Input"),
    block_stack("Stack")
  )

  for (tag in tags) {
    expect_identical(tag_attr(tag, "data-shinyblocks-scope"), "")
    expect_null(tag_attr(tag, "data-shinyblocks-root"))
  }

  runtime <- block_button("Run")
  expect_null(tag_attr(runtime, "data-shinyblocks-scope"))
  expect_identical(tag_attr(runtime, "data-shinyblocks-root"), "")
})

test_that("card helper classes merge with user classes", {
  expect_identical(
    tag_attr(block_card_header("Header", class = "custom"), "class"),
    "sb-card-header custom"
  )
  expect_identical(
    tag_attr(block_card_content("Body", class = "custom"), "class"),
    "sb-card-content custom"
  )
  expect_identical(
    tag_attr(block_card_footer("Footer", class = "custom"), "class"),
    "sb-card-footer custom"
  )
})

test_that("alerts render role, variants, and icon markup", {
  alert <- runtime_payload_from(
    block_alert(
      "Heads up",
      description = "Action needed.",
      variant = "destructive",
      icon = "alert-triangle"
    )
  )
  alert_html <- render_html(
    block_alert(
      "Heads up",
      description = "Action needed.",
      variant = "destructive",
      icon = "alert-triangle"
    )
  )

  expect_identical(alert$props$variant, "destructive")
  expect_match(alert$props$titleHtml, "Heads up", fixed = TRUE)
  expect_match(alert$props$titleHtml, 'class="sb-alert-title"', fixed = TRUE)
  expect_match(alert$props$descriptionHtml, "Action needed.", fixed = TRUE)
  expect_match(
    alert$props$descriptionHtml,
    'class="sb-alert-description"',
    fixed = TRUE
  )
  expect_match(alert$props$iconHtml, 'data-icon="inline-start"', fixed = TRUE)
  expect_match(alert_html, 'data-sb-component="alert"', fixed = TRUE)
})

test_that("alerts accept composed title and description tags", {
  title <- block_alert_title("Maintenance")
  description <- block_alert_description("Scheduled tonight.")
  action <- block_alert_action(block_button(
    "Review",
    variant = "outline",
    size = "sm"
  ))
  payload <- runtime_payload_from(
    block_alert(title, description = description, action = action, icon = NULL)
  )

  expect_identical(tag_attr(title, "data-sb-child"), "alert-title")
  expect_identical(
    tag_attr(description, "data-sb-child"),
    "alert-description"
  )
  expect_identical(tag_attr(action, "data-sb-child"), "alert-action")
  expect_match(payload$props$titleHtml, "Maintenance", fixed = TRUE)
  expect_match(
    payload$props$descriptionHtml,
    "Scheduled tonight.",
    fixed = TRUE
  )
  expect_match(payload$props$actionHtml, "Review", fixed = TRUE)
  expect_match(payload$props$actionHtml, "sb-alert-action", fixed = TRUE)
  expect_null(payload$props$iconHtml)
})

test_that("alerts expose feedback-state variants", {
  for (variant in c("success", "warning", "info")) {
    payload <- runtime_payload_from(block_alert("Status", variant = variant))
    expect_identical(payload$props$variant, variant)
  }
})

test_that("value boxes render expected regions", {
  box <- runtime_payload_from(
    block_value_box(
      "Revenue",
      "$42k",
      block_badge("Healthy", variant = "secondary"),
      description = "Up 12% month over month.",
      icon = "trending-up",
      variant = "accent"
    )
  )
  box_html <- render_html(
    block_value_box(
      "Revenue",
      "$42k",
      block_badge("Healthy", variant = "secondary"),
      description = "Up 12% month over month.",
      icon = "trending-up"
    )
  )

  expect_match(box$props$titleHtml, "Revenue", fixed = TRUE)
  expect_match(box$props$valueHtml, "$42k", fixed = TRUE)
  expect_match(
    box$props$descriptionHtml,
    "Up 12% month over month.",
    fixed = TRUE
  )
  expect_match(box$props$iconHtml, 'data-icon="inline-start"', fixed = TRUE)
  expect_identical(box$props$variant, "accent")
  expect_match(box$props$contentHtml, 'data-sb-component="badge"', fixed = TRUE)
  expect_match(box_html, 'data-sb-component="value-box"', fixed = TRUE)
})

test_that("value boxes merge user classes", {
  payload <- runtime_payload_from(block_value_box(
    "Revenue",
    "$42k",
    class = "custom"
  ))
  expect_identical(payload$className, "custom")
})

test_that("separators expose orientation and aria correctly", {
  vertical <- runtime_payload_from(
    block_separator(orientation = "vertical", decorative = FALSE)
  )
  decorative <- runtime_payload_from(block_separator())
  decorative_html <- render_html(block_separator())

  expect_identical(
    vertical$props$orientation,
    "vertical"
  )
  expect_identical(vertical$props$decorative, FALSE)
  expect_identical(decorative$props$orientation, "horizontal")
  expect_identical(decorative$props$decorative, TRUE)
  expect_match(
    decorative_html,
    'data-sb-component="separator"',
    fixed = TRUE
  )
})

test_that("skeletons and spinners expose expected attributes", {
  skeleton <- runtime_payload_from(
    block_skeleton(
      class = "custom",
      id = "loading-skeleton",
      `data-testid` = "skeleton",
      style = "width: 4rem; height: 1rem;"
    )
  )
  skeleton_html <- render_html(
    block_skeleton(
      class = "custom",
      id = "loading-skeleton",
      `data-testid` = "skeleton",
      style = "width: 4rem; height: 1rem;"
    )
  )
  spinner <- runtime_payload_from(block_spinner(
    label = "Loading table",
    size = "lg",
    color = "muted",
    icon = "loader-pinwheel",
    class = "custom",
    style = "margin: 1rem;"
  ))
  spinner_html <- render_html(block_spinner(
    label = "Loading table",
    size = "lg",
    color = "muted",
    icon = "loader-pinwheel",
    class = "custom",
    style = "margin: 1rem;"
  ))

  expect_identical(skeleton$className, "custom")
  expect_identical(skeleton$props$attrs$id, "loading-skeleton")
  expect_identical(skeleton$props$attrs$`data-testid`, "skeleton")
  expect_identical(skeleton$props$attrs$style$width, "4rem")
  expect_identical(skeleton$props$attrs$style$height, "1rem")
  expect_match(skeleton_html, 'data-sb-component="skeleton"', fixed = TRUE)
  expect_identical(spinner$props$label, "Loading table")
  expect_identical(spinner$props$size, "lg")
  expect_identical(spinner$props$color, "muted")
  expect_identical(spinner$props$iconName, "loader-pinwheel")
  expect_match(
    spinner$props$spriteHref,
    "icons/sprite.svg",
    fixed = TRUE
  )
  expect_identical(spinner$className, "custom")
  expect_identical(spinner$style$margin, "1rem")
  expect_match(spinner_html, 'data-sb-component="spinner"', fixed = TRUE)
})

test_that("spinner validates icon choices", {
  for (icon in shinyblocks:::spinner_icon_choices()) {
    expect_identical(
      runtime_payload_from(block_spinner(icon = icon))$props$iconName,
      icon
    )
  }

  expect_error(block_spinner(icon = "home"))
})

test_that("spinner and icon accept the same semantic colors", {
  colors <- shinyblocks:::semantic_color_choices()

  for (color in colors) {
    expect_identical(
      runtime_payload_from(block_spinner(color = color))$props$color,
      color
    )
    expect_s3_class(block_icon("home", color = color), "shiny.tag")
  }

  expect_error(block_spinner(color = "urgent"))
})

test_that("empty states render icon, description, and action", {
  empty <- runtime_payload_from(
    block_empty(
      "No results",
      description = "Try broadening your search.",
      htmltools::tags$p("Extra detail"),
      icon = "folder",
      action = block_button("Clear filters")
    )
  )
  empty_html <- render_html(
    block_empty(
      "No results",
      description = "Try broadening your search.",
      htmltools::tags$p("Extra detail"),
      icon = "folder",
      action = block_button("Clear filters")
    )
  )

  expect_match(empty$props$titleHtml, "No results", fixed = TRUE)
  expect_match(
    empty$props$descriptionHtml,
    "Try broadening your search.",
    fixed = TRUE
  )
  expect_match(empty$props$contentHtml, "Extra detail", fixed = TRUE)
  expect_match(empty$props$iconHtml, 'data-icon="inline-start"', fixed = TRUE)
  expect_match(
    empty$props$actionHtml,
    'data-sb-component="button"',
    fixed = TRUE
  )
  expect_match(empty_html, 'data-sb-component="empty"', fixed = TRUE)
})

test_that("block_code validates its arguments", {
  expect_error(
    block_code(),
    "`code` must be a single non-empty character string.",
    fixed = TRUE
  )
  expect_error(
    block_code(123),
    "`code` must be a single non-empty character string.",
    fixed = TRUE
  )
  expect_error(
    block_code(c("line1", "line2")),
    "`code` must be a single non-empty character string.",
    fixed = TRUE
  )
  expect_error(
    block_code(""),
    "`code` must be a single non-empty character string.",
    fixed = TRUE
  )
  expect_error(
    block_code("print('hello')", language = c("r", "python")),
    "`language` must be NULL or a single character string.",
    fixed = TRUE
  )
  expect_error(
    block_code("print('hello')", variant = "invalid-variant"),
    "`variant` must be one of \"default\", \"outline\".",
    fixed = TRUE
  )
})

test_that("block_code emits runtime payload with all props and custom styling", {
  code_block <- block_code(
    "console.log('hello');",
    language = "javascript",
    copyable = TRUE,
    line_numbers = FALSE,
    header = TRUE,
    variant = "outline",
    class = "custom-class",
    style = "margin-bottom: 2rem;"
  )

  payload <- runtime_payload_from(code_block)
  html <- render_html(code_block)

  expect_identical(payload$component, "code")
  expect_identical(payload$props$code, "console.log('hello');")
  expect_identical(payload$props$language, "javascript")
  expect_identical(payload$props$copyable, TRUE)
  expect_identical(payload$props$line_numbers, FALSE)
  expect_identical(payload$props$header, TRUE)
  expect_identical(payload$props$variant, "outline")
  expect_identical(payload$className, "custom-class")
  expect_identical(tag_attr(code_block, "style"), "margin-bottom: 2rem;")

  expect_match(html, 'data-sb-component="code"', fixed = TRUE)
  expect_match(html, 'class="sb-runtime-mount"', fixed = TRUE)
})

test_that("block_code handles defaults correctly", {
  code_block <- block_code("console.log('hello');")
  payload <- runtime_payload_from(code_block)
  expect_identical(payload$props$header, FALSE)
  expect_identical(payload$props$line_numbers, TRUE)
  expect_identical(payload$props$copyable, TRUE)
  expect_identical(payload$props$variant, "default")
})

test_that("block_icon size and color map to real classes", {
  default_icon <- block_icon("home")
  expect_match(tag_attr(default_icon, "class"), "sb-icon", fixed = TRUE)
  expect_false(grepl(
    "sb-icon-size-",
    tag_attr(default_icon, "class"),
    fixed = TRUE
  ))
  expect_false(grepl(
    "sb-icon-color-",
    tag_attr(default_icon, "class"),
    fixed = TRUE
  ))

  lg_icon <- block_icon("home", size = "lg")
  expect_match(tag_attr(lg_icon, "class"), "sb-icon-size-lg", fixed = TRUE)

  sm_icon <- block_icon("home", size = "sm", color = "success", class = "extra")
  expect_match(tag_attr(sm_icon, "class"), "sb-icon-size-sm", fixed = TRUE)
  expect_match(
    tag_attr(sm_icon, "class"),
    "sb-icon-color-success",
    fixed = TRUE
  )
  expect_match(tag_attr(sm_icon, "class"), "extra", fixed = TRUE)
})

test_that("block_icon rejects an unknown size", {
  expect_error(block_icon("home", size = "huge"))
})

test_that("block_icon rejects an unknown color", {
  expect_error(block_icon("home", color = "urgent"))
})

test_that("block_icon ignores size for tag passthrough and applies color", {
  custom <- htmltools::tags$svg(class = "my-icon")
  passthrough <- block_icon(custom, size = "lg", color = "warning")
  expect_false(grepl(
    "sb-icon-size-",
    tag_attr(passthrough, "class") %||% "",
    fixed = TRUE
  ))
  expect_match(
    tag_attr(passthrough, "class"),
    "sb-icon-color-warning",
    fixed = TRUE
  )
})

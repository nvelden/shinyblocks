test_that("block_page renders the shell landmarks", {
  page <- block_page(
    title = "Example",
    sidebar = block_sidebar(
      title = "Navigation",
      block_nav_item("Home", selected = TRUE)
    ),
    header = block_header("Header"),
    "Body"
  )

  rendered <- htmltools::renderTags(page)
  html <- paste(rendered$html, collapse = "")
  head <- paste(rendered$head, collapse = "")

  expect_match(html, '<div class="sb-app">', fixed = TRUE)
  expect_match(html, '<div class="sb-page has-sidebar">', fixed = TRUE)
  expect_match(html, '<aside class="sb-sidebar">', fixed = TRUE)
  expect_match(html, '<header class="sb-header">', fixed = TRUE)
  expect_match(html, '<main class="sb-body">', fixed = TRUE)
  expect_match(head, "document.documentElement.dataset.theme", fixed = TRUE)
})

test_that("layout helpers merge user classes", {
  expect_identical(
    tag_attr(block_header("Header", class = "custom"), "class"),
    "sb-header custom"
  )
  expect_identical(
    tag_attr(block_body("Body", class = "custom"), "class"),
    "sb-body custom"
  )
  expect_identical(
    tag_attr(block_sidebar("Item", class = "custom"), "class"),
    "sb-sidebar custom"
  )
})

test_that("selected nav items expose aria-current", {
  selected <- block_nav_item("Home", selected = TRUE)
  unselected <- block_nav_item("Reports")

  expect_identical(tag_attr(selected, "aria-current"), "page")
  expect_null(tag_attr(unselected, "aria-current"))
})

test_that("nav items advertise themselves as nav-item children", {
  ns <- local_internal()
  item <- block_nav_item("Home")

  expect_identical(tag_attr(item, "data-sb-child"), "nav-item")
  expect_invisible(
    ns$validate_children(list(item), "nav-item", "block_nav")
  )
})

test_that("nav items and buttons decorate icons", {
  nav <- render_html(block_nav_item("Home", icon = "home"))
  button_start <- render_html(block_button("Search", icon = "search"))
  button_end <- render_html(
    block_button("Open", icon = "arrow-right", icon_position = "inline-end")
  )

  expect_match(nav, 'data-icon="inline-start"', fixed = TRUE)
  expect_match(
    nav,
    'href="shinyblocks-0.0.0.9000/icons/sprite.svg#sb-icon-home"',
    fixed = TRUE
  )
  expect_match(button_start, 'data-icon="inline-start"', fixed = TRUE)
  expect_match(button_end, 'data-icon="inline-end"', fixed = TRUE)
})

test_that("button variants and sizes map to classes", {
  destructive <- tag_attr(
    block_button("Delete", variant = "destructive"),
    "class"
  )
  link <- tag_attr(block_button("Open", variant = "link"), "class")
  small <- tag_attr(block_button("Save", size = "sm"), "class")
  icon <- tag_attr(block_button("", size = "icon"), "class")

  expect_match(destructive, "sb-button-destructive", fixed = TRUE)
  expect_match(link, "sb-button-link", fixed = TRUE)
  expect_match(small, "sb-button-size-sm", fixed = TRUE)
  expect_match(icon, "sb-button-size-icon", fixed = TRUE)
})

test_that("button classes merge with user classes", {
  classes <- tag_attr(
    block_button("Save", variant = "outline", size = "lg", class = "custom"),
    "class"
  )

  expect_identical(
    classes,
    "sb-button sb-button-outline sb-button-size-lg custom"
  )
})

test_that("badge variants map to classes", {
  destructive <- tag_attr(
    block_badge("Blocked", variant = "destructive"),
    "class"
  )
  outline <- tag_attr(block_badge("Draft", variant = "outline"), "class")

  expect_match(destructive, "sb-badge-destructive", fixed = TRUE)
  expect_match(outline, "sb-badge-outline", fixed = TRUE)
})

test_that("badge classes merge with user classes", {
  classes <- tag_attr(block_badge("New", class = "custom"), "class")

  expect_identical(classes, "sb-badge sb-badge-default custom")
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
  expect_identical(tag_attr(card, "class"), "sb-card custom")
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
  alert <- render_html(
    block_alert(
      "Heads up",
      description = "Action needed.",
      variant = "destructive",
      icon = "alert-triangle"
    )
  )

  expect_match(alert, 'role="alert"', fixed = TRUE)
  expect_match(alert, 'class="sb-alert sb-alert-destructive"', fixed = TRUE)
  expect_match(alert, 'class="sb-alert-title"', fixed = TRUE)
  expect_match(alert, 'class="sb-alert-description"', fixed = TRUE)
  expect_match(alert, 'data-icon="inline-start"', fixed = TRUE)
})

test_that("alerts accept composed title and description tags", {
  title <- block_alert_title("Maintenance")
  description <- block_alert_description("Scheduled tonight.")
  alert <- block_alert(title, description = description, icon = NULL)

  expect_identical(tag_attr(title, "data-sb-child"), "alert-title")
  expect_identical(
    tag_attr(description, "data-sb-child"),
    "alert-description"
  )
  expect_identical(
    tag_attr(alert, "class"),
    "sb-alert sb-alert-default"
  )
})

test_that("value boxes render expected regions", {
  box <- render_html(
    block_value_box(
      "Revenue",
      "$42k",
      description = "Up 12% month over month.",
      icon = "trending-up"
    )
  )

  expect_match(box, 'class="sb-value-box"', fixed = TRUE)
  expect_match(box, 'class="sb-value-box-title"', fixed = TRUE)
  expect_match(box, 'class="sb-value-box-value"', fixed = TRUE)
  expect_match(box, 'class="sb-value-box-description"', fixed = TRUE)
  expect_match(box, 'data-icon="inline-start"', fixed = TRUE)
})

test_that("value boxes merge user classes", {
  classes <- tag_attr(
    block_value_box("Revenue", "$42k", class = "custom"),
    "class"
  )

  expect_identical(classes, "sb-value-box custom")
})

test_that("separators expose orientation and aria correctly", {
  vertical <- block_separator(orientation = "vertical", decorative = FALSE)
  decorative <- block_separator()

  expect_identical(
    tag_attr(vertical, "class"),
    "sb-separator sb-separator-vertical"
  )
  expect_identical(tag_attr(vertical, "role"), "separator")
  expect_identical(tag_attr(vertical, "aria-orientation"), "vertical")
  expect_identical(tag_attr(decorative, "aria-hidden"), "true")
})

test_that("skeletons and spinners expose expected attributes", {
  skeleton <- block_skeleton(class = "custom")
  spinner <- block_spinner(label = "Loading table", class = "custom")

  expect_identical(tag_attr(skeleton, "class"), "sb-skeleton custom")
  expect_identical(tag_attr(skeleton, "aria-hidden"), "true")
  expect_identical(tag_attr(spinner, "class"), "sb-spinner custom")
  expect_identical(tag_attr(spinner, "role"), "status")
  expect_identical(tag_attr(spinner, "aria-label"), "Loading table")
})

test_that("empty states render icon, description, and action", {
  empty <- render_html(
    block_empty(
      "No results",
      description = "Try broadening your search.",
      icon = "folder",
      action = block_button("Clear filters")
    )
  )

  expect_match(empty, 'class="sb-empty"', fixed = TRUE)
  expect_match(empty, 'class="sb-empty-title"', fixed = TRUE)
  expect_match(empty, 'class="sb-empty-description"', fixed = TRUE)
  expect_match(empty, 'class="sb-empty-action"', fixed = TRUE)
  expect_match(empty, 'data-icon="inline-start"', fixed = TRUE)
})

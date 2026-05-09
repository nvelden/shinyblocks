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

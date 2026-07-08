test_that("block_breadcrumb renders a nav landmark with interleaved separators", {
  trail <- block_breadcrumb(
    block_breadcrumb_item("Home", href = "/"),
    block_breadcrumb_item("Components", href = "/components"),
    block_breadcrumb_item("Breadcrumb", current = TRUE),
    class = "custom"
  )
  html <- render_html(trail)

  expect_identical(trail$name, "nav")
  expect_identical(tag_attr(trail, "class"), "sb-breadcrumb custom")
  expect_identical(tag_attr(trail, "aria-label"), "breadcrumb")

  # Three entries -> two separators, strictly interleaved inside the <ol>.
  expect_identical(
    lengths(regmatches(html, gregexpr('data-sb-child="breadcrumb-item"', html))),
    3L
  )
  expect_identical(
    lengths(regmatches(html, gregexpr("sb-breadcrumb-separator", html))),
    2L
  )
  expect_match(
    html,
    'class="sb-breadcrumb-separator" role="presentation" aria-hidden="true"',
    fixed = TRUE
  )
  # Default separator is the sprite chevron.
  expect_match(html, "#sb-icon-chevron-right", fixed = TRUE)

  # Package CSS dependency rides along.
  deps <- htmltools::findDependencies(trail)
  expect_true("shinyblocks" %in% vapply(deps, `[[`, character(1), "name"))
})

test_that("block_breadcrumb_item renders link, current-page, and plain variants", {
  link <- block_breadcrumb_item("Docs", href = "/docs")
  link_html <- render_html(link)
  expect_match(link_html, '<a class="sb-breadcrumb-link" href="/docs">Docs</a>', fixed = TRUE)

  current <- block_breadcrumb_item("Here", href = "/ignored", current = TRUE)
  current_html <- render_html(current)
  expect_match(
    current_html,
    '<span class="sb-breadcrumb-page" role="link" aria-disabled="true" aria-current="page">Here</span>',
    fixed = TRUE
  )
  expect_no_match(current_html, "/ignored", fixed = TRUE)

  plain <- block_breadcrumb_item("Plain")
  expect_match(render_html(plain), '<span class="sb-breadcrumb-text">Plain</span>', fixed = TRUE)

  # Tag labels are allowed.
  tagged <- block_breadcrumb_item(htmltools::tags$em("Fancy"), href = "#")
  expect_match(render_html(tagged), "<em>Fancy</em>", fixed = TRUE)
})

test_that("block_breadcrumb_ellipsis hides the glyph and announces the label", {
  ellipsis <- block_breadcrumb_ellipsis()
  html <- render_html(ellipsis)

  expect_identical(tag_attr(ellipsis, "data-sb-child"), "breadcrumb-ellipsis")
  expect_match(
    html,
    'class="sb-breadcrumb-ellipsis" role="presentation" aria-hidden="true"',
    fixed = TRUE
  )
  expect_match(html, "#sb-icon-more-horizontal", fixed = TRUE)
  expect_match(html, '<span class="sb-breadcrumb-sr-only">More</span>', fixed = TRUE)

  custom <- block_breadcrumb_ellipsis(label = "Hidden pages")
  expect_match(render_html(custom), ">Hidden pages</span>", fixed = TRUE)
})

test_that("block_breadcrumb supports string and tag separators", {
  slash <- block_breadcrumb(
    block_breadcrumb_item("A", href = "#"),
    block_breadcrumb_item("B", current = TRUE),
    separator = "/"
  )
  slash_html <- render_html(slash)
  expect_match(slash_html, '>/</li>', fixed = TRUE)
  expect_no_match(slash_html, "sb-icon-chevron-right", fixed = TRUE)

  tag_sep <- block_breadcrumb(
    block_breadcrumb_item("A", href = "#"),
    block_breadcrumb_item("B", current = TRUE),
    separator = htmltools::tags$span(class = "sep", ">")
  )
  expect_match(render_html(tag_sep), '<span class="sep">&gt;</span>', fixed = TRUE)
})

test_that("breadcrumb constructors validate their inputs", {
  expect_error(
    block_breadcrumb(),
    "needs at least one",
    fixed = TRUE
  )
  expect_error(
    block_breadcrumb(htmltools::div("nope")),
    "must be `breadcrumb-item`, `breadcrumb-ellipsis` items",
    fixed = TRUE
  )
  expect_error(
    block_breadcrumb(block_breadcrumb_item("A"), separator = 1),
    "`separator` must be NULL, a single string, or an htmltools tag.",
    fixed = TRUE
  )
  expect_error(
    block_breadcrumb_item(),
    "`label` is required",
    fixed = TRUE
  )
  expect_error(
    block_breadcrumb_item("A", href = c("/a", "/b")),
    "`href` must be NULL or a single string.",
    fixed = TRUE
  )
  expect_error(
    block_breadcrumb_item("A", current = "yes"),
    "`current` must be a single TRUE or FALSE.",
    fixed = TRUE
  )
  expect_error(
    block_breadcrumb_ellipsis(label = c("a", "b")),
    "`label` must be a single string.",
    fixed = TRUE
  )
})

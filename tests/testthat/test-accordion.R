test_that("block_accordion_item builds a trigger, chevron, and content region", {
  item <- block_accordion_item("faq", "Question?", "Answer body.")
  html <- render_html(item)

  expect_match(html, 'class="sb-accordion-item"')
  expect_match(html, 'data-sb-child="accordion-item"')
  expect_match(html, 'data-value="faq"')
  expect_match(html, 'class="sb-accordion-trigger"')
  expect_match(html, 'aria-expanded="false"')
  expect_match(html, "Question\\?")
  expect_match(html, "Answer body.")
  expect_match(html, 'class="sb-accordion-content"')
  expect_match(html, 'role="region"')
  # Closed content is inert so it stays out of the tab order / a11y tree.
  expect_match(html, "<div class=\"sb-accordion-content\"[^>]*inert")
})

test_that("block_accordion_item validates value, title, and disabled", {
  expect_error(block_accordion_item(1, "Title"), "`value` must be a single string")
  expect_error(block_accordion_item("v"), "`title` must be a single string")
  expect_error(
    block_accordion_item("v", "T", disabled = "yes"),
    "`disabled` must be a single TRUE or FALSE"
  )
})

test_that("block_accordion wires ids, state, and the input binding", {
  acc <- block_accordion(
    block_accordion_item("a", "A", "body a"),
    block_accordion_item("b", "B", "body b"),
    id = "sections",
    open = "b"
  )
  html <- render_html(acc)

  expect_match(html, 'class="sb-accordion"')
  expect_match(html, 'data-sb-accordion="true"')
  expect_match(html, 'data-sb-accordion-input-id="sections"')
  expect_match(html, 'data-type="single"')
  expect_match(html, 'data-collapsible="false"')

  # The `open = "b"` item resolves to open, the other stays closed.
  expect_match(html, 'data-value="b"[^>]*data-state="open"')
  expect_match(html, 'data-value="a"[^>]*data-state="closed"')
  expect_match(html, 'aria-expanded="true"[^>]*id="sections-trigger-2"')
  expect_match(html, 'aria-controls="sections-panel-2"')
})

test_that("block_accordion accepts a spliced list of items via !!!", {
  items <- lapply(1:3, function(i) {
    block_accordion_item(paste0("q", i), paste("Question", i), paste("Answer", i))
  })
  acc <- block_accordion(!!!items, id = "faq", open = "q2")
  html <- render_html(acc)

  expect_match(html, 'data-value="q1"')
  expect_match(html, 'data-value="q2"[^>]*data-state="open"')
  expect_match(html, 'data-value="q3"')
  expect_match(html, "Question 3")
  # Spliced items are still validated and de-duplicated like literal ones.
  dup <- lapply(1:2, function(i) block_accordion_item("same", "T", "b"))
  expect_error(block_accordion(!!!dup), "item values must be unique")
})

test_that("block_accordion multiple mode is always collapsible", {
  acc <- block_accordion(
    block_accordion_item("a", "A", "a"),
    block_accordion_item("b", "B", "b"),
    type = "multiple",
    open = c("a", "b")
  )
  html <- render_html(acc)
  expect_match(html, 'data-type="multiple"')
  expect_match(html, 'data-collapsible="true"')
  expect_match(html, 'data-value="a"[^>]*data-state="open"')
  expect_match(html, 'data-value="b"[^>]*data-state="open"')
})

test_that("block_accordion validates children, values, and open set", {
  expect_error(
    block_accordion(htmltools::tags$div("nope")),
    "must be `accordion-item` items"
  )
  expect_error(block_accordion(), "requires at least one item")
  expect_error(
    block_accordion(
      block_accordion_item("dup", "A", "a"),
      block_accordion_item("dup", "B", "b")
    ),
    "item values must be unique"
  )
  expect_error(
    block_accordion(
      block_accordion_item("a", "A", "a"),
      open = "missing"
    ),
    "must match one of the accordion item values"
  )
  expect_error(
    block_accordion(
      block_accordion_item("a", "A", "a"),
      block_accordion_item("b", "B", "b"),
      type = "single",
      open = c("a", "b")
    ),
    "must be a single value when `type = \"single\"`"
  )
})

test_that("block_accordion marks disabled items", {
  acc <- block_accordion(
    block_accordion_item("a", "A", "a", disabled = TRUE)
  )
  html <- render_html(acc)
  expect_match(html, 'data-disabled="true"')
  expect_match(html, "<button[^>]*disabled")
})

test_that("block_accordion renders a leading icon before the title", {
  acc <- block_accordion(
    block_accordion_item("a", "A", "a", icon = "star")
  )
  html <- render_html(acc)
  expect_match(html, 'data-icon="inline-start"')
})

test_that("update_block_accordion sends the open set and notify flag", {
  capture <- local_input_message_session()
  update_block_accordion(capture$session, "sections", open = c("a", "b"))
  msg <- capture$last_message()
  expect_identical(msg$input_id, "sections")
  expect_identical(msg$payload$open, list("a", "b"))
  expect_true(msg$payload$notify)
})

test_that("update_block_accordion open = NULL closes all without notify when asked", {
  capture <- local_input_message_session()
  update_block_accordion(capture$session, "sections", open = NULL, notify = FALSE)
  payload <- capture$last_payload()
  expect_identical(payload$open, list())
  expect_false(payload$notify)
})

test_that("update_block_accordion validates session and input id", {
  expect_error(
    update_block_accordion(NULL, "sections", open = "a"),
    "`session` is required"
  )
  capture <- local_input_message_session()
  expect_error(
    update_block_accordion(capture$session, "", open = "a"),
    "`input_id` must be a non-empty string"
  )
})

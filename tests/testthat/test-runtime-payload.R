test_that("runtime_payload() creates a versioned payload", {
  ns <- local_internal()

  payload <- ns$runtime_payload(
    component = "fixture",
    props = list(label = "Label"),
    input_id = "choice",
    state = list(value = "a"),
    binding = list(input = TRUE),
    class = "extra"
  )

  expect_identical(payload$schemaVersion, 1L)
  expect_identical(payload$component, "fixture")
  expect_identical(payload$id, "choice")
  expect_identical(payload$props$label, "Label")
  expect_identical(payload$state$value, "a")
  expect_identical(payload$binding$input, TRUE)
  expect_identical(payload$className, "extra")
})

test_that("runtime payloads are encoded as safe JSON", {
  ns <- local_internal()

  payload <- ns$runtime_payload(
    component = "fixture",
    props = list(label = "</script>")
  )
  json <- ns$runtime_payload_json(payload)

  expect_match(json, "<\\/script>", fixed = TRUE)
  expect_identical(
    jsonlite::fromJSON(json)$props$label,
    "</script>"
  )
})

test_that("runtime_component() emits a scoped mount node with dependencies", {
  ns <- local_internal()

  tag <- ns$runtime_component(
    component = "fixture",
    .validate = FALSE,
    props = list(label = "Label"),
    input_id = "choice",
    children = list(htmltools::tags$span("Child"))
  )
  html <- render_html(tag)
  deps <- htmltools::findDependencies(tag)

  expect_match(html, 'data-shinyblocks-root=""', fixed = TRUE)
  expect_match(html, 'data-shinyblocks-runtime="true"', fixed = TRUE)
  expect_match(html, 'data-sb-component="fixture"', fixed = TRUE)
  expect_match(html, 'data-sb-input-id="choice"', fixed = TRUE)
  expect_match(html, 'data-shinyblocks-payload=""', fixed = TRUE)
  expect_match(html, 'data-shinyblocks-react=""', fixed = TRUE)
  expect_match(html, 'data-shinyblocks-children=""', fixed = TRUE)
  expect_match(html, ">Child<", fixed = TRUE)
  expect_identical(deps[[1]]$name, "shinyblocks")
})

test_that("runtime mount ids are deterministic for inputs and unique otherwise", {
  ns <- local_internal()

  first <- ns$runtime_component(component = "fixture", .validate = FALSE, input_id = "choice")
  second <- ns$runtime_component(component = "fixture", .validate = FALSE, input_id = "choice")
  presentational <- list(
    ns$runtime_component(component = "fixture", .validate = FALSE),
    ns$runtime_component(component = "fixture", .validate = FALSE)
  )

  expect_identical(tag_attr(first, "id"), "sb-runtime-fixture-choice")
  expect_identical(tag_attr(second, "id"), "sb-runtime-fixture-choice")
  expect_length(unique(vapply(presentational, tag_attr, character(1), "id")), 2)
})

test_that("runtime payload helpers validate inputs", {
  ns <- local_internal()

  expect_snapshot(
    ns$runtime_payload(component = ""),
    error = TRUE
  )
  expect_snapshot(
    ns$runtime_payload(component = "fixture", props = list("unnamed")),
    error = TRUE
  )
})

test_that("runtime_component() rejects unknown component names", {
  ns <- local_internal()

  expect_error(
    ns$runtime_component(component = "selct"),
    "Unknown runtime `component`"
  )
  # The allowlist constant must mirror the JS-side RUNTIME_INPUT_COMPONENTS
  # plus the non-input components dispatched by RuntimeMount.
  expect_true(all(
    c("button", "select", "checkbox", "switch", "slider") %in% ns$RUNTIME_COMPONENT_NAMES
  ))
})

test_that("runtime_component(.validate = FALSE) allows synthetic test names", {
  ns <- local_internal()

  expect_silent(
    ns$runtime_component(component = "fixture", .validate = FALSE)
  )
})

test_that("runtime_payload_json() reports a friendly error for unserialisable payloads", {
  ns <- local_internal()

  payload <- ns$runtime_payload(
    component = "fixture",
    props = list(handler = new.env())
  )

  expect_error(
    ns$runtime_payload_json(payload),
    "Runtime payload is not JSON serializable:"
  )
})

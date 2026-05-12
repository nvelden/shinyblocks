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
  expect_match(html, ">Child<", fixed = TRUE)
  expect_identical(deps[[1]]$name, "shinyblocks")
})

test_that("runtime mount ids are deterministic for inputs and unique otherwise", {
  ns <- local_internal()

  first <- ns$runtime_component(component = "fixture", input_id = "choice")
  second <- ns$runtime_component(component = "fixture", input_id = "choice")
  presentational <- list(
    ns$runtime_component(component = "fixture"),
    ns$runtime_component(component = "fixture")
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

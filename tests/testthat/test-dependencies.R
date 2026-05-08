test_that("components attach the shinyblocks dependency", {
  dependencies <- htmltools::findDependencies(block_card("Body"))

  expect_length(dependencies, 1)
  expect_identical(dependencies[[1]]$name, "shinyblocks")
  expect_identical(dependencies[[1]]$stylesheet, "shinyblocks.css")
})

test_that("repeated component dependencies resolve once", {
  rendered <- htmltools::renderTags(
    htmltools::tagList(
      block_card("Body"),
      block_button("Button"),
      block_sidebar("Item")
    )
  )

  dependency_names <- vapply(rendered$dependencies, `[[`, character(1), "name")

  expect_identical(dependency_names, "shinyblocks")
})

test_that("block_page uses htmltools dependencies for assets", {
  page <- block_page("Body", title = "Example")
  dependencies <- htmltools::findDependencies(page)
  html <- as.character(page)

  expect_length(dependencies, 1)
  expect_identical(dependencies[[1]]$name, "shinyblocks")
  expect_no_match(html, "shinyblocks/shinyblocks[.]css")
})

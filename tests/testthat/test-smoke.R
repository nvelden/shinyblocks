test_that("core helpers return tags", {
  expect_s3_class(block_sidebar("Item"), "shiny.tag")
  expect_s3_class(block_header("Header"), "shiny.tag")
  expect_s3_class(block_body("Body"), "shiny.tag")
  expect_s3_class(block_card("Body"), "shiny.tag")
  expect_s3_class(block_button("Button"), "shiny.tag")
  expect_s3_class(block_icon("search"), "shiny.tag")
})

test_that("showcase app sources without launching", {
  app_file <- system.file("showcase", "app.R", package = "shinyblocks")
  env <- new.env(parent = globalenv())

  source(app_file, local = env, chdir = TRUE)

  expect_s3_class(env$ui, "shiny.tag.list")
  expect_type(env$server, "closure")
})

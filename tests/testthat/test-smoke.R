test_that("core helpers return tags", {
  expect_s3_class(block_sidebar("Item"), "shiny.tag")
  expect_s3_class(block_header("Header"), "shiny.tag")
  expect_s3_class(block_card("Body"), "shiny.tag")
  expect_s3_class(block_button("Button"), "shiny.tag")
})

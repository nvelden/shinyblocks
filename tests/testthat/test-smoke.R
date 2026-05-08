test_that("core helpers return tags", {
  expect_s3_class(shadcn_sidebar("Item"), "shiny.tag")
  expect_s3_class(shadcn_header("Header"), "shiny.tag")
  expect_s3_class(shadcn_card("Body"), "shiny.tag")
  expect_s3_class(shadcn_button("Button"), "shiny.tag")
})

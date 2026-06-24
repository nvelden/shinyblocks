test_that("layout primitives render defaults and preserve child order", {
  stack <- block_stack("first", htmltools::tags$span("second"))
  cluster <- block_cluster("first", htmltools::tags$span("second"))
  grid <- block_grid("first", htmltools::tags$span("second"))

  expect_identical(
    tag_attr(stack, "class"),
    "sb-stack sb-layout-gap-md sb-layout-align-stretch"
  )
  expect_identical(
    tag_attr(cluster, "class"),
    paste(
      "sb-cluster sb-layout-gap-sm sb-layout-align-center",
      "sb-layout-justify-start"
    )
  )
  expect_identical(tag_attr(cluster, "data-wrap"), "true")
  expect_identical(
    tag_attr(grid, "class"),
    "sb-grid sb-layout-gap-md sb-layout-align-stretch"
  )
  expect_identical(tag_attr(grid, "style"), "--sb-grid-min:16rem;")

  for (tag in list(stack, cluster, grid)) {
    html <- render_html(tag)
    expect_lt(regexpr("first", html, fixed = TRUE), regexpr("second", html, fixed = TRUE))
  }
})

test_that("layout primitives support their complete semantic class vocabulary", {
  for (gap in c("sm", "md", "lg")) {
    expect_match(tag_attr(block_stack(gap = gap), "class"), paste0("sb-layout-gap-", gap), fixed = TRUE)
    expect_match(tag_attr(block_cluster(gap = gap), "class"), paste0("sb-layout-gap-", gap), fixed = TRUE)
    expect_match(tag_attr(block_grid(gap = gap), "class"), paste0("sb-layout-gap-", gap), fixed = TRUE)
  }

  for (align in c("stretch", "start", "center", "end")) {
    expect_match(tag_attr(block_stack(align = align), "class"), paste0("sb-layout-align-", align), fixed = TRUE)
    expect_match(tag_attr(block_grid(align = align), "class"), paste0("sb-layout-align-", align), fixed = TRUE)
    expect_match(tag_attr(block_cluster(align = align), "class"), paste0("sb-layout-align-", align), fixed = TRUE)
  }

  for (justify in c("start", "center", "end", "between")) {
    expect_match(
      tag_attr(block_cluster(justify = justify), "class"),
      paste0("sb-layout-justify-", justify),
      fixed = TRUE
    )
  }
})

test_that("cluster wrapping and grid widths are validated and serialized", {
  expect_identical(tag_attr(block_cluster(wrap = FALSE), "data-wrap"), "false")
  expect_identical(tag_attr(block_grid(min_width = 240), "style"), "--sb-grid-min:240px;")
  expect_identical(tag_attr(block_grid(min_width = "14rem"), "style"), "--sb-grid-min:14rem;")

  expect_error(block_cluster(wrap = NA), "wrap.*single TRUE or FALSE")
  expect_error(block_grid(min_width = c("12rem", "16rem")), "`min_width` must be a single valid CSS unit.", fixed = TRUE)
  expect_error(block_grid(min_width = "wide"), "`min_width` must be a single valid CSS unit.", fixed = TRUE)
})

test_that("layout primitives merge classes, allow empty containers, and nest", {
  nested <- block_stack(
    block_cluster(class = "actions"),
    block_grid(class = "cards"),
    class = "page-flow"
  )

  expect_match(tag_attr(nested, "class"), "page-flow", fixed = TRUE)
  expect_match(render_html(nested), 'class="sb-cluster', fixed = TRUE)
  expect_match(render_html(nested), 'class="sb-grid', fixed = TRUE)
  expect_s3_class(block_stack(), "shiny.tag")
  expect_s3_class(block_cluster(), "shiny.tag")
  expect_s3_class(block_grid(), "shiny.tag")
})

test_that("layout primitives reject unsupported semantic values", {
  expect_error(block_stack(gap = "xl"), '`gap` must be one of "sm", "md", "lg".', fixed = TRUE)
  expect_error(block_stack(align = "baseline"), '`align` must be one of "stretch", "start", "center", "end".', fixed = TRUE)
  expect_error(block_cluster(justify = "around"), '`justify` must be one of "start", "center", "end", "between".', fixed = TRUE)
})

test_that("layout primitives attach shinyblocks dependencies", {
  for (tag in list(block_stack(), block_cluster(), block_grid())) {
    deps <- htmltools::renderTags(tag)$dependencies
    expect_true(any(vapply(deps, function(dep) identical(dep$name, "shinyblocks"), logical(1))))
  }
})

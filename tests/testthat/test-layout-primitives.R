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
  msg <- "`min_width` must be a single non-negative CSS length or percentage"

  expect_identical(tag_attr(block_cluster(wrap = FALSE), "data-wrap"), "false")
  expect_identical(tag_attr(block_grid(min_width = 240), "style"), "--sb-grid-min:240px;")
  expect_identical(tag_attr(block_grid(min_width = "14rem"), "style"), "--sb-grid-min:14rem;")
  expect_identical(tag_attr(block_grid(min_width = "50%"), "style"), "--sb-grid-min:50%;")

  expect_error(block_cluster(wrap = NA), "wrap.*single TRUE or FALSE")
  expect_identical(tag_attr(block_grid(min_width = 0), "style"), "--sb-grid-min:0px;")
  expect_identical(tag_attr(block_grid(min_width = "0"), "style"), "--sb-grid-min:0;")

  expect_error(block_grid(min_width = c("12rem", "16rem")), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "wide"), msg, fixed = TRUE)
  # Reject values that produce invalid `min()`/`minmax()` tracks.
  expect_error(block_grid(min_width = -1), msg, fixed = TRUE)
  expect_error(block_grid(min_width = Inf), msg, fixed = TRUE)
  expect_error(block_grid(min_width = NaN), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "auto"), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "-5px"), msg, fixed = TRUE)
})

test_that("block_grid() min_width rejects CSS injection and non-length values", {
  msg <- "`min_width` must be a single non-negative CSS length or percentage"

  # Critical: validateCssUnit() accepted calc(...) containing `;`, letting
  # callers smuggle extra declarations into the inline `style` attribute.
  expect_error(
    block_grid(min_width = "calc(1px);position:fixed;inset:0;z-index:9999;foo:calc(1px)"),
    msg,
    fixed = TRUE
  )
  expect_error(block_grid(min_width = "16rem;color:red"), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "16rem;}body{display:none"), msg, fixed = TRUE)

  # calc() and other functional/keyword values are rejected outright.
  expect_error(block_grid(min_width = "calc(100% - 1rem)"), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "calc(auto)"), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "min(100%, 16rem)"), msg, fixed = TRUE)

  # CSS-wide keywords and non-length track values.
  expect_error(block_grid(min_width = "inherit"), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "initial"), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "unset"), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "fit-content"), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "max-content"), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "1fr"), msg, fixed = TRUE)

  # Malformed numerics.
  expect_error(block_grid(min_width = ""), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "16"), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "px"), msg, fixed = TRUE)
  expect_error(block_grid(min_width = "16 rem"), msg, fixed = TRUE)
  expect_error(block_grid(min_width = NA_character_), msg, fixed = TRUE)

  # A whitespace-padded valid length is accepted and trimmed.
  expect_identical(tag_attr(block_grid(min_width = " 18rem "), "style"), "--sb-grid-min:18rem;")
})

test_that("block_grid() track survives a caller-supplied style override", {
  # `style` may be passed through `...` (htmltools convention), but the
  # component-owned, validated `--sb-grid-min` must remain authoritative: it is
  # emitted last so it wins the inline-style cascade.
  attacked <- tag_attr(
    block_grid(style = "--sb-grid-min:999rem;position:fixed", min_width = "16rem"),
    "style"
  )
  expect_true(grepl("--sb-grid-min:16rem;$", attacked))
  # The validated value is the *last* declaration of the property.
  positions <- gregexpr("--sb-grid-min", attacked, fixed = TRUE)[[1]]
  last <- substring(attacked, positions[length(positions)])
  expect_match(last, "^--sb-grid-min:16rem;", fixed = FALSE)

  # A benign caller style is preserved alongside the managed track.
  benign <- tag_attr(block_grid(style = "color:red", min_width = "20rem"), "style")
  expect_match(benign, "color:red", fixed = TRUE)
  expect_true(grepl("--sb-grid-min:20rem;$", benign))
})

test_that("layout primitives forward named arguments as container attributes", {
  expect_match(render_html(block_stack(id = "flow")), 'id="flow"', fixed = TRUE)
  expect_match(
    render_html(block_cluster(`aria-label` = "Actions")),
    'aria-label="Actions"',
    fixed = TRUE
  )
  expect_match(
    render_html(block_grid(`data-region` = "metrics")),
    'data-region="metrics"',
    fixed = TRUE
  )
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

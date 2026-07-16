# R-side composition primitives: shadcn frames around shiny::imageOutput() /
# shiny::plotOutput(). No runtime payload, so we assert on the tag tree.

media_box <- function(frame) frame$children[[1]]
output_tag <- function(frame) media_box(frame)$children[[1]]
caption_tag <- function(frame) frame$children[[2]]

test_that("block_image_output builds the figure -> media -> output structure", {
  frame <- block_image_output("img", caption = "Fig 1", border = TRUE)

  expect_identical(frame$name, "figure")
  expect_identical(tag_attr(frame, "class"), "sb-output-frame sb-image-output")
  expect_identical(tag_attr(frame, "data-shinyblocks-scope"), "")

  media <- media_box(frame)
  expect_identical(media$name, "div")
  expect_identical(tag_attr(media, "class"), "sb-output-media")

  out <- output_tag(frame)
  expect_identical(tag_attr(out, "id"), "img")
  expect_match(tag_attr(out, "class"), "shiny-image-output")

  # figcaption is a SIBLING of the media box (D2), not inside it.
  cap <- caption_tag(frame)
  expect_identical(cap$name, "figcaption")
  expect_identical(tag_attr(cap, "class"), "sb-output-caption")
  expect_identical(cap$children[[1]], "Fig 1")
})

test_that("block_plot_output wraps shiny::plotOutput()", {
  frame <- block_plot_output("p")

  expect_identical(tag_attr(frame, "class"), "sb-output-frame sb-plot-output")
  out <- output_tag(frame)
  expect_match(tag_attr(out, "class"), "shiny-plot-output")
  expect_identical(tag_attr(out, "id"), "p")
})

test_that("frames attach the shinyblocks html dependency", {
  expect_true(length(htmltools::findDependencies(block_image_output("a"))) > 0)
  expect_true(length(htmltools::findDependencies(block_plot_output("b"))) > 0)
})

test_that("no caption means no figcaption sibling", {
  frame <- block_image_output("img")
  expect_null(caption_tag(frame))
  expect_no_match(render_html(frame), "figcaption")
})

test_that("aspect/border/rounded land as data-* on the media box, not the figure", {
  frame <- block_image_output(
    "img", aspect = "16/9", border = TRUE, rounded = TRUE
  )
  media <- media_box(frame)

  expect_true(!is.null(tag_attr(media, "data-aspect")))
  expect_true(!is.null(tag_attr(media, "data-border")))
  expect_true(!is.null(tag_attr(media, "data-rounded")))
  expect_match(tag_attr(media, "style"), "--sb-output-aspect:16/9", fixed = TRUE)
  expect_match(tag_attr(media, "style"), "--sb-output-fit:cover", fixed = TRUE)

  # none of these leak onto the figure wrapper
  expect_null(tag_attr(frame, "data-aspect"))
  expect_null(tag_attr(frame, "data-border"))
})

test_that("rounded defaults TRUE, border defaults FALSE", {
  media <- media_box(block_image_output("img"))
  expect_true(!is.null(tag_attr(media, "data-rounded")))
  expect_null(tag_attr(media, "data-border"))
  expect_null(tag_attr(media, "data-aspect"))
})

test_that("aspect accepts a positive number", {
  media <- media_box(block_plot_output("p", aspect = 1.5))
  expect_match(tag_attr(media, "style"), "--sb-output-aspect:1.5", fixed = TRUE)
})

test_that("aspect rejects invalid values", {
  expect_error(block_image_output("img", aspect = -1), "aspect")
  expect_error(block_image_output("img", aspect = "16/0"), "aspect")
  expect_error(block_image_output("img", aspect = "wide"), "aspect")
  expect_error(block_image_output("img", aspect = c(1, 2)), "aspect")
})

test_that("fit is validated via match_arg", {
  expect_error(block_image_output("img", fit = "stretch"), "fit")
  media <- media_box(block_image_output("img", fit = "contain"))
  expect_match(tag_attr(media, "style"), "--sb-output-fit:contain", fixed = TRUE)
})

test_that("logical args are validated", {
  expect_error(block_image_output("img", border = "yes"), "border")
  expect_error(block_image_output("img", rounded = NA), "rounded")
  expect_error(block_image_output("img", inline = 1), "inline")
  expect_error(block_plot_output("p", fill = c(TRUE, FALSE)), "fill")
})

test_that("id must be a non-empty string", {
  expect_error(block_image_output(""), "non-empty")
  expect_error(block_image_output(c("a", "b")), "id")
})

test_that("caption must be a string or NULL", {
  expect_error(block_image_output("img", caption = 1), "caption")
})

test_that("fill default differs per function (D4)", {
  # imageOutput default fill = FALSE -> no html-fill-item class
  expect_no_match(render_html(block_image_output("img")), "html-fill-item")

  # plotOutput default fill = !inline -> TRUE -> html-fill-item class
  expect_match(render_html(block_plot_output("p")), "html-fill-item")

  # plotOutput inline = TRUE -> fill = FALSE
  expect_no_match(render_html(block_plot_output("p", inline = TRUE)), "html-fill-item")
})

test_that("custom width sizes the media box, not only the Shiny output", {
  # Otherwise the (block-level) framed media box stays full-width while the
  # Shiny output shrinks to `width`, so border/aspect chrome diverges (D2).
  media <- media_box(block_image_output("img", width = "300px"))
  expect_match(tag_attr(media, "style"), "width:300px", fixed = TRUE)

  out <- output_tag(block_image_output("img", width = "300px"))
  expect_match(tag_attr(out, "style"), "width:300px", fixed = TRUE)
})

test_that("default width also lands on the media box", {
  media <- media_box(block_plot_output("p"))
  expect_match(tag_attr(media, "style"), "width:100%", fixed = TRUE)
})

test_that("width/height/click/brush forward to the Shiny output", {
  html <- render_html(block_image_output(
    "img", width = "300px", height = "200px", click = "cl", brush = "br"
  ))
  expect_match(html, "width:300px", fixed = TRUE)
  expect_match(html, "height:200px", fixed = TRUE)
  expect_match(html, 'data-click-id="cl"', fixed = TRUE)
  expect_match(html, 'data-brush-id="br"', fixed = TRUE)
})

test_that("height = NULL resolves to 100% with aspect, Shiny default without", {
  with_aspect <- output_tag(block_image_output("img", aspect = "16/9"))
  expect_match(tag_attr(with_aspect, "style"), "height:100%", fixed = TRUE)

  no_aspect <- output_tag(block_image_output("img"))
  expect_match(tag_attr(no_aspect, "style"), "height:400px", fixed = TRUE)
})

test_that("rendered frames match snapshot", {
  expect_snapshot(cat(render_html(
    block_image_output("img", aspect = "16/9", border = TRUE, caption = "A photo")
  )))
  expect_snapshot(cat(render_html(
    block_plot_output("plot", border = TRUE, rounded = FALSE)
  )))
})

# Styled frames around Shiny's two reactive raster outputs. These are R-side
# composition primitives (like `block_field_*()`), NOT runtime-payload
# components: `htmltools` wraps `shiny::imageOutput()` / `shiny::plotOutput()`
# with package classes via `attach_shinyblocks_deps()`. shinyblocks owns the
# frame (aspect box, object-fit, border, radius, caption); Shiny keeps owning
# the content (temp-file serving, content-type, resize/recalc, click/brush).

# Resolve `aspect` to a CSS `aspect-ratio` value or NULL. Accepts a positive
# finite numeric or a "w/h" string with positive finite parts; anything else
# errors. (D2 — the value rides on `.sb-output-media`, never the figure.)
resolve_aspect <- function(aspect) {
  if (is.null(aspect)) {
    return(NULL)
  }

  if (is.numeric(aspect)) {
    if (length(aspect) != 1 || !is.finite(aspect) || aspect <= 0) {
      stop("`aspect` must be a single positive number.", call. = FALSE)
    }
    return(format(aspect, trim = TRUE, scientific = FALSE))
  }

  if (is.character(aspect) && length(aspect) == 1 && !is.na(aspect)) {
    parts <- strsplit(trimws(aspect), "/", fixed = TRUE)[[1]]
    if (length(parts) == 2) {
      nums <- suppressWarnings(as.numeric(trimws(parts)))
      if (all(is.finite(nums)) && all(nums > 0)) {
        return(paste(format(nums, trim = TRUE, scientific = FALSE), collapse = "/"))
      }
    }
  }

  stop(
    "`aspect` must be NULL, a positive number, or a \"w/h\" string with positive parts.",
    call. = FALSE
  )
}

# kind: "image" | "plot". Box chrome (aspect/border/radius/overflow) lives on
# the INNER media box, never on the <figure> — so the caption sibling is not
# clipped by the aspect box (D2). `width` is mirrored onto the media box (which
# also carries the border/aspect chrome) AND forwarded to the Shiny output, so
# the frame and its content always share one width — a block-level media box
# would otherwise stay full-width while the Shiny output shrank to `width`.
output_frame <- function(output_tag, kind, width, aspect, fit, border, rounded,
                         caption, class, style) {
  check_flag(border, "border")
  check_flag(rounded, "rounded")
  check_string(caption, "caption", null_ok = TRUE)

  frame_class <- switch(
    kind,
    image = "sb-output-frame sb-image-output",
    plot = "sb-output-frame sb-plot-output"
  )

  aspect_value <- resolve_aspect(aspect)
  media_style <- paste0(
    if (!is.null(width)) paste0("width:", width, ";"),
    # Plots render to the box size, so `object-fit` is meaningless for them and
    # `fit` is NULL — only image frames carry `--sb-output-fit`.
    if (!is.null(fit)) paste0("--sb-output-fit:", fit, ";"),
    if (!is.null(aspect_value)) paste0("--sb-output-aspect:", aspect_value, ";")
  )

  media <- htmltools::tags$div(
    class = "sb-output-media",
    `data-aspect` = if (!is.null(aspect_value)) NA else NULL,
    `data-border` = if (isTRUE(border)) NA else NULL,
    `data-rounded` = if (isTRUE(rounded)) NA else NULL,
    style = media_style,
    output_tag
  )

  attach_shinyblocks_deps(
    htmltools::tags$figure(
      class = merge_classes(frame_class, class),
      style = style,
      media,
      if (!is.null(caption)) {
        htmltools::tags$figcaption(class = "sb-output-caption", caption)
      }
    ),
    # Output-frame standalone behavior is implemented and verified in #111.
    scope = FALSE
  )
}

# Shared arg validation + Shiny-output construction for both public functions.
# Frame-only args (border/rounded/caption) are validated in `output_frame()`,
# which is where they are actually consumed.
build_output <- function(output_fn, id, width, height, aspect,
                         click, dblclick, hover, brush, inline, fill) {
  check_string(id, "id")
  if (!nzchar(id)) {
    stop("`id` must be a non-empty string.", call. = FALSE)
  }
  check_flag(inline, "inline")
  check_flag(fill, "fill")

  # height = NULL resolves to "100%" when aspect is set so the Shiny output
  # fills the aspect box; without aspect, omit it so Shiny applies its own
  # default ("400px") rather than us duplicating it (D4).
  if (is.null(height) && !is.null(aspect)) {
    height <- "100%"
  }

  args <- list(
    outputId = id,
    width = width,
    click = click,
    dblclick = dblclick,
    hover = hover,
    brush = brush,
    inline = inline,
    fill = fill
  )
  if (!is.null(height)) {
    args$height <- height
  }

  do.call(output_fn, args)
}

#' Frame a reactive image output
#'
#' Wraps [shiny::imageOutput()] in a shadcn-styled frame (aspect box,
#' object-fit, border, radius, optional caption). App-author server code stays
#' vanilla Shiny: `output$id <- shiny::renderImage(...)` is unchanged. The
#' image's accessible name (`alt`) is server-controlled via
#' [shiny::renderImage()]'s returned `alt`; the frame cannot set it.
#'
#' For *static* images use [htmltools::img()] — no component needed. Interactive
#' htmlwidgets (plotly, leaflet, DT, ...) are a different mechanism and out of
#' scope.
#'
#' @param id Shiny output id, passed verbatim to [shiny::imageOutput()].
#' @param width,height CSS lengths forwarded to the Shiny output. `height =
#'   NULL` resolves to `"100%"` when `aspect` is set, otherwise Shiny's default.
#' @param aspect Aspect ratio for the media box: `NULL`, a positive number, or a
#'   `"w/h"` string (e.g. `"16/9"`).
#' @param fit `object-fit` for the rendered image. One of `"cover"`,
#'   `"contain"`, `"fill"`, `"none"`, `"scale-down"`.
#' @param border Draw a border around the media box.
#' @param rounded Round the media box corners (and clip overflow).
#' @param caption Optional `<figcaption>` text shown below the image.
#' @param click,dblclick,hover,brush Forwarded to the Shiny output unchanged.
#' @param inline,fill Forwarded to the Shiny output. `fill` defaults to `FALSE`
#'   to match [shiny::imageOutput()].
#' @param class Additional classes for the `<figure>` wrapper.
#' @param style Inline style for the `<figure>` wrapper.
#'
#' @return An `htmltools` `<figure>` tag.
#' @family outputs
#' @export
block_image_output <- function(id,
                               width = "100%",
                               height = NULL,
                               aspect = NULL,
                               fit = c("cover", "contain", "fill", "none", "scale-down"),
                               border = FALSE,
                               rounded = TRUE,
                               caption = NULL,
                               click = NULL,
                               dblclick = NULL,
                               hover = NULL,
                               brush = NULL,
                               inline = FALSE,
                               fill = FALSE,
                               class = NULL,
                               style = NULL) {
  fit <- match_arg(fit, c("cover", "contain", "fill", "none", "scale-down"))

  output_tag <- build_output(
    output_fn = shiny::imageOutput, id = id, width = width, height = height,
    aspect = aspect, click = click, dblclick = dblclick, hover = hover,
    brush = brush, inline = inline, fill = fill
  )

  output_frame(
    output_tag, kind = "image", width = width, aspect = aspect, fit = fit,
    border = border, rounded = rounded, caption = caption, class = class,
    style = style
  )
}

#' Frame a reactive plot output
#'
#' Wraps [shiny::plotOutput()] in a shadcn-styled frame (aspect box, border,
#' radius, optional caption). App-author server code stays vanilla Shiny:
#' `output$id <- shiny::renderPlot(...)` is unchanged. Covers base graphics,
#' ggplot2, and lattice. The plot's accessible name (`alt`) is server-controlled
#' via [shiny::renderPlot()]'s `alt`; the frame cannot set it.
#'
#' Unlike [block_image_output()] there is no `fit` argument: [shiny::renderPlot()]
#' already renders to the media box size, so `object-fit` would have no visible
#' effect.
#'
#' @inheritParams block_image_output
#' @param id Shiny output id, passed verbatim to [shiny::plotOutput()].
#' @param caption Optional `<figcaption>` text shown below the plot.
#' @param inline,fill Forwarded to the Shiny output. `fill` defaults to
#'   `!inline` to match [shiny::plotOutput()].
#'
#' @return An `htmltools` `<figure>` tag.
#' @family outputs
#' @export
block_plot_output <- function(id,
                              width = "100%",
                              height = NULL,
                              aspect = NULL,
                              border = FALSE,
                              rounded = TRUE,
                              caption = NULL,
                              click = NULL,
                              dblclick = NULL,
                              hover = NULL,
                              brush = NULL,
                              inline = FALSE,
                              fill = !inline,
                              class = NULL,
                              style = NULL) {
  output_tag <- build_output(
    output_fn = shiny::plotOutput, id = id, width = width, height = height,
    aspect = aspect, click = click, dblclick = dblclick, hover = hover,
    brush = brush, inline = inline, fill = fill
  )

  output_frame(
    output_tag, kind = "plot", width = width, aspect = aspect, fit = NULL,
    border = border, rounded = rounded, caption = caption, class = class,
    style = style
  )
}

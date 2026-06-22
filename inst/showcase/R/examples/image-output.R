local({
  # A tiny inline SVG (data URI) so the static frame ships a real <img> element
  # that exercises the container-sizing + object-fit CSS without a live server.
  placeholder_src <- paste0(
    "data:image/svg+xml,",
    utils::URLencode(paste0(
      "<svg xmlns='http://www.w3.org/2000/svg' width='320' height='180'>",
      "<rect width='320' height='180' fill='hsl(220 14% 90%)'/>",
      "<text x='50%' y='50%' fill='hsl(220 9% 46%)' font-family='sans-serif' ",
      "font-size='16' text-anchor='middle' dominant-baseline='middle'>",
      "placeholder image</text></svg>"
    ), reserved = TRUE)
  )

  htmltools::tagList(
    htmltools::tags$p(
      style = "color: var(--muted-foreground); margin: 0;",
      paste(
        "block_image_output() / block_plot_output() wrap shiny::imageOutput() /",
        "shiny::plotOutput() in a shadcn-styled frame (aspect box, object-fit,",
        "border, radius, caption). The full live playground lands in Slice 3."
      )
    ),
    htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "Static frame"),
    htmltools::tags$p(
      style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
      paste(
        "A hand-built frame with a real <img> (no live server) so the media-box",
        "aspect/border/radius and object-fit CSS are exercised before Slice 3",
        "wires live renderImage()/renderPlot() demos."
      )
    ),
    htmltools::div(
      style = "max-width: 28rem;",
      htmltools::tags$figure(
        class = "sb-output-frame sb-image-output",
        htmltools::tags$div(
          class = "sb-output-media",
          `data-aspect` = NA,
          `data-border` = NA,
          `data-rounded` = NA,
          style = "--sb-output-fit:cover; --sb-output-aspect:16/9;",
          htmltools::img(src = placeholder_src, alt = "Placeholder image inside a styled frame.")
        ),
        htmltools::tags$figcaption(
          class = "sb-output-caption",
          "16/9 frame, cover fit, bordered + rounded media box."
        )
      )
    ),
    htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "Parity fixtures"),
    htmltools::tags$p(
      style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
      "Stable instances captured by tools/parity/. Do not remove."
    ),
    htmltools::div(
      style = "display: flex; flex-direction: column; gap: 1rem; max-width: 28rem;",
      # A real block_image_output(): an empty Shiny output container (no render
      # wired here) — enough for the border/caption theme bindings.
      block_image_output(
        "parity_image_output",
        aspect = "16/9",
        border = TRUE,
        caption = "Bordered, captioned block_image_output() frame.",
        class = "sb-parity-image-output"
      )
    )
  )
})

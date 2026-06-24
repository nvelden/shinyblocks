# Static gallery preview. block_image_output() frames shiny::imageOutput(),
# which renders empty without a running Shiny server, so this mirrors the real
# component frame (the same .sb-output-* classes and CSS) with representative
# sample artwork in the media box. See the playground for live renderImage()
# usage: output$id <- shiny::renderImage(...).
artwork <- htmltools::HTML(
  '<svg viewBox="0 0 320 180" preserveAspectRatio="xMidYMid slice" width="100%" height="100%" role="img" aria-label="Server-rendered campaign artwork">
  <defs><linearGradient id="sb-art" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#7c3aed"/><stop offset="1" stop-color="#ec4899"/></linearGradient></defs>
  <rect width="320" height="180" fill="url(#sb-art)"/>
  <circle cx="250" cy="54" r="34" fill="#fde68a" opacity="0.92"/>
  <path d="M0 180 L70 108 L120 150 L190 92 L260 150 L320 118 L320 180 Z" fill="#1e1b4b" opacity="0.55"/>
  <path d="M0 180 L92 134 L150 166 L232 124 L320 158 L320 180 Z" fill="#1e1b4b" opacity="0.82"/>
</svg>'
)

htmltools::tags$figure(
  class = "sb-output-frame sb-image-output",
  htmltools::tags$div(
    class = "sb-output-media",
    `data-aspect` = NA, `data-border` = NA, `data-rounded` = NA,
    style = "width:100%;--sb-output-fit:cover;--sb-output-aspect:16/9;",
    artwork
  ),
  htmltools::tags$figcaption(
    class = "sb-output-caption",
    "Server-rendered campaign artwork"
  )
)

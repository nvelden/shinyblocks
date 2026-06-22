htmltools::tagList(
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0;",
    paste(
      "block_image_output() / block_plot_output() wrap shiny::imageOutput() /",
      "shiny::plotOutput() in a shadcn-styled frame (aspect box, object-fit,",
      "border, radius, caption). The full live playground lands in Slice 3."
    )
  ),
  htmltools::tags$h3(style = "margin-top: 2rem; font-size: 1.125rem;", "Parity fixtures"),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instances captured by tools/parity/. Do not remove."
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 1rem; max-width: 28rem;",
    block_image_output(
      "parity_image_output",
      aspect = "16/9",
      border = TRUE,
      caption = "Bordered, captioned image-output frame (static placeholder).",
      class = "sb-parity-image-output"
    )
  )
)

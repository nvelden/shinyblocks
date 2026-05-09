htmltools::tagList(
  block_theme(
    primary = "oklch(0.58 0.22 262)",
    radius = "0.5rem"
  ),
  htmltools::div(
    style = paste(
      "display: flex;",
      "flex-wrap: wrap;",
      "gap: 0.75rem;",
      "align-items: center;"
    ),
    block_dark_mode_toggle(),
    block_button("Primary", icon = "sun"),
    block_button("Outline", variant = "outline")
  ),
  block_card(
    title = "Theme overrides",
    description = "Scoped token overrides plus persisted dark mode.",
    paste(
      "This card and the buttons above are driven by the local",
      "block_theme() overrides."
    )
  )
)

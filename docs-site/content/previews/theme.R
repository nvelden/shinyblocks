htmltools::tagList(
  shinyblocks::block_theme(
    accent = "oklch(0.6 0.15 150)",
    radius = "1rem"
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 1rem; border: 1px solid var(--border); border-radius: var(--radius);",
    htmltools::div(style = "font-size: 0.875rem; font-weight: 500; margin-bottom: 0.5rem;", "Theme Override Canvas"),
    shinyblocks::block_button("Accent Button", size = "sm")
  )
)

htmltools::tagList(
  shinyblocks::block_style("luma", scope = ".sb-style-preview-canvas")$style,
  htmltools::div(
    class = "sb-style-preview-canvas",
    `data-sb-style` = "luma",
    style = "display: flex; flex-direction: column; gap: 0.75rem; align-items: center; justify-content: center; padding: 1rem; border: 1px solid var(--border); border-radius: var(--radius);",
    htmltools::div(style = "font-size: 0.875rem; font-weight: 500;", "Luma Style Profile"),
    htmltools::div(
      style = "display: flex; gap: 0.5rem; align-items: center;",
      shinyblocks::block_button("Luma Button", size = "sm"),
      shinyblocks::block_badge("Luma", variant = "secondary")
    )
  )
)

htmltools::div(
  style = "width: 100%; max-width: 300px; margin: 0 auto; padding: 1rem;",
  htmltools::div(
    style = "font-weight: 500; font-size: 0.875rem; line-height: 1.25rem;",
    "shinyblocks"
  ),
  htmltools::div(
    style = "font-size: 0.875rem; line-height: 1.25rem; color: var(--muted-foreground);",
    "An open-source dashboard library."
  ),
  htmltools::div(
    style = "margin: 0.75rem 0;",
    shinyblocks::block_separator()
  ),
  htmltools::div(
    style = "height: 1.25rem; font-size: 0.875rem; line-height: 1.25rem; color: var(--muted-foreground);",
    shinyblocks::block_cluster(
      gap = "md",
      align = "center",
      wrap = FALSE,
      htmltools::div("Blog"),
      shinyblocks::block_separator(orientation = "vertical"),
      htmltools::div("Docs"),
      shinyblocks::block_separator(orientation = "vertical"),
      htmltools::div("Source")
    )
  )
)

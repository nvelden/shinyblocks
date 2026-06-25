htmltools::div(
  style = paste(
    "width: 100%; max-width: 200px; border: 1px solid var(--border);",
    "border-radius: 0.375rem; padding: 0.5rem;"
  ),
  shinyblocks::block_stack(
    gap = "sm",
    shinyblocks::block_nav_item("Dashboard", href = "#", icon = "layout-dashboard", selected = TRUE),
    shinyblocks::block_nav_item("Settings", href = "#", icon = "settings")
  )
)

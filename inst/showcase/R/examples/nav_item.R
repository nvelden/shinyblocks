htmltools::div(
  style = paste(
    "background: var(--sidebar);",
    "color: var(--sidebar-foreground);",
    "padding: 0.75rem;",
    "border-radius: 0.5rem;",
    "max-width: 18rem;"
  ),
  block_nav(
    class = "sb-sidebar-nav",
    block_nav_item("Home", icon = "home", selected = TRUE),
    block_nav_item("Reports", icon = "file-text"),
    block_nav_item("Users", icon = "users"),
    block_nav_item("Settings", icon = "settings")
  )
)

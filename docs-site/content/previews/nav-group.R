htmltools::div(
  style = paste(
    "background: var(--sidebar); color: var(--sidebar-foreground);",
    "padding: 0.75rem; border: 1px solid var(--border);",
    "border-radius: 0.5rem; max-width: 18rem; margin: 0 auto;"
  ),
  shinyblocks::block_nav(
    class = "sb-sidebar-nav",
    shinyblocks::block_nav_label("Workspace"),
    shinyblocks::block_nav_item(
      "Dashboard",
      value = "dashboard",
      icon = "layout-dashboard",
      selected = TRUE
    ),
    shinyblocks::block_nav_label("Management"),
    shinyblocks::block_nav_group(
      "Operations",
      shinyblocks::block_nav_item("Users", value = "users", icon = "users"),
      shinyblocks::block_nav_item("Orders", value = "orders", icon = "clipboard"),
      icon = "folder",
      value = "operations",
      expanded = FALSE
    )
  )
)

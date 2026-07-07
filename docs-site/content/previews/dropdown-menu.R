# Static gallery preview of the *open* dropdown menu (block_dropdown_menu()
# only shows its trigger until the runtime opens the portaled menu on click).
# Uses the real .sb-dropdown-menu-* / .sb-button classes (under
# data-shinyblocks-root + -portal-root so both resolve). See the playground
# for live block_dropdown_menu() usage.
shinyblocks::block_stack(
  gap = "sm",
  align = "center",
  `data-shinyblocks-root` = NA,
  `data-shinyblocks-portal-root` = NA,
  htmltools::tags$button(
    class = "sb-button sb-button-outline sb-button-size-default sb-dropdown-menu-trigger",
    `data-slot` = "dropdown-menu-trigger",
    type = "button",
    "Open menu"
  ),
  htmltools::tags$div(
    class = "sb-dropdown-menu-content",
    `data-slot` = "dropdown-menu-content",
    style = "position:static;min-width:12rem;",
    htmltools::tags$div(
      class = "sb-dropdown-menu-label",
      `data-slot` = "dropdown-menu-label",
      "My Account"
    ),
    htmltools::tags$div(
      class = "sb-dropdown-menu-item",
      `data-slot` = "dropdown-menu-item",
      `data-highlighted` = "true",
      htmltools::tags$span(class = "sb-dropdown-menu-item-label", "Profile"),
      htmltools::tags$span(class = "sb-dropdown-menu-shortcut", "⌘P")
    ),
    htmltools::tags$div(
      class = "sb-dropdown-menu-item",
      `data-slot` = "dropdown-menu-item",
      htmltools::tags$span(class = "sb-dropdown-menu-item-label", "Settings")
    ),
    htmltools::tags$div(
      class = "sb-dropdown-menu-separator",
      `data-slot` = "dropdown-menu-separator"
    ),
    htmltools::tags$div(
      class = "sb-dropdown-menu-item",
      `data-slot` = "dropdown-menu-item",
      `data-variant` = "destructive",
      htmltools::tags$span(class = "sb-dropdown-menu-item-label", "Delete account")
    )
  )
)

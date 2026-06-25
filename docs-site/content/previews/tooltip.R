# Static gallery preview of the *open* tooltip (block_tooltip() only shows its
# trigger until the runtime opens the portaled bubble on hover/focus). Uses the
# real .sb-tooltip-content / .sb-button classes (under data-shinyblocks-root +
# -portal-root so both resolve). See the playground for live block_tooltip()
# usage.
shinyblocks::block_stack(
  gap = "sm",
  align = "center",
  `data-shinyblocks-root` = NA,
  `data-shinyblocks-portal-root` = NA,
  htmltools::tags$div(
    class = "sb-tooltip-content",
    `data-slot` = "tooltip-content",
    role = "tooltip",
    style = "position:static;",
    "Clicking is not required to view this hint."
  ),
  htmltools::tags$button(
    class = "sb-button sb-button-outline sb-button-size-default",
    `data-slot` = "tooltip-trigger",
    type = "button",
    "Hover me"
  )
)

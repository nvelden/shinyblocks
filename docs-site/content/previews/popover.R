# Static gallery preview of the *open* popover (block_popover() only shows its
# trigger until the runtime opens the portaled panel on click). Uses the real
# .sb-popover-content / .sb-button classes (under data-shinyblocks-root +
# -portal-root so both resolve). See the playground for live block_popover()
# usage.
htmltools::tags$div(
  `data-shinyblocks-root` = NA,
  `data-shinyblocks-portal-root` = NA,
  style = "display:flex;flex-direction:column;align-items:center;gap:0.625rem;",
  htmltools::tags$button(
    class = "sb-button sb-button-default sb-button-size-default",
    `data-slot` = "popover-trigger",
    type = "button",
    "View Details"
  ),
  htmltools::tags$div(
    class = "sb-popover-content",
    `data-slot` = "popover-content",
    style = "position:static;max-width:18rem;",
    "This is a premium, portal-rendered popover content styled with shadcn presets."
  )
)

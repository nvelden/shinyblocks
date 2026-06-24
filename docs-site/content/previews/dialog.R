# Static gallery preview. block_dialog() renders only its trigger until the
# runtime opens the portaled dialog on click, so a static preview would show an
# empty box. This mirrors the *open* dialog with the real .sb-dialog-* /
# .sb-button classes (under data-shinyblocks-root + -portal-root so both the
# button and overlay styles resolve), with the fixed-overlay positioning
# neutralised so it sits inside the card. See the playground for live
# block_dialog() usage.
shinyblocks::block_cluster(
  justify = "center",
  `data-shinyblocks-root` = NA,
  `data-shinyblocks-portal-root` = NA,
  style = "width:100%;",
  htmltools::tags$div(
    class = "sb-dialog-content sb-dialog-content-size-default",
    `data-slot` = "dialog-content",
    role = "dialog",
    style = "position:relative;top:auto;left:auto;transform:none;width:18rem;max-width:100%;max-height:none;gap:1rem;box-sizing:border-box;",
    htmltools::tags$div(
      class = "sb-dialog-header",
      `data-slot` = "dialog-header",
      htmltools::tags$div(class = "sb-dialog-title", "Edit Profile"),
      htmltools::tags$div(
        class = "sb-dialog-description",
        "Make changes to your profile here. Click save when you're done."
      )
    ),
    htmltools::tags$div(
      class = "sb-dialog-footer",
      `data-slot` = "dialog-footer",
      htmltools::tags$button(
        class = "sb-button sb-button-default sb-button-size-sm",
        `data-slot` = "button",
        type = "button",
        "Save changes"
      )
    ),
    htmltools::tags$button(
      class = "sb-dialog-close",
      `data-slot` = "dialog-close",
      type = "button",
      `aria-label` = "Close",
      htmltools::HTML("&times;")
    )
  )
)

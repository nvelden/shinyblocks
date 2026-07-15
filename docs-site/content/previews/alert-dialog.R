shinyblocks::block_cluster(
  justify = "center",
  `data-shinyblocks-root` = NA,
  `data-shinyblocks-portal-root` = NA,
  style = "width:100%;",
  htmltools::tags$div(
    class = "sb-dialog-content sb-alert-dialog-content sb-dialog-content-size-default",
    role = "alertdialog",
    style = "position:relative;top:auto;left:auto;transform:none;width:20rem;max-width:100%;",
    htmltools::tags$div(
      class = "sb-dialog-header",
      htmltools::tags$div(class = "sb-dialog-title", "Delete account?"),
      htmltools::tags$div(class = "sb-dialog-description", "This action cannot be undone.")
    ),
    htmltools::tags$div(
      class = "sb-dialog-footer",
      htmltools::tags$button(class = "sb-button sb-button-outline sb-button-size-sm", "Cancel"),
      htmltools::tags$button(class = "sb-button sb-button-destructive sb-button-size-sm", "Delete")
    )
  )
)

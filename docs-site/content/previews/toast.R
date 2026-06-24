# Toasts are fired from the server with show_toast() onto a block_toaster().
# This static preview shows the rendered toast surface (it reuses the
# block_alert() variant + icon styling).
toast_card <- function(title, description, variant, icon_name) {
  htmltools::tags$div(
    class = paste("sb-toast", paste0("sb-toast-", variant)),
    `data-slot` = "toast",
    htmltools::tags$div(
      class = "sb-toast-icon",
      shinyblocks::block_icon(icon_name, size = "sm")
    ),
    htmltools::tags$div(
      class = "sb-toast-content",
      htmltools::tags$div(class = "sb-toast-title", title),
      htmltools::tags$div(class = "sb-toast-description", description)
    ),
    htmltools::tags$button(
      class = "sb-toast-close",
      `aria-label` = "Dismiss",
      htmltools::HTML("&times;")
    )
  )
}

shinyblocks::block_stack(
  gap = "sm",
  `data-shinyblocks-portal-root` = "",
  style = "position: relative; width: 100%; max-width: 360px; margin: 0 auto;",
  toast_card("Changes saved", "Your profile has been updated.", "success", "check-circle"),
  toast_card("Storage almost full", "You have used 90% of your space.", "warning", "alert-triangle")
)

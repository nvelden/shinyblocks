shinyblocks::block_alert(
  title = "Update Available",
  description = "A new version of the dashboard is available. Please refresh the page.",
  icon = "info"
)
shinyblocks::block_alert("Payment received", variant = "success")
shinyblocks::block_alert("Needs review", variant = "warning")
shinyblocks::block_alert("Sync active", variant = "info")

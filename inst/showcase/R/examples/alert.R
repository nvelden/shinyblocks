htmltools::tagList(
  block_alert(
    "Heads up",
    description = "shinyblocks alerts surface important inline messages."
  ),
  block_alert(
    "Build failed",
    description = paste(
      "Three components failed to render.",
      "Check the console for details."
    ),
    variant = "destructive",
    icon = "alert-triangle"
  ),
  block_alert(
    block_alert_title("Composed slots"),
    description = block_alert_description(
      "Pass pre-built ", htmltools::tags$code("block_alert_title()"),
      " and ", htmltools::tags$code("block_alert_description()"),
      " tags to compose richer content."
    ),
    icon = "info"
  )
)

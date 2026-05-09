htmltools::div(
  style = paste(
    "display: grid;",
    "grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));",
    "gap: 1rem;"
  ),
  block_value_box(
    "Net revenue",
    "$42k",
    description = "Up 12% month over month.",
    icon = "trending-up"
  ),
  block_value_box(
    "Open incidents",
    "7",
    description = "Two require immediate response.",
    icon = "alert-triangle"
  ),
  block_value_box(
    "Team seats",
    "24",
    block_badge("Healthy", variant = "secondary"),
    description = "No pending invites.",
    icon = "users"
  )
)

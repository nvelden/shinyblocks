htmltools::div(
  style = "display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1rem;",
  block_card(
    title = "Active users",
    value = "1,284",
    "Up 8% from last week."
  ),
  block_card(
    title = "Pending tickets",
    value = "37",
    "Investigate the spike on Tuesday."
  ),
  block_card(
    title = "Plain card",
    "Cards can also be used as plain surfaces for grouped content without a numeric value slot."
  )
)

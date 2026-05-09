htmltools::div(
  style = paste(
    "display: grid;",
    "grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));",
    "gap: 1rem;"
  ),
  block_card(
    block_card_header(
      block_card_title("Revenue"),
      block_card_description("Last 30 days")
    ),
    block_card_content(
      htmltools::tags$div(class = "sb-card-value", "$42k"),
      "Up 12% month over month."
    ),
    block_card_footer(block_button("View report", variant = "outline"))
  ),
  block_card(
    title = "Active users",
    description = "Weekly snapshot",
    value = "1,284",
    footer = block_badge("Healthy", variant = "secondary"),
    "Up 8% from last week."
  ),
  block_card(
    title = "Plain card",
    paste(
      "Cards can also be used as plain surfaces for grouped content",
      "without a numeric value slot."
    )
  )
)

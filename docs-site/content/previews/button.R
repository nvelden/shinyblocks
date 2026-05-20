htmltools::div(
  style = "display: flex; gap: 0.75rem; align-items: center; justify-content: center; padding: 1rem; flex-wrap: wrap;",
  shinyblocks::block_button("Default"),
  shinyblocks::block_button("Secondary", variant = "secondary"),
  shinyblocks::block_button("Outline", variant = "outline"),
  shinyblocks::block_button("Destructive", variant = "destructive")
)

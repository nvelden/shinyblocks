htmltools::div(
  style = "padding: 1rem;",
  shinyblocks::block_cluster(
    gap = "sm",
    justify = "center",
    shinyblocks::block_badge("Default"),
    shinyblocks::block_badge("Secondary", variant = "secondary"),
    shinyblocks::block_badge("Outline", variant = "outline"),
    shinyblocks::block_badge("Destructive", variant = "destructive"),
    shinyblocks::block_badge("Success", variant = "success"),
    shinyblocks::block_badge("Warning", variant = "warning"),
    shinyblocks::block_badge("Info", variant = "info")
  )
)

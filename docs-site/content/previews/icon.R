htmltools::div(
  style = "padding: 1rem; font-size: 1.5rem; color: var(--muted-foreground);",
  shinyblocks::block_cluster(
    gap = "md",
    justify = "center",
    shinyblocks::block_icon("bell", class = "text-destructive"),
    shinyblocks::block_icon("star", class = "text-yellow-500"),
    shinyblocks::block_icon("check-circle", class = "text-primary"),
    shinyblocks::block_icon("alert-triangle", class = "text-warning")
  )
)

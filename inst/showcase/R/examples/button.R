htmltools::tagList(
  htmltools::div(
    style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
    block_button("Default"),
    block_button("Secondary", variant = "secondary"),
    block_button("Outline", variant = "outline"),
    block_button("Ghost", variant = "ghost"),
    block_button("Destructive", variant = "destructive"),
    block_button("Link", variant = "link")
  ),
  htmltools::div(
    style = "display: flex; flex-wrap: wrap; align-items: center; gap: 0.5rem;",
    block_button("Default size"),
    block_button("Small", size = "sm"),
    block_button("Large", size = "lg"),
    block_button("", size = "icon", icon = "search")
  ),
  htmltools::div(
    style = "display: flex; flex-wrap: wrap; gap: 0.5rem;",
    block_button("Search", icon = "search"),
    block_button("Open", icon = "arrow-right", icon_position = "inline-end"),
    block_button("Disabled", disabled = NA)
  )
)

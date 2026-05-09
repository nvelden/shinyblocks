htmltools::div(
  style = paste(
    "display: grid;",
    "grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));",
    "gap: 1rem;"
  ),
  block_card(
    block_card_header(
      block_skeleton(style = "height: 1rem; width: 6rem;"),
      block_skeleton(style = "height: 1rem; width: 10rem;")
    ),
    block_card_content(
      block_skeleton(style = "height: 2rem; width: 5rem;"),
      block_skeleton(style = "height: 1rem; width: 100%;"),
      block_skeleton(style = "height: 1rem; width: 75%;")
    )
  ),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 0.75rem;",
    block_skeleton(style = "height: 2.5rem; width: 100%;"),
    block_skeleton(style = "height: 2.5rem; width: 100%;"),
    block_skeleton(style = "height: 2.5rem; width: 66%;")
  )
)

htmltools::div(
  style = "display: flex; align-items: center; gap: 1rem; padding: 1rem;",
  shinyblocks::block_skeleton(style = "width: 3rem; height: 3rem; border-radius: 9999px;"),
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 0.5rem; flex: 1;",
    shinyblocks::block_skeleton(style = "height: 1rem; width: 100%; max-width: 250px;"),
    shinyblocks::block_skeleton(style = "height: 1rem; width: 100%; max-width: 200px;")
  )
)

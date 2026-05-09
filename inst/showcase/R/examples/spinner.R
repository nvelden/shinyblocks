htmltools::div(
  style = "display: flex; flex-wrap: wrap; align-items: center; gap: 1rem;",
  block_spinner(),
  block_button("Saving", icon = block_spinner(), disabled = NA),
  htmltools::div(
    style = "display: inline-flex; align-items: center; gap: 0.5rem;",
    block_spinner(label = "Loading table"),
    htmltools::tags$span("Loading table")
  )
)

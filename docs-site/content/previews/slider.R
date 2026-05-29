htmltools::div(
  style = "width: 20rem; max-width: 100%;",
  shinyblocks::block_field(
    shinyblocks::block_field_label("Volume", `for` = "volume"),
    shinyblocks::block_slider(
      "volume",
      value = 50,
      min = 0,
      max = 100,
      min_label = "Quiet",
      max_label = "Loud",
      width = "100%"
    )
  )
)

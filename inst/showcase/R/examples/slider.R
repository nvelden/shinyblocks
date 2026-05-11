htmltools::tagList(
  block_field_group(
    block_field(
      block_field_label("Volume", `for` = "showcase_slider_volume"),
      block_slider(
        "showcase_slider_volume",
        value = 50,
        min = 0,
        max = 100
      ),
      block_field_description(
        "A single-handle slider with shadcn-tokened track, range, and thumb."
      )
    ),
    block_field(
      block_field_label("Price range", `for` = "showcase_slider_range"),
      block_slider(
        "showcase_slider_range",
        value = c(25, 75),
        min = 0,
        max = 100,
        step = 5
      ),
      block_field_description(
        "Range mode: two thumbs, filled portion between them."
      )
    ),
    block_field(
      block_field_label("Disabled", `for` = "showcase_slider_disabled"),
      block_slider(
        "showcase_slider_disabled",
        value = 30,
        min = 0,
        max = 100,
        disabled = TRUE
      ),
      block_field_description("Disabled state uses opacity 0.5 per shadcn.")
    )
  )
)

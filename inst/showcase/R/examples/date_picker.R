htmltools::tagList(
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 1rem 0;",
    paste(
      "Slice 3 ships theme parity for block_date_picker(). The full interactive",
      "playground (controls, server actions, input$ display, API table) lands in",
      "slice 4."
    )
  ),
  htmltools::tags$h3(
    style = "margin-top: 1rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance captured by the theme-conformance harness. Do not remove."
  ),
  htmltools::div(
    style = "padding: 1rem; border: 1px dashed var(--border); border-radius: 0.5rem; max-width: 260px;",
    block_date_picker(
      "showcase_parity_date_picker",
      value = "2024-01-15",
      width = "220px",
      class = "sb-parity-date-picker-default"
    )
  )
)

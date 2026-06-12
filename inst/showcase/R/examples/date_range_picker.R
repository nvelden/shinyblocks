# Slice 4 ships the structural + theme-parity surface for the range picker. The
# full interactive playground (controls, input$ display, server actions, API
# table) lands in slice 5; this section currently shows representative previews
# plus the stable parity fixtures captured by the theme-conformance harness.
htmltools::tagList(
  htmltools::tags$div(
    style = "display: flex; flex-wrap: wrap; gap: 1.5rem; align-items: flex-start;",
    htmltools::tags$div(
      style = "flex: 1; min-width: 260px; max-width: 340px;",
      htmltools::tags$div(
        style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
        "Empty (placeholder-first)"
      ),
      block_date_range_picker(
        "showcase_date_range_picker_empty",
        placeholder = "Pick a date range",
        width = "300px"
      )
    ),
    htmltools::tags$div(
      style = "flex: 1; min-width: 260px; max-width: 340px;",
      htmltools::tags$div(
        style = "font-size: 0.75rem; font-weight: 600; color: var(--muted-foreground); margin-bottom: 0.5rem;",
        "Pre-filled range"
      ),
      block_date_range_picker(
        "showcase_date_range_picker_filled",
        start = "2024-01-08",
        end = "2024-01-19",
        width = "300px"
      )
    )
  ),
  htmltools::tags$h3(
    style = "margin-top: 2rem; font-size: 1.125rem;",
    "Parity fixtures"
  ),
  htmltools::tags$p(
    style = "color: var(--muted-foreground); margin: 0 0 0.5rem 0; font-size: 0.875rem;",
    "Stable instance captured by the theme-conformance harness. Do not remove."
  ),
  htmltools::div(
    style = "padding: 1rem; border: 1px dashed var(--border); border-radius: 0.5rem; max-width: 320px;",
    block_date_range_picker(
      "showcase_parity_date_range_picker",
      start = "2024-01-08",
      end = "2024-01-19",
      width = "280px",
      class = "sb-parity-date-range-picker-default"
    )
  )
)

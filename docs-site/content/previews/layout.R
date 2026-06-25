shinyblocks::block_card(
  title = "Dashboard Layout",
  description = "A conceptual structure of a page shell",
  style = "max-width: 400px; margin: 0 auto;",
  htmltools::div(
    style = paste(
      "border: 1px solid var(--border); border-radius: 0.375rem;",
      "padding: 0.5rem; font-family: monospace; font-size: 0.75rem;"
    ),
    shinyblocks::block_stack(
      gap = "sm",
      htmltools::div(
        style = "background: var(--muted); padding: 0.25rem; text-align: center; border-radius: 0.25rem;",
        "block_header()"
      ),
      shinyblocks::block_cluster(
        gap = "sm",
        wrap = FALSE,
        htmltools::div(
          style = "background: var(--muted); padding: 0.5rem 0.25rem; width: 30%; border-radius: 0.25rem; text-align: center; min-height: 80px;",
          "sidebar"
        ),
        htmltools::div(
          style = "background: var(--muted); padding: 0.5rem 0.25rem; flex: 1; border-radius: 0.25rem; text-align: center; min-height: 80px;",
          "block_body()"
        )
      )
    )
  )
)

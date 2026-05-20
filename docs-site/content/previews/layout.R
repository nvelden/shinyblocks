shinyblocks::block_card(
  title = "Dashboard Layout",
  description = "A conceptual structure of a page shell",
  style = "max-width: 400px; margin: 0 auto;",
  htmltools::div(
    style = "display: flex; flex-direction: column; gap: 0.5rem; border: 1px solid var(--border); border-radius: 0.375rem; padding: 0.5rem; font-family: monospace; font-size: 0.75rem;",
    htmltools::div(style = "background: var(--muted); padding: 0.25rem; text-align: center; border-radius: 0.25rem;", "block_header()"),
    htmltools::div(
      style = "display: flex; gap: 0.5rem; min-height: 80px;",
      htmltools::div(style = "background: var(--muted); padding: 0.25rem; width: 30%; border-radius: 0.25rem; display: flex; align-items: center; justify-content: center;", "sidebar"),
      htmltools::div(style = "background: var(--muted); padding: 0.25rem; flex: 1; border-radius: 0.25rem; display: flex; align-items: center; justify-content: center;", "block_body()")
    )
  )
)

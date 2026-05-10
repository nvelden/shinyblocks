sb_section <- function(id, title, lead, example_path, active = FALSE) {
  ex <- render_example(example_path)
  scoped_render <- scope_showcase_theme(ex$rendered, id)

  htmltools::tags$section(
    id = id,
    `data-sb-section` = id,
    `aria-labelledby` = paste0(id, "-title"),
    hidden = if (!active) NA else NULL,
    style = "display: flex; flex-direction: column; gap: 1rem;",
    htmltools::tags$h2(
      id = paste0(id, "-title"),
      style = paste(
        "font-size: 1.25rem;",
        "font-weight: 600;",
        "letter-spacing: -0.025em;",
        "margin: 0;"
      ),
      title
    ),
    if (!is.null(lead)) {
      htmltools::tags$p(
        style = "color: var(--muted-foreground); margin: 0;",
        lead
      )
    },
    htmltools::tags$div(
      `data-sb-preview` = id,
      scoped_render
    ),
    htmltools::tags$details(
      htmltools::tags$summary(
        style = paste(
          "cursor: pointer;",
          "color: var(--muted-foreground);",
          "font-size: 0.875rem;",
          "user-select: none;"
        ),
        "View source"
      ),
      htmltools::tags$pre(
        style = paste(
          "margin: 0.5rem 0 0 0;",
          "padding: 0.75rem 1rem;",
          "overflow-x: auto;",
          "background: var(--muted);",
          "color: var(--foreground);",
          "border-radius: 0.5rem;",
          "font-size: 0.8125rem;",
          "line-height: 1.5;"
        ),
        htmltools::tags$code(ex$code)
      )
    )
  )
}

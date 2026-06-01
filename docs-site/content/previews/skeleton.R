preview_skeleton <- function(style) {
  htmltools::tagAppendAttributes(
    shinyblocks::block_skeleton(style = style),
    style = paste(
      "display: block; background-color: var(--muted, oklch(97% 0 0));",
      "border-radius: calc(var(--radius, 0.625rem) * 0.8);",
      "animation: shinyblocks-pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;",
      style
    )
  )
}

htmltools::div(
  `data-shinyblocks-root` = "",
  style = paste(
    "width: min(100%, 20rem); display: flex; flex-direction: column;",
    "gap: 1rem; padding: 0.25rem; box-sizing: border-box;"
  ),
  htmltools::div(
    style = "display: flex; align-items: center; gap: 0.875rem;",
    preview_skeleton(
      "width: 3rem; height: 3rem; border-radius: calc(var(--radius, 0.625rem) * 0.8); flex: 0 0 auto;"
    ),
    htmltools::div(
      style = "display: flex; min-width: 0; flex: 1; flex-direction: column; gap: 0.5rem;",
      preview_skeleton("width: 100%; height: 1rem; max-width: 12rem;"),
      preview_skeleton("width: 65%; height: 1rem;")
    )
  ),
  preview_skeleton("width: 100%; height: 5rem; border-radius: calc(var(--radius, 0.625rem) * 0.8);"),
  htmltools::div(
    style = "display: flex; gap: 0.5rem; flex-wrap: wrap;",
    preview_skeleton("width: 5rem; height: 1rem;"),
    preview_skeleton("width: 7rem; height: 1rem;")
  )
)

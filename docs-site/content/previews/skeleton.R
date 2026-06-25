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

shinyblocks::block_stack(
  gap = "md",
  `data-shinyblocks-root` = "",
  style = "width: min(100%, 20rem); padding: 0.25rem; box-sizing: border-box;",
  shinyblocks::block_cluster(
    gap = "sm",
    align = "center",
    preview_skeleton(
      "width: 3rem; height: 3rem; border-radius: calc(var(--radius, 0.625rem) * 0.8); flex: 0 0 auto;"
    ),
    shinyblocks::block_stack(
      gap = "sm",
      style = "min-width: 0; flex: 1;",
      preview_skeleton("width: 100%; height: 1rem; max-width: 12rem;"),
      preview_skeleton("width: 65%; height: 1rem;")
    )
  ),
  preview_skeleton("width: 100%; height: 5rem; border-radius: calc(var(--radius, 0.625rem) * 0.8);"),
  shinyblocks::block_cluster(
    gap = "sm",
    preview_skeleton("width: 5rem; height: 1rem;"),
    preview_skeleton("width: 7rem; height: 1rem;")
  )
)

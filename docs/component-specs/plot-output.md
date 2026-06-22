# Plot Output

> Shinyblocks function: `block_plot_output()` (sibling of `block_image_output()`)
> Shadcn reference: image / aspect-ratio composition (`AspectRatio`,
> `object-cover`, rounded + border treatment)
> Status: Phase — R-side composition primitive framing a Shiny raster output

`block_plot_output()` wraps [`shiny::plotOutput()`] (`renderPlot()`) in the same
shadcn-styled frame as `block_image_output()`, sharing the private
`output_frame()` builder. It covers base graphics, **ggplot2**, and lattice.
App-author server code stays vanilla Shiny — `output$id <- renderPlot(...)` is
unchanged.

See [`image-output.md`](image-output.md) for the full structure, library
coverage matrix, token contract, and accessibility notes — they are identical.

## Difference from `block_image_output()`

- Wraps `shiny::plotOutput()` (frame class `sb-plot-output`) instead of
  `shiny::imageOutput()`.
- **`fill` defaults to `!inline`** (matching `shiny::plotOutput()`), whereas
  `block_image_output()` defaults `fill = FALSE` (matching
  `shiny::imageOutput()`). They differ in Shiny, so a shared default would
  silently change image behavior. Sizing is CSS-driven, not `fill`-driven.
- Click/hover/brush coordinate inputs forward unchanged, so interactive plot
  selection keeps working inside the frame.

## States

- **default** — bordered (optional) media box with rounded corners.
- **with aspect** — media box drives height via `aspect-ratio`; the Shiny output
  fills it (`height: 100%`).
- **fit** — accepted for API parity with image output, but usually not visually
  apparent because `renderPlot()` renders the image to the output box size.
- **captioned** — muted `<figcaption>` below the media box.

## Token contract

| Visual role | Token |
| --- | --- |
| Border | `--border` |
| Radius | `--radius` |
| Caption foreground | `--muted-foreground` |

## Accessibility

The plot's accessible name (`alt`) is **server-controlled** via
`renderPlot(alt = ...)` — the frame cannot set it.

## Deliberate divergences from shadcn

- shadcn has no canonical reactive-plot-output component; this frames Shiny's
  raster output contract.

## Reference screenshot

![Plot output](_screenshots/plot-output.png)

Captured from the local shinyblocks showcase `plot-output` playground.

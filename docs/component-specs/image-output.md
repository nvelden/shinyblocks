# Image Output

> Shinyblocks function: `block_image_output()` (see also `block_plot_output()`)
> Shadcn reference: image / aspect-ratio composition (`AspectRatio`,
> `object-cover`, rounded + border treatment)
> Status: Phase — R-side composition primitive framing a Shiny raster output

`block_image_output()` wraps [`shiny::imageOutput()`] (`renderImage()`) in a
shadcn-styled frame. shinyblocks owns the **frame** (aspect box, object-fit,
border, radius, caption); Shiny keeps owning the **content** (temp-file serving,
content-type, `deleteFile` cleanup, resize/recalc, click/hover/brush). App-author
server code stays vanilla Shiny — `output$id <- renderImage(...)` is unchanged.

It is an R-side composition primitive (like `block_field_*()`): `htmltools`
wrapping the Shiny output via `attach_shinyblocks_deps()`. No React runtime, no
input binding, no payload, no `update_block_*()`.

## Library coverage

| Library / source | Shiny mechanism | Wrapper |
| --- | --- | --- |
| base graphics, ggplot2, lattice | `renderPlot()` / `plotOutput()` (PNG) | `block_plot_output()` |
| magick, server-generated image files (PNG/JPEG/SVG/GIF) | `renderImage()` / `imageOutput()` | `block_image_output()` |

Scope is Shiny's raster image outputs only. **Out of scope:** interactive
htmlwidgets (plotly, leaflet, DT, …) are a different mechanism (interactive
`<div>`, not an `<img>`); *static* images use `htmltools::img()` directly.

## Structure

```html
<figure class="sb-output-frame sb-image-output">
  <div class="sb-output-media" data-aspect data-border data-rounded
       style="--sb-output-aspect:16/9; --sb-output-fit:cover">
    <div class="shiny-image-output ..."></div>   <!-- Shiny fills with <img> -->
  </div>
  <figcaption class="sb-output-caption">...</figcaption>
</figure>
```

Box chrome (aspect/border/radius/`overflow:hidden`) lives on the inner
`.sb-output-media`, never the `<figure>` — so the `<figcaption>` sibling is not
clipped by the aspect box.

## States

- **default** — bordered (optional) media box with rounded corners.
- **with aspect** — media box drives height via `aspect-ratio`; the Shiny output
  fills it (`height: 100%`).
- **fit** — `object-fit` (`cover`/`contain`/`fill`/`none`/`scale-down`) on the
  rendered `<img>`.
- **captioned** — muted `<figcaption>` below the media box.

## Token contract

| Visual role | Token |
| --- | --- |
| Border | `--border` |
| Radius | `--radius` |
| Caption foreground | `--muted-foreground` |

## Accessibility

The image's accessible name (`alt`) is **server-controlled** via
`renderImage(alt = ...)` — the frame cannot set it. App authors should always
return an `alt`. The `caption` is decorative `<figcaption>`, not a replacement
for `alt`.

## Deliberate divergences from shadcn

- shadcn has no canonical reactive-image-output component; this frames Shiny's
  raster output contract.

## Reference screenshot

![Image output](_screenshots/image-output.png)

Captured from the local shinyblocks showcase. _(Pending Slice 3.)_

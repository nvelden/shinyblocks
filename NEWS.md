# shinyblocks (development version)

## 0.0.0.9000

* Initial R package scaffold with exported Shiny/htmltools helpers for
  pages, sidebars, headers, navigation items, cards, and buttons.
* `block_card()` now ships with styling for its title, value, and body
  slots so it renders as a tokenised surface instead of an unstyled
  `<article>`.
* `block_nav_item()` advertises itself as a `nav-item` child via
  `data-sb-child`, so a future `block_nav()` parent can validate its
  contents.
* Documentation gains a Quarto + Shinylive component gallery
  (`vignettes/articles/components/`) modelled on
  <https://shiny.posit.co/r/components/>. Each exported component has
  a page with an embedded live demo and visible source. See
  `docs/decisions/0013-component-gallery-quarto.md`.

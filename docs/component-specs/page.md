# Page

> Shinyblocks function: `block_page()`
> Shadcn reference: <https://ui.shadcn.com/blocks>

## States

- **default** — top-level app shell with optional header and body.
- **with-sidebar** — page root carries sidebar state attrs and renders
  the sidebar/backdrop/header-shell composition.
- **theme-mode** — bootstraps `data-theme` from system, light, or dark
  mode before the app paints.

## Token contract

| Visual role | Token |
| --- | --- |
| App surface | `--background` |
| App text | `--foreground` |

## Deliberate divergences from shadcn

- `block_page()` is a dashboard shell primitive rather than a direct
  one-to-one shadcn component.
- Theme bootstrapping is handled inline so a Shiny page paints in the
  correct mode before JS enhancements attach.

## Reference screenshot

![Page](_screenshots/page.png)

Captured from <https://ui.shadcn.com/blocks> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.

# Nav Label

> Shinyblocks function: `block_nav_label()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/sidebar>
> Status: R-side sidebar section caption.

## States

- **default** — renders a non-interactive `.sb-nav-section-label` caption inside
  `block_nav()`.
- **sidebar-collapsed** — hidden by sidebar rail CSS so captions do not occupy
  the icon-only navigation surface.
- **nav-input child** — carries no `data-value` and never reports input state.

## R API

| Argument | Purpose |
| --- | --- |
| `text` | Section caption text. |
| `class` | Extra classes for `.sb-nav-section-label`. |

## Stable Shell Hooks

`block_nav_label()` owns `.sb-nav-section-label` and advertises
`data-sb-child="nav-label"` for `block_nav()` and `block_sidebar()`
composition.

## Accessibility

- Rendered as a non-interactive `<div>`.
- It does not enter the tab order and does not create a navigation item.

## Token Contract

| Visual role | Token |
| --- | --- |
| Muted caption text | `--muted-foreground` |

## Deliberate Divergences From Shadcn

- This is a lightweight caption helper rather than a React sidebar menu label
  primitive.

## Reference Screenshot

![Nav label](_screenshots/nav.png)

Captured from <https://ui.shadcn.com/docs/components/sidebar> on 2026-05-11.

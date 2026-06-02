# Nav

> Shinyblocks function: `block_nav()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/sidebar>
> Status: R-side navigation container; Phase 7 spec refreshed around
> the shipped sidebar composition rule and runtime keyboard behavior.

## States

- **default** — `<nav class="sb-nav">` container for one or more
  `block_nav_item()` children. Validated at construction.
- **stacked** — renders a vertical navigation list with sidebar-safe
  spacing.
- **keyboard-enhanced** — when inside a sidebar, the package runtime
  enables Up/Down/Home/End traversal across child items.
- **sidebar-composed** — when passed as the single child of
  `block_sidebar()`, the existing `<nav>` is promoted to the sidebar
  navigation region (gets `.sb-sidebar-nav` merged into its class)
  instead of being wrapped inside another `<nav>` landmark.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | One or more `block_nav_item()` children. Other children fail validation. |
| `class` | Extra classes for the `.sb-nav` element. |

## Stable shell hooks

`block_nav()` owns `.sb-nav` and contributes `.sb-sidebar-nav` when
composed inside `block_sidebar()`. These hooks are R-side navigation
contracts, not runtime component styling targets.

## Accessibility

- Rendered as `<nav>`.
- The sidebar composition rule avoids nested `<nav>` landmarks.
- Child `block_nav_item()` elements carry `aria-current="page"` when
  selected.

## Token contract

| Visual role | Token |
| --- | --- |
| Layout spacing | none (layout only; visual tokens are owned by `block_nav_item()`) |

## Deliberate divergences from shadcn

- `block_nav()` is an R-side validation wrapper; shadcn sidebar
  examples rely on composition inside React providers and menu primitives.

## Reference screenshot

![Nav](_screenshots/nav.png)

Captured from <https://ui.shadcn.com/docs/components/sidebar> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.

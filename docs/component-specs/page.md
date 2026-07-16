# Page

> Shinyblocks function: `block_page()`
> Shadcn reference: <https://ui.shadcn.com/blocks>
> Status: R-side app-shell composition primitive; Phase 7 spec
> refreshed around shipped shell hooks, theme bootstrap delegation,
> and runtime portal ownership.

## States

- **default** — top-level app shell with optional header and body.
- **with-sidebar** — page root carries `data-sidebar-enhanced`,
  `data-sidebar-mobile-open`, and `data-sidebar-collapsed` attributes
  consumed by the package runtime sidebar behavior.
- **theme-mode** — serializes the requested initial theme mode
  (`system`, `light`, or `dark`) into `window.shinyblocksInitialThemeMode`
  for the package theme runtime to apply.
- **portal-owned** — emits the runtime portal root inside the
  `.sb-app` shell so `block_theme()` page-scoped token overrides reach
  overlay/select portal content.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Page body content. Wrapped in `block_body()` automatically. |
| `title` | Browser tab title (defaults to `"shinyblocks"`). |
| `sidebar` | Optional `block_sidebar()` tag. Triggers the mobile sidebar trigger and backdrop wiring. |
| `header` | Optional `block_header()` tag. Composed inside `.sb-header-shell` alongside the mobile sidebar trigger. |
| `theme_mode` | Initial theme mode: `"system"`, `"light"`, or `"dark"`. |
| `theme` | Optional `block_theme()` overrides injected into `<head>`. |
| `class` | Extra classes for the app root (`.sb-app`). |

## Stable shell hooks

`block_page()` owns the `.sb-app`, `.sb-page`, `.sb-page-main`,
`.sb-header-shell`, `.sb-sidebar-backdrop`, and portal-root placement
hooks, plus the `data-sidebar-*` state attributes on `.sb-page`. These
hooks are reserved for package shell layout and must not become
dependencies for runtime-rendered component visuals. The shell
stylesheet guardrail enforces this contract.

## Host-package isolation

The generated base reset targets the `.sb-app` root and elements that carry a
shinyblocks-owned `sb-*` class. It does not reset arbitrary descendants by
element name. Native Shiny controls, bslib content, htmlwidgets, and other
foreign markup placed in cards, tabs, accordions, dialogs, or layout slots keep
their own typography, spacing, borders, media display, and focus treatment.
Standalone shinyblocks components use the same ownership markers and do not
establish a reset over surrounding host markup.

## Accessibility

- `block_body()` is a `<main>` landmark; one per page.
- When a sidebar is present, a mobile trigger button labeled
  "Open sidebar" appears in `.sb-header-shell` with
  `aria-controls`/`aria-expanded` wiring to the sidebar's id.
- The portal root is `aria-hidden`-neutral so overlay content owns its
  own ARIA wiring (`role="dialog"`, etc.).

## Token contract

| Visual role | Token |
| --- | --- |
| App surface | `--background` |
| App text | `--foreground` |

## Deliberate divergences from shadcn

- `block_page()` is a dashboard app-shell primitive, not a one-to-one
  shadcn component. It packages the recurring header/sidebar/body
  layout into a single helper.
- Theme bootstrapping is handled by the package `shinyblocks.js`
  runtime. `block_page()` only emits the initial mode configuration so
  the same runtime owns dark-mode toggle delegation and Shiny
  `update_block_theme()` messages.

## Reference screenshot

![Page](_screenshots/page.png)

Captured from <https://ui.shadcn.com/blocks> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.

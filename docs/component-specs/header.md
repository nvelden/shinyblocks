# Header

> Shinyblocks function: `block_header()`
> Shadcn reference: <https://ui.shadcn.com/blocks>

## States

- **default** — top page header band with shadcn-style spacing and
  border treatment.
- **with-sidebar-trigger** — renders beside the mobile sidebar trigger
  inside `.sb-header-shell`.
- **responsive** — remains usable in both sidebar and no-sidebar page
  shells.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` |
| Foreground | `--foreground` |
| Border | `--border` |

## Stable shell hooks

`block_header()` owns `.sb-header` and participates in the page-owned
`.sb-header-shell` wrapper when a sidebar trigger is present. These
hooks stay package-owned shell contracts.

## Deliberate divergences from shadcn

- `block_header()` packages a recurring app-shell pattern rather than a
  direct upstream component export.

## Reference screenshot

![Header](_screenshots/header.png)

Captured from <https://ui.shadcn.com/blocks> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.

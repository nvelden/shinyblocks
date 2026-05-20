# Theme

> Shinyblocks function: `block_theme()`
> Shadcn reference: token theming model at <https://ui.shadcn.com/docs/theming>

## States

- **default** — emits page-scoped CSS variable overrides for the owned
  page shell.
- **overridden** — supplied token values replace the vendored defaults
  for components inside the page shell, including owned runtime portal
  content.
- **server-updated** — `update_block_theme()` sends a Shiny custom
  message handled by the same package theme runtime used by the
  dark-mode toggle.

## Token contract

| Visual role | Token |
| --- | --- |
| Override scope | page-shell CSS custom properties |
| Primary example | `--primary` |
| Radius example | `--radius` |

## Deliberate divergences from shadcn

- `block_theme()` is an R helper that emits a `<style>` tag; shadcn
  itself expects the host app to own the CSS variable source.
- `update_block_theme()` changes the active light/dark/system mode; it
  does not mutate CSS token values emitted by `block_theme()`.

## Reference screenshot

![Theme](_screenshots/theme.png)

Captured from the local shinyblocks showcase on 2026-05-11.
Refresh and update the date whenever the shinyblocks reference treatment changes.

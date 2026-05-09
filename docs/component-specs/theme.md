# Theme

> Shinyblocks function: `block_theme()`
> Shadcn reference: token theming model at <https://ui.shadcn.com/docs/theming>

## States

- **default** — emits page-scoped CSS variable overrides for `.sb-app`.
- **overridden** — supplied token values replace the vendored defaults
  for components inside the page shell only.

## Token contract

| Visual role | Token |
| --- | --- |
| Override scope | `.sb-app` CSS custom properties |
| Primary example | `--primary` |
| Radius example | `--radius` |

## Deliberate divergences from shadcn

- `block_theme()` is an R helper that emits a `<style>` tag; shadcn
  itself expects the host app to own the CSS variable source.

## Reference screenshot

![Theme](_screenshots/theme.png)

Capture pending — use a shadcn-themed surface showing custom token
overrides, then refresh the date when the canonical look changes.

# Select

> Shinyblocks function: `block_select()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/select>

## States

- **default** — bordered trigger surface rendered through Shiny's
  select/selectize path.
- **open** — popover-like dropdown surface with token-driven item
  styling.
- **hover** — option rows use `--accent` fill and
  `--accent-foreground`.
- **focus-visible** — 3px `--ring` shadow on the visible trigger shell.
- **invalid** — destructive ring when the wrapped select carries
  `aria-invalid="true"`.
- **disabled** — delegated to the underlying Shiny select element.

## Token contract

| Visual role | Token |
| --- | --- |
| Trigger surface | `--background` |
| Trigger border | `--input` |
| Dropdown surface | `--popover` |
| Dropdown text | `--popover-foreground` |
| Active option | `--accent`, `--accent-foreground` |
| Focus ring | `--ring` |
| Invalid ring | `--destructive`, `--border` |

## Deliberate divergences from shadcn

- `block_select()` is a wrapper around Shiny/selectize, not a package-
  owned select runtime, per ADR 0014.
- Item selection and menu positioning are controlled by Selectize, with
  shinyblocks CSS overriding the visual shell.

## Reference screenshot

![Select](_screenshots/select.png)

Captured from <https://ui.shadcn.com/docs/components/select> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.

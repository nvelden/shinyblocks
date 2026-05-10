# Separator

> Shinyblocks function: `block_separator()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/separator>

## States

- **horizontal** — full-width divider line.
- **vertical** — vertical divider for dense toolbars or inline layouts.
- **semantic** — exposes `role="separator"` and `aria-orientation` when
  `decorative = FALSE`.
- **decorative** — hidden from assistive tech by default.

## Token contract

| Visual role | Token |
| --- | --- |
| Rule color | `--border` |

## Deliberate divergences from shadcn

- shinyblocks defaults separators to decorative-only because most uses
  in the package are presentational.

## Reference screenshot

![Separator](_screenshots/separator.png)

Capture pending — use the canonical shadcn separator docs page once
screenshots are being captured.

# Field Invalid

> Shinyblocks function: `block_field_invalid()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/input>
> Status: Phase 5.13 — ownership resolved as an R-side composition primitive

## States

- **default** — decorates a `block_field()` with destructive helper text
  and invalid attrs on wrapped controls.
- **runtime-control** — marks runtime control mounts with
  `aria-invalid="true"` and `aria-describedby` so the owned control can
  inherit invalid styling.
- **choice-control** — checkbox and switch invalid styling is driven by
  the same field-level `data-invalid="true"` wrapper.

## Token contract

| Visual role | Token |
| --- | --- |
| Invalid text | `--destructive` |
| Invalid ring | `--destructive`, `--border` |

## Deliberate divergences from shadcn

- shadcn documents invalid states as a styling pattern, while
  `block_field_invalid()` packages the pattern into one R helper.

## Reference screenshot

![Field invalid](_screenshots/field-invalid.png)

Captured from <https://ui.shadcn.com/docs/components/input> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.

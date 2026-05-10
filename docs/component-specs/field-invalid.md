# Field Invalid

> Shinyblocks function: `block_field_invalid()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/input>

## States

- **default** — decorates a `block_field()` with destructive helper text
  and invalid attrs on wrapped controls.
- **text-control** — marks nested `input`, `select`, and `textarea`
  with `aria-invalid="true"` and `aria-describedby`.
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

Capture pending — use the shadcn invalid form example as the reference
once screenshots are being captured.

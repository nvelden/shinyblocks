# Field

> Shinyblocks function: `block_field()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/input>

## States

- **default** — vertical field wrapper for label, control, and helper
  text.
- **invalid** — carries `data-invalid="true"` and appends destructive
  helper text when wrapped by `block_field_invalid()`.
- **composed** — accepts input wrappers, textarea, select, checkbox,
  and switch content without imposing extra chrome.

## Token contract

| Visual role | Token |
| --- | --- |
| Helper text | `--muted-foreground` |
| Invalid text | `--destructive` |

## Deliberate divergences from shadcn

- `block_field()` is a composition wrapper around Shiny controls, not a
  direct upstream shadcn primitive.

## Reference screenshot

![Field](_screenshots/field.png)

Captured from <https://ui.shadcn.com/docs/components/input> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.

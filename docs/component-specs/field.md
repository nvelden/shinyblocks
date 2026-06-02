# Field

> Shinyblocks function: `block_field()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/input>
> Status: Phase 5.13 — ownership resolved as an R-side composition primitive

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

## Runtime ownership

`block_field()` remains a package-owned R-side composition wrapper. It
owns layout, label/helper-text placement, and field-level invalid
messaging. Interactive control behavior belongs to the child component,
which should normally be a runtime control such as `block_input()`,
`block_textarea()`, `block_select()`, `block_checkbox()`, or
`block_switch()`.

## Deliberate divergences from shadcn

- `block_field()` is a composition wrapper, not a direct upstream shadcn
  primitive.

## Reference screenshot

![Field](_screenshots/field.png)

Captured from <https://ui.shadcn.com/docs/components/input> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.

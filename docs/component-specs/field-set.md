# Field Set

> Shinyblocks function: `block_field_set()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/input>
> Status: Phase 5.13 — R-side composition primitive

## States

- **default** — bordered group wrapper around related fields.
- **with-legend** — renders `block_field_legend()` as the group title.
- **invalid-children** — child control invalid states render inside the
  shared fieldset shell without changing the fieldset border token.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | transparent |
| Border | `--border` |

## Deliberate divergences from shadcn

- `block_field_set()` is a semantic fieldset wrapper; shadcn form docs
  show the pattern but do not ship a direct primitive.

## Reference screenshot

![Field set](_screenshots/field-set.png)

Captured from <https://ui.shadcn.com/docs/components/input> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.

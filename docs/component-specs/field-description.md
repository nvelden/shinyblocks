# Field Description

> Shinyblocks function: `block_field_description()`
> Shadcn reference: <https://ui.shadcn.com/docs/components/input>
> Status: R-side composition primitive; Phase 7 spec refreshed around
> the shipped helper/error reuse pattern.

## States

- **default** — muted helper text rendered as
  `<p class="sb-field-description">` below the control.
- **error** — when used inside `block_field_invalid()`, gains
  `.sb-field-error` styling for destructive coloring.
- **described-by** — supplying `id` lets a control reference it via
  `aria-describedby`.

## R API

| Argument | Purpose |
| --- | --- |
| `...` | Helper text content. |
| `id` | Optional DOM id so a control can wire `aria-describedby` to it. |
| `class` | Extra classes merged onto the `.sb-field-description` element. |

## Composition contract

Stamps `data-sb-child="field-description"` on the emitted `<p>`. The
field family detects this marker when composing helper / error /
description regions; see [field](field.md) and
[field-invalid](field-invalid.md).

## Token contract

| Visual role | Token |
| --- | --- |
| Helper text | `--muted-foreground` |
| Error text | `--destructive` |

## Deliberate divergences from shadcn

- shinyblocks reuses one primitive for helper and error text instead
  of splitting them into separate exported helpers. Error styling is
  driven by the parent (`block_field_invalid()`).

## Reference screenshot

![Field description](_screenshots/field-description.png)

Captured from <https://ui.shadcn.com/docs/components/input> on 2026-05-11.
Refresh and update the date whenever shadcn updates the canonical look.

# Input Group

> Shinyblocks function: `block_input_group()`
> Shadcn reference: input-with-addon composition built from Input
> patterns
> Status: Phase 5.11 — ownership resolved as an R-side layout primitive

## States

- **default** — bordered shell wrapping addon and one input control.
- **focus-within** — 3px `--ring` shadow on the group shell.
- **invalid** — destructive ring when a child control carries
  `aria-invalid="true"`.
- **composed** — intended to wrap one control plus one or more addons.

## Token contract

| Visual role | Token |
| --- | --- |
| Surface | `--background` |
| Border | `--input` |
| Focus ring | `--ring` |
| Invalid ring | `--destructive`, `--border` |

## Runtime ownership

`block_input_group()` is not a standalone runtime input binding. It is a
package-owned R-side composition wrapper that lays out addon slots around
a child control. The preferred control child is runtime `block_input()`,
which owns Shiny value binding, invalid state, disabled state, and server
updates through `update_block_input()`.

Raw Shiny inputs remain tolerated for backward-compatible composition, but
new showcase, docs, and tests should use runtime controls inside the group.

## Deliberate divergences from shadcn

- shadcn does not ship a canonical standalone input-group component;
  this is a shinyblocks composition wrapper around the input contract.

## Reference screenshot

![Input group](_screenshots/input-group.png)

Captured from the local shinyblocks showcase on 2026-05-11.
Refresh and update the date whenever the shinyblocks reference treatment changes.

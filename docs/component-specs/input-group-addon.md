# Input Group Addon

> Shinyblocks function: `block_input_group_addon()`
> Shadcn reference: input-with-addon composition built from Input
> patterns

## States

- **default** — inline addon content aligned vertically with the
  wrapped input.
- **icon** — most common usage is a leading icon with muted foreground.
- **composed** — intended to live inside `block_input_group()`.

## Token contract

| Visual role | Token |
| --- | --- |
| Text/icon | `--muted-foreground` |
| Divider border | `--input` |

## Deliberate divergences from shadcn

- shadcn does not ship a canonical standalone addon primitive; this is
  a shinyblocks composition helper.

## Reference screenshot

![Input group addon](_screenshots/input-group-addon.png)

Captured from the local shinyblocks showcase on 2026-05-11.
Refresh and update the date whenever the shinyblocks reference treatment changes.

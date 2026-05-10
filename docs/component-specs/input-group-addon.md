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

Capture pending — use the canonical input styling plus a prefixed-addon
composition treatment when capturing the screenshot.

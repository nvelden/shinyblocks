# Theme presets

> Shinyblocks function: `block_theme_presets()`
> Status: discovery helper for the built-in colour palettes consumed by
> `block_theme(preset = )` (issue #33,
> [ADR 0021](../decisions/0021-theme-presets-and-style-profiles.md)).

## States

- **default** — returns the supported built-in palette names as a character
  vector: `neutral`, `stone`, `zinc`, `mauve`, `olive`, `mist`, `taupe`.

## R API

### `block_theme_presets()`

No arguments. Returns the palette names accepted by the `preset` argument of
[`block_theme()`](theme.md). Use it instead of hardcoding palette names from
documentation; it is the single stable data source for callers and playground
controls.

## Deliberate divergences from shadcn

- shadcn exposes base colours through CLI/registry tooling; shinyblocks vendors
  the packs as package-owned R data and surfaces the names through this helper.

# Style profiles

> Shinyblocks function: `block_style_profiles()`
> Status: discovery helper for the built-in visual style profiles consumed by
> [`block_style()`](style.md) (issue #33,
> [ADR 0021](../decisions/0021-theme-presets-and-style-profiles.md)).

## States

- **default** — returns the supported built-in style-profile names as a
  character vector. Currently `c("default", "luma", "rhea")`. The `default`
  profile preserves the current visuals; `luma` is the upstream Radix Luma
  visual profile and `rhea` is its denser sibling (see
  [`style.md`](style.md) for token and per-family coverage).

## R API

### `block_style_profiles()`

No arguments. Returns the profile names accepted by the `profile` argument of
[`block_style()`](style.md). One stable data source for callers and (future)
playground controls, so profile names are not hardcoded from documentation.

## Deliberate divergences from shadcn

- shadcn ships style presets through CLI preset codes; shinyblocks curates a
  small set of package-owned profiles and exposes their names through this
  helper.

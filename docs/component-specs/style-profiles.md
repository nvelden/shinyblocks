# Style profiles

> Shinyblocks function: `block_style_profiles()`
> Status: discovery helper for the built-in visual style profiles consumed by
> [`block_style()`](style.md) (issue #33).

## States

- **default** — returns the supported built-in style-profile names as a
  character vector. Currently
  `c("default", "luma", "lyra", "maia", "mira", "nova", "rhea", "sera", "vega")`.
  The `default` profile preserves the current visuals; every non-default
  profile maps to an official shadcn/ui v4 registry style file (see
  [`style.md`](style.md) for token and per-family coverage).

## R API

### `block_style_profiles()`

No arguments. Returns the profile names accepted by the `profile` argument of
[`block_style()`](style.md). One stable data source for callers and (future)
playground controls, so profile names are not hardcoded from documentation.

## Deliberate divergences from shadcn

- shadcn style files are Tailwind `@apply` registries. shinyblocks translates
  them into R profile data and scoped package CSS instead of vendoring React or
  Tailwind source into app-author code.

# Style

> Shinyblocks function: `block_style()` (consumed by `block_page(style = )`)
> Shadcn reference: official v4 style registry at
> <https://github.com/shadcn-ui/ui/tree/main/apps/v4/registry/styles>
> Status: Slice 5 plus official-profile alignment (issues #33, #48). Ships the
> `default`, `luma`, `lyra`, `maia`, `mira`, `nova`, `rhea`, `sera`, and `vega`
> profiles, the public `--sb-*` token layer, the internal
> geometry/translucency token layer, the profile-scoped component CSS, and the
> style-profile
> parity harness (`tools/theme/check-style-parity.mjs` + `style-registry.mjs`).
> Luma now covers the shell families too (input group, field, tabs, sidebar,
> nav); all five are measured `profile` bindings in the parity registry.

A **style profile** owns visual *feel* — control sizing, spacing, surface and
overlay metrics, elevation, focus/disabled treatment, and motion — separate
from `block_theme()`, which owns semantic light/dark **colour** tokens. Profiles
are emitted as `--sb-*` custom properties.

## States

- **default** — `block_style("default")` selects the built-in default profile,
  whose values live in the runtime stylesheet so selection alone changes
  nothing; `block_page()` still tags `.sb-app` with `data-sb-style="default"`.
- **overridden** — `...` snake-case overrides emit a
  `<style class="sb-style-overrides">` tag scoped to
  `.sb-app[data-sb-style="<profile>"]` and the runtime/portal roots inside it.
- **scoped** — `scope =` confines the emitted rules to one subtree (and its
  runtime/portal roots) instead of the whole page.

## R API

### `block_style(profile = "default", ..., scope = NULL)`

| Argument | Purpose |
| --- | --- |
| `profile` | Built-in profile name. Supported values come from `block_style_profiles()`. |
| `...` | Named overrides from the fixed allowlist (below). Values emit as `--<mapped-token>: <value>;`. Override values win over profile values. |
| `scope` | Optional CSS selector confining emitted rules to one subtree. |

Returns a `shinyblocks_style` object. Pass it to `block_page(style = )`, which
places `data-sb-style="<profile>"` on `.sb-app` and injects the override
`<style>`. Because the portal root sits inside `.sb-app`, profile tokens reach
dialog, popover, tooltip, and select portal content.

Unknown profile names, unnamed overrides, unknown override names, raw `--sb-*`
CSS-variable names, and invalid `scope` values raise an error at construction.

### `block_style_profiles()` / `block_theme_presets()`

Return the supported style-profile names and the supported colour-palette names,
respectively. One stable data source for callers and (future) playground
controls.

## Override allowlist → CSS token

| R name | CSS property | Default |
| --- | --- | --- |
| `font_body` / `font_heading` / `font_mono` | `--sb-font-*` | `inherit` / `inherit` / system mono stack |
| `control_font_size` / `control_font_weight` | `--sb-control-font-*` | `0.875rem` / `500` |
| `control_height` / `control_height_sm` / `control_height_lg` | `--sb-control-height*` | `2.25rem` / `2rem` / `2.5rem` |
| `control_padding_x` / `control_gap` | `--sb-control-padding-x` / `--sb-control-gap` | `1rem` / `0.5rem` |
| `surface_padding` / `surface_gap` | `--sb-surface-*` | `1.5rem` / `1.5rem` |
| `overlay_padding` / `overlay_gap` | `--sb-overlay-*` | `1.5rem` / `1rem` |
| `control_shadow` / `surface_shadow` / `overlay_shadow` | `--sb-*-shadow` | current control/surface/overlay shadows |
| `focus_ring_width` / `focus_ring_opacity` | `--sb-focus-ring-*` | `3px` / `50%` |
| `disabled_opacity` | `--sb-disabled-opacity` | `0.5` |
| `transition_duration` | `--sb-transition-duration` | `0.15s` |

Defaults equal the historical hardcoded runtime values, so the default profile
is visually identical to pre-Slice-3 shinyblocks.

## Two token tiers (issue #34)

`block_style()` emits two tiers of `--sb-*` tokens:

- **Public allowlist** (`style_token_map()`, table above) — the small, curated,
  ergonomic names a caller may pass via `block_style(...)`. Stable surface.
- **Internal profile tokens** (`style_internal_token_map()`) — finer
  per-component *geometry* tokens (`--sb-<component>-radius`, `-surface`,
  `-border`, `-shadow`) that profiles set as **data** but callers cannot pass via
  `...` (passing one errors as an unknown override). The default runtime CSS
  reads each as `var(--sb-<token>, <historical default>)`, so an unset token is a
  no-op and the default profile is unchanged.
- **Internal translucency tokens** — `--sb-surface-backdrop` plus elevated
  surface backgrounds (`--sb-card-surface`, `--sb-value-box-surface`,
  `--sb-select-content-surface`, `--sb-dialog-surface`,
  `--sb-popover-surface`). They default to `none` or the historical opaque
  colour. They remain internal infrastructure for future user-defined custom
  styles/themes; no built-in `glass` profile ships because shadcn has no
  official `style-glass.css`.

`style_emit_token_map()` is the union (public + internal) that `block_style()`
actually emits; `...` validates against the public tier only. This lets a profile
express component geometry as data — collapsing bespoke `[data-sb-style]` CSS —
without enlarging the public surface. Adding a profile is then an R list in
`style_profiles` plus, at most, a few genuinely-structural CSS rules.

## Built-in profiles

### `default`

Empty override list; its values are the runtime-CSS `--sb-*` defaults above.
Selecting it changes nothing on its own.

### `luma`

Mirrors official upstream Radix Luma
(`apps/v4/registry/styles/style-luma.css`). Built end to end in Slice 4.

**Shared `--sb-*` tokens** (in the `luma` profile list, emitted by
`block_style("luma")`):

| Token | Luma value | vs default |
| --- | --- | --- |
| `control_padding_x` | `0.75rem` | `1rem` |
| `control_gap` | `0.375rem` | `0.5rem` |
| `control_shadow` | `none` | light drop shadow |
| `surface_shadow` | shadow-md | light drop shadow |
| `overlay_gap` | `1.5rem` | `1rem` |
| `overlay_shadow` | shadow-lg | shadow-lg-ish |
| `focus_ring_opacity` | `30%` | `50%` |

Control heights, control typography, surface padding/gap, and overlay padding
already match upstream Luma, so they keep the default values. Fonts stay local
(`inherit`); Luma's bundled `geist` font is not vendored.

**Profile data** — as of issue #34, Luma's radii and surfaces are emitted as
internal geometry tokens (the `luma` list in `R/style-profiles.R`), not CSS:

- **Radii** (`<component>_radius`): card/value-box/button `2rem`, badge/input/
  select/select-content/popover `1.5rem`, textarea/select-item/alert/empty/
  skeleton `1rem`, code `1.25rem`, dialog `2rem`, checkbox `5px`, tooltip
  `0.75rem`.
- **Translucent surface** (`<component>_surface` + `_border` + `_shadow`):
  input/textarea/select use `color-mix(--input 50%)`; checkbox/switch/radio/
  slider-track use `--input 90%`; all flat (`shadow: none`) with a transparent
  border.
- **Foreground ring** (`<surface>_border` + `_shadow`): card/value-box/
  select-content/dialog/popover get a transparent border and a base elevation
  plus a `1px` foreground ring (5%).

**Residual profile-scoped CSS** (`[data-sb-style="luma"]` in
`frontend/src/styles/runtime.css`) — only what a single static token cannot
express:

| Family | Bespoke remainder |
| --- | --- |
| Card | dark-mode-only ring at 10% (block_style emits one static value, not per-mode) |
| Button | `active` press translate, 80% hover |
| Textarea | even padding, locked resize |
| Select | item gap/padding/weight |
| Switch | `border-2`, larger geometry, pill thumb, primary border when checked |
| Slider | thicker track, 24×16 pill thumb with ring |
| Radio group | wider gap, primary-filled (not ring+dot) checked button |
| Dialog | `bg-black/30` blurred scrim |
| Tooltip / Alert / Empty | tighter padding / gaps / dashed border |

Checked checkbox fill is the shared default (primary), so Luma needs no rule for
it.

**Shell-family profile-scoped CSS** (`[data-sb-style="luma"]` in
`inst/www/src/shinyblocks.css`, compiled to `inst/www/shinyblocks.css` by
`make build-css`):

| Family | Luma treatment |
| --- | --- |
| Tabs | `rounded-full` pill list and triggers, wider trigger padding; line variant keeps its flat underline |
| Nav | menu item `rounded-xl` (0.75rem), taller hit target (`min-height` 2.5rem), wider padding |
| Sidebar | wider menu item gap (`.sb-nav` / `.sb-sidebar-nav`), softer toggle radius |
| Field | wider field (`gap` 0.75rem) and group (`gap` 2rem) spacing, `rounded-3xl` transparent fieldset |
| Input group | `rounded-4xl` (2rem) translucent `input/50` surface, transparent border, wider addon padding |

These were the Slice 4/5 deferral; the port landed alongside Slice 5. Values
mirror official upstream Radix Luma (`apps/v4/registry/styles/style-luma.css` +
`radix-luma/ui`).

### `rhea`

Mirrors official upstream Radix Rhea
(`apps/v4/registry/styles/style-rhea.css`). Rhea is a compact Luma: it keeps
the rounded translucent treatment while tightening control heights, padding,
surface gaps, card density, switch width, slider thickness, and shell spacing.
The repeated recipes are profile data in `R/style-profiles.R`; scoped CSS is
limited to structural geometry that cannot be represented by one token.

### `lyra`, `maia`, `mira`, `nova`, `sera`, `vega`

These profiles map to the corresponding official upstream files:
`style-lyra.css`, `style-maia.css`, `style-mira.css`, `style-nova.css`,
`style-sera.css`, and `style-vega.css`.

The first issue #48 port expresses each style as token data:

| Profile | Primary treatment |
| --- | --- |
| `lyra` | compact square controls and surfaces, 1px focus rings |
| `maia` | rounded/pill controls, translucent inputs, ringed surfaces |
| `mira` | extra-compact controls, small radii, subdued focus rings |
| `nova` | balanced compact rounded controls and cards |
| `sera` | editorial square geometry, semibold controls, roomier surfaces |
| `vega` | md-scale radii with subtle shadowed controls and surfaces |

Full structural parity for switch/slider metrics, radio checked-fill models,
shell-family geometry, text transform/letter spacing, and border-width
differences remains follow-up work. The parity registry records those
token-only gaps as explicit neutral entries so they are visible rather than
silently skipped. Lyra has started moving beyond token-only coverage: slider
track/thumb geometry is now measured in the parity registry, and compact square
shell-family rules for tabs, nav, sidebar toggle, fieldset, and input groups are
ported as scoped CSS. The shell rules stay neutral in the current registry
because its shared shell radius bindings already compute to `0px` under the
default profile.

## Conformance and parity (Slice 5)

Profile parity is checked separately from colour conformance so a failure names
the right layer:

- **Palette sweep** — `tools/theme/check-theme-response.mjs` (`npm run
  test:themes-runtime`) drives every `block_theme(preset = ...)` palette through
  the live showcase in light and dark, asserting palettes are distinct and that
  light differs from dark. R is the single source of truth for the emitted
  tokens.
- **Style-profile parity** — `tools/theme/check-style-parity.mjs` (`npm run
  test:style-parity`, `make style-parity`) toggles the page into each
  non-default profile like `block_page(style = block_style("<profile>"))` and
  asserts each component's
  profile-sensitive computed property (radius, padding, gap, height, border
  width) changes.
- **Completeness gate** — `tools/theme/style-registry.mjs` requires every
  component in `RUNTIME_COMPONENT_NAMES` plus the R-side primitives to declare a
  mode: `profile` (measured), `overlay` (portal surface, CSS present), or
  `profile-neutral` (with a reason). A new uncovered component fails the gate.

## Deliberate divergences from shadcn

- The `--sb-*` tokens are shinyblocks-owned, not vendored from shadcn. They are
  a curated, stable public surface; internal CSS stays free to evolve and raw
  CSS-variable names are not a public API.
- No universal spacing or hover multiplier: profiles change related components
  selectively according to the runtime token inventory.
- Fonts stay local and application-owned; profiles ship system stacks only.
- Slice 3 is page-wide; subtree-scoped *style* profiles are deferred. Colour
  `block_theme(scope = )` remains supported.

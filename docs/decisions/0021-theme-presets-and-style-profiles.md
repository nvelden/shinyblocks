# ADR 0021: Theme Presets and Style Profiles

## Status

Proposed (2026-06-01). Not implemented.

## Context

`block_theme()` currently emits scoped light/dark overrides for shadcn-shaped
semantic tokens such as `--background`, `--primary`, `--border`, and `--ring`.
That contract is useful for recoloring components, but it cannot represent a
different visual baseline.

Official shadcn/ui introduced Luma as a style with rounded geometry, soft
elevation, and breathable layouts. The official changelog explicitly says that
Luma goes beyond theming and changes component geometry, spacing, and feel:

- <https://ui.shadcn.com/docs/changelog/2026-03-luma>
- <https://github.com/shadcn-ui/ui/blob/main/apps/v4/registry/styles/style-luma.css>

The local runtime inventory confirms that shinyblocks also has profile-sensitive
values outside its semantic color tokens: control heights, padding, gaps,
radii, shadows, focus treatment, hover emphasis, disabled opacity, and motion.

## Decision

Separate color palettes from visual style profiles.

### Semantic color palettes

`block_theme()` continues to own semantic light/dark colors. A future
`block_theme(preset =)` accepts exactly one built-in palette. Explicit `...`
overrides replace palette values, and explicit `dark` overrides replace both
palette dark values and shared explicit overrides in dark mode.

Built-in palette definitions live in internal R lists. A future
`block_theme_presets()` helper returns supported names.

### Visual style profiles

A future `block_style()` owns typography, spacing, control sizes, shape,
shadows, hover/focus treatment, disabled treatment, and motion. It accepts
exactly one built-in profile plus validated snake-case R overrides mapped to a
curated stable `--sb-*` token set. Raw arbitrary CSS-variable names are not a
public API.

Built-in profile definitions live in internal R lists. A future
`block_style_profiles()` helper returns supported names. The default profile
preserves current shinyblocks visuals. Luma is the first non-default profile.

The first release is page-wide:

```r
block_page(
  style = block_style("luma"),
  theme = block_theme(preset = "olive")
)
```

`block_page()` will place `data-sb-style="<profile>"` on `.sb-app`. The owned
portal root already lives inside `.sb-app`, so inherited profile tokens reach
dialog, popover, tooltip, and select portal content. Subtree-scoped profiles
are deferred; `block_theme(scope =)` remains supported for color overrides.

### Sources of truth

Use internal R lists for built-in palette and profile definitions. The public
authoring API is R-first and the data is small. If maintainer tooling later
needs JSON, generate it from the R lists rather than creating a second editable
source.

### Stable tokens and scoped CSS

Expose a small stable public `--sb-*` profile layer for repeated concepts:
font stacks, control typography, control heights and padding, surface padding
and gaps, surface and overlay shadows, focus-ring metrics, disabled opacity,
and transition duration.

Use component-specific profile tokens or `[data-sb-style]` CSS only where a
shared token would couple unrelated components. Keep fixed implementation
details fixed, including accessibility hiding geometry, portal stacking,
responsive viewport bounds, native-bridge hiding, and code syntax colors.

**Amendment (issue #34): two token tiers.** The component-specific profile
tokens above are formalised as an *internal* tier (`style_internal_token_map()`:
per-component `--sb-<component>-radius`/`-surface`/`-border`/`-shadow`) that
profiles set as data but callers cannot pass via `block_style(...)`. The public
allowlist (`style_token_map()`) is unchanged. `block_style()` emits the union
(`style_emit_token_map()`); `...` validates against the public tier only. The
default runtime CSS reads each internal token as `var(--sb-<token>, <default>)`,
so an unset token is a no-op. This inverts the cost model: a profile is data (an
R list) plus, at most, a few genuinely-structural CSS rules, instead of a
linearly-growing block of `[data-sb-style]` selectors. Luma's radii and
translucent/ring surfaces moved from CSS into the `luma` list accordingly; only
geometry a single static token cannot express (per-mode rings, thumb metrics,
alternative fill models, blurred scrim) remains as scoped CSS.

Do not implement a universal spacing multiplier. Luma changes related
components selectively: for example controls, cards, dialogs, select menus,
fields, and tabs do not all scale by one ratio. A multiplier would produce
untested combinations and make component dimensions less predictable.

### Fonts

Fonts remain local and application-owned. Built-in profiles ship system-font
stacks only. shinyblocks will not download or bundle web fonts. Applications
that require a specific font can load it themselves and pass a family override.

## Why Luma Is Not a Palette

The official Luma stylesheet changes component structure-facing metrics:

- buttons become pill-shaped and use profile-specific heights and gaps;
- inputs, textarea, select, and input groups use translucent input surfaces,
  transparent borders, larger radii, and different focus-ring opacity;
- cards and dialogs use larger gaps, padding, radii, and softer elevation;
- select menus and popovers use larger menu padding, item padding, and radii;
- slider thumbs and switch tracks change geometry, not only color;
- tabs, fields, sidebar items, skeletons, alerts, and empty states change
  component-specific spacing or shape.

Palette substitution cannot express those differences.

## Consequences

Positive:

- Color presets remain composable with visual profiles.
- Current `block_theme(scope =)` behavior remains understandable.
- The public style override surface stays curated and testable.
- Luma rollout can be reviewed family by family without advertising unsupported
  parity.

Costs and risks:

- Runtime and shell CSS must consume profile tokens consistently.
- Some Luma differences require component-specific scoped CSS.
- Portal inheritance and default-profile regression checks become release
  gates.
- Exact upstream font defaults cannot be bundled; local stacks are an
  intentional approximation unless the application supplies a font.
- `block_code()` and shell/navigation helpers are shinyblocks-specific and need
  deliberate profile decisions rather than unsupported upstream parity claims.

## Rollout

1. Record this ADR and the runtime/upstream inventories.
2. Add built-in semantic color presets to `block_theme()`.
3. Add `block_style()`, page-wide profile emission, and stable public tokens
   while preserving current visuals.
4. Add Luma with shared tokens plus narrowly scoped profile CSS.
5. Extend conformance and parity checks for every palette and shipped family.

## Verification Expectations

Implementation slices must verify:

- palette and profile name validation;
- precedence of explicit overrides over built-in values;
- light/dark palette emission and existing `scope =` behavior;
- `.sb-app[data-sb-style]` emission and portal inheritance;
- default-profile visual stability;
- explicit Luma review for every shipped family;
- static token usage plus runtime color and style-profile parity checks.

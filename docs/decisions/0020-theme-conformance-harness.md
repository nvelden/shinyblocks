# ADR 0020: Theme-Conformance Harness

## Status

Implemented (initial slice, 2026-05-29)

## Context

`shinyblocks` promises shadcn-style components that follow a semantic
token system: every color comes from a CSS variable (`--primary`,
`--background`, `--border`, …) so components recolor correctly under
dark mode and under `block_theme()` token overrides.

That promise was not mechanically enforced, and it broke in practice:

- A runtime component (slider thumb) hardcoded `background-color:
  #ffffff`, so it stayed white in dark mode instead of following
  `--background`.
- The **Theme** showcase section rendered `block_theme(primary = "hsl(221.2
  83.2% 53.3%)")`. Because `block_theme()` emitted a *page-wide* `<style>`
  (`.sb-app` + every `[data-shinyblocks-root]`) and the preview rendered
  with `suspendWhenHidden = FALSE`, the demo's blue `--primary` leaked
  across the entire gallery — every checkbox/button/badge rendered blue.

Both are "does this component actually use theme tokens?" failures that
a screenshot review and the shadcn parity harness ([ADR 0016](0016-visual-parity-harness.md))
did not catch. The parity harness diffs computed styles against a shadcn
reference in light and dark, but it does not assert that a given property
is *bound to a token* (i.e. that changing the token changes the render).

We need a reproducible check that (a) guarantees current and future
components are token-driven, and (b) forces every new component to be
covered or fail CI.

## Decision

Adopt a **theme-conformance framework** with two enforcement layers and a
completeness gate. It lives under `tools/theme/` and is dev-only.

### Layer 0 — `block_theme(scope =)` primitive

`block_theme()` gains an optional `scope` selector. Default behaviour is
unchanged (page-wide). With a scope, overrides are confined to that
subtree and the runtime roots inside it (`<scope> [data-shinyblocks-root]`,
which out-specifies the base `[data-shinyblocks-root]` token block). This
is a real feature for multi-theme regions and is what lets the showcase
Theme demo (and parity fixture) theme themselves without leaking into the
gallery.

### Layer 1 — Static token-usage check

`tools/theme/check-token-usage.mjs` scans the hand-authored stylesheets
(`frontend/src/styles/runtime.css`, `inst/www/src/shinyblocks.css`) and
fails when an *applied* color property uses a literal color instead of a
`var(--token)`. Custom-property *definitions* (the token source of truth
and the fixed `--sb-code-token-*` syntax-highlight palette) are skipped.
Intentional, shadcn-accurate literals (destructive `white`, the dialog
`bg-black/50` scrim) live in `tools/theme/color-allowlist.mjs`, each with a
justification. Fast, no browser; runs in the Quality Gate (`make
theme-static`).

### Layer 2 — Runtime token-override check

`tools/theme/check-theme-response.mjs` drives the local showcase with
Playwright. For each binding declared in `tools/theme/theme-registry.mjs`
(component → selector → CSS property → token), it forces the token to a
sentinel color (`* { --token: <sentinel> !important }`) and asserts the
element's computed property becomes the sentinel — in light and dark. A
hardcoded or mis-bound property does not change and fails loudly. This is
the behavioural proof that the component re-colors with the theme.
Transitions/animations are disabled during measurement so the settled
value is read, not the mid-transition value.

### Layer 3 — Completeness gate

`check-theme-response.mjs` reads `RUNTIME_COMPONENT_NAMES` from
`R/runtime.R` (single source of truth) plus an explicit R-side primitive
list, and fails if any is missing from the registry. A new component
cannot ship without either runtime bindings or an explicit
`mode: "static-only"` entry with a reason. Overlays (dialog, popover,
tooltip) are `static-only`: their themed surface only renders on
interaction, but their CSS is token-driven and covered by Layer 1.

### Wiring

- `npm run test:themes` (= `test:themes-static` + `test:themes-runtime`).
- `make theme-static` runs in the Quality Gate; `make theme-test` runs the
  full check against a running showcase.
- The runtime layer reuses the stable `.sb-parity-*` showcase fixtures
  (ADR 0016); `input` and `radio-group` gained fixtures for this.

## Consequences

- Every component is now mechanically guaranteed to honor theme settings,
  and new components are forced into coverage by the gate.
- The slider-thumb hardcode and the Theme-demo leak are fixed as the
  framework's first catches.
- Authoring a component now includes a theme-registry entry (see the
  `shinyblocks-component` skill).
- The runtime layer needs the showcase running and Playwright, so it is a
  `make theme-test` step, not part of the browserless gate; the static
  layer (which catches the most common failure, hardcoded color) is in the
  gate.

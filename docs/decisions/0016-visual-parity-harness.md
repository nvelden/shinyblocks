# ADR 0016: Visual-Parity Harness

## Status

Accepted (2026-05-11)

## Context

`shinyblocks` promises shadcn-look components. The current
verification stack ([ADR 0015](0015-component-specs.md)) is a written
spec doc per component plus a committed reference screenshot, walked
by a human reviewer during Quality Gate item 16. That layer catches
big drift (rounded-rectangle vs pill, wrong colour family) but
provably misses subtler issues that ship anyway — most recently:

- The select trigger renders a Selectize-default arrow glyph
  alongside the masked chevron, visible to anyone who looks.
- The select dropdown shows a "double hover" — the keyboard-cursor
  row and the pointer-hovered row both light up simultaneously.
- The select trigger has `rounded-md` (~6px) where shadcn now uses
  `rounded-lg` (~10px).

These are mechanical CSS differences — `getComputedStyle()` reports
them deterministically. A reviewer staring at a screenshot may or may
not notice. The package needs a mechanical check that catches these
without depending on human attention.

Two natural approaches:

1. **Pixel-diff snapshot tests.** Render shinyblocks alongside a
   shadcn reference in the same headless browser, capture both as
   PNGs, diff with `pixelmatch`, fail above some tolerance. Catches
   everything visual but flakes on anti-aliasing, scrollbars, font
   rendering across machines, and reports "image differs by 0.7%"
   rather than naming the property that drifted.
2. **Computed-style diff.** Same browser session, but for each
   component query `window.getComputedStyle(el)` for a fixed set of
   visual properties (border-radius, background, padding, box-shadow,
   color, font-size, …) and diff the resulting objects
   property-by-property. No tolerance to tune, no flakes, reports
   read like "borderRadius drifts: 8px → 6px".

Computed-style diff catches the bulk of drift that matters; pixel
diff catches the residual (icon glyph paths, complex shadows, layout
where shape matters more than properties).

## Decision

Adopt a **dual-render parity harness** built around computed-style
diff as the primary mechanism, with a small pixel-snapshot tier for
residual visual checks. Both layers are dev-only — they never ship
to CRAN.

### Architecture

```
parity/                              # dev-only React reference app
├── package.json                     # Vite + React + shadcn-ui pinned
├── vite.config.ts
├── src/
│   ├── main.tsx
│   ├── routes.tsx                   # one route per component
│   └── components/
│       ├── select.tsx               # canonical shadcn Select demo
│       ├── button.tsx
│       └── …

tools/parity/                        # capture and diff scripts (Node + Playwright)
├── capture-styles.mjs               # load both apps, capture computed styles
├── diff-styles.mjs                  # compare against committed baseline
├── capture-screenshots.mjs          # residual visual layer
└── README.md

docs/component-specs/_parity/        # committed baselines
├── select.json                      # canonical shadcn computed styles
├── button.json
└── …
```

The reference app serves the shadcn React component for each route.
The capture script loads each route in a Playwright Chromium
instance, locates the canonical element, and serialises:

- The element's computed styles (a fixed property set per component).
- Each interactive state (`hover`, `focus`, `active`, `disabled`,
  `aria-invalid`, plus open/closed for poppers).
- Each theme (`data-theme="light"`, `data-theme="dark"`).

That capture is committed as `docs/component-specs/_parity/<name>.json`
— the canonical "what shadcn computes" baseline.

The same script then loads `http://127.0.0.1:4321` (the shinyblocks
showcase), navigates to the matching component, captures the same
property set in the same states/themes, and diffs against the
baseline. Drift reports include the property name, both values, and
the (component, state, theme) tuple.

### Pinning

`parity/package.json` pins `shadcn-ui`, `react`, `react-dom`,
`tailwindcss`, and any popper / radix dependencies. Bumping shadcn
deliberately produces a baseline regen with visible diff — the
upstream changes never sneak in silently.

### Tolerance

Default: exact-string equality on computed values. Two opt-outs:

1. Some computed values are rounded by the browser (e.g.
   `rgba(0, 0, 0, 0.2980392...)`). Normalise rgba/rgb/hex to the
   same colour space before comparison.
2. Known intentional divergences listed in the spec doc's
   "Deliberate divergences" section get a `known_divergences` key in
   the baseline JSON — those properties skip diff but stay
   documented.

### Pixel-snapshot tier

For icon glyphs and complex shadows where the property is the same
but the rendering differs, a second script captures cropped PNGs of
each component (one per state/theme) under
`docs/component-specs/_screenshots/`. These are committed as the
visual artifact for ADR 0015 spec docs *and* regression-checked with
generous tolerance (`pixelmatch` at ~3%).

### CI integration

`make parity` runs the harness. CI runs it on every PR; failures
block the gate. The script outputs:

```
✓ block_button (default, light) — 27 properties match
✗ block_select (default, light)
  - borderRadius:    "8px"  → "6px"      drift
  - boxShadow:       "0 1px 2px ..." → "none"   drift
  - SelectizeArrow.display:  "block" → "none"   (this is shinyblocks)
✗ block_select (open, light)
  - .option.active backgroundColor:  same colour appears on two rows
```

## Consequences

**Positive:**

- The kind of drift that shipped in v0.0.0.9000 select (arrow,
  hover, radius) becomes test-failing instead of reviewer-dependent.
- Property-named diffs make fixing fast — the test tells you what
  changed, not just that something did.
- Pin + diff is the right pattern for "track upstream deliberately"
  — bumping shadcn produces a single PR with the visible delta.
- Dark mode is automatically covered — same script, theme toggled.

**Negative / accepted costs:**

- Real toolchain: Node, Playwright, the React reference app. All
  dev-only. The package itself ships unchanged.
- ~300MB Chromium binary for Playwright (cached locally; CI
  downloads on each fresh runner).
- Initial baseline capture: ~5 min/component × 40 = several hours.
  Incremental from there.
- Selectize-rendered components (select, textarea) will need their
  own treatment — the rendered DOM differs from shadcn's even when
  the *intent* matches. Either:
  - Compare against shadcn's Radix Select (different DOM, expect
    structural diff; only token-level computed styles match), or
  - Accept the divergence in the spec doc and skip those properties
    in the baseline.

**Out of scope for this ADR:**

- Cross-browser parity (Firefox, WebKit). Chromium only at first.
- Animation timing parity (transitions, motion). Captures freeze
  state, not motion.
- Accessibility tree parity. Spec docs + manual a11y sweep stay
  authoritative for now.

## Implementation order

Documented in
[`docs/agent-plans/2026-05-09-phase-5-handoff.md`](../agent-plans/2026-05-09-phase-5-handoff.md)
as a dedicated slice. The skeleton lands first (one component:
`select`, since it has known drift). Per-component baselines extend
incrementally, same pattern as the spec backfill.

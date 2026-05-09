# ADR 0015: Component Visual-Parity Specs

## Status

Accepted (2026-05-09)

## Context

`shinyblocks` ports the shadcn/ui design system into a Shiny package.
The pitch is that user-visible components look like shadcn — the same
radii, the same token-driven colour roles, the same focus rings, the
same hover and selected behaviours — without users running Node, React,
or Tailwind.

That promise is easy to break in small ways. A single `bg-secondary`
silently drifts to `bg-muted` and the badge no longer matches its
shadcn counterpart. A focus ring uses `--ring` on one component and
`outline` on another. The `disabled` opacity is `0.5` here and `0.6`
there. Each drift on its own is invisible; together they erode the
"feels like shadcn" claim that justifies the package's existence.

Catching this drift requires **a fixed reference**. Today the only
reference is each maintainer's memory of the shadcn docs. Quality Gate
item 15 ("Interaction-style parity") asks the reviewer to walk every
state of every component touched in the phase against the shadcn
contract, but without a written contract, the review collapses into
"looks fine to me".

Two options for raising the bar:

1. **Pixel-diff against shadcn-react.** Headless browser, two reference
   apps, screenshot tolerance tuning, fragile under font-rendering
   differences and Bootstrap leakage. High setup cost, high false-
   positive rate, low signal until the package is much larger.
2. **A short written spec per component.** One markdown file per
   exported `block_*()` capturing the shadcn reference URL, the full
   list of states the component must render, the token contract, and
   any deliberate divergences. A reviewer-anchored process that scales
   with the package and survives shadcn's own upstream changes.

## Decision

Each exported `block_*()` ships with a **component spec** at
`docs/component-specs/<name>.md`. The spec follows the template in
`docs/component-specs/_template.md` and contains five sections:

1. **Reference link** — the canonical shadcn docs page, e.g.
   `https://ui.shadcn.com/docs/components/select` (or the `/radix/`
   variant when applicable).
2. **States** — every visual state the component must render. The
   reviewer walks each one during Quality Gate item 15.
3. **Token contract** — a small table mapping visual roles (surface,
   foreground, border, focus ring, accent on hover, …) to the
   semantic CSS variable that drives them.
4. **Deliberate divergences** — anywhere shinyblocks knowingly
   differs from shadcn, with the reasoning. This is the audit trail
   that prevents "drift" from being relabelled as "intent" after the
   fact.
5. **Reference screenshot** — one image captured from the shadcn docs
   page on a known date, committed under
   `docs/component-specs/_screenshots/<name>.png`. This anchors the
   spec to a specific upstream snapshot; when shadcn changes, the
   delta is visible and the spec is updated deliberately.

### Enforcement

`tests/testthat/test-doc-coverage.R` grows a third coverage block
that asserts every exported `block_*()` has a matching
`docs/component-specs/<name>.md`, with the same shape as the existing
pkgdown-reference and gallery checks. The check is active immediately
for new components.

A `backfill_pending` allowlist in the test names every component that
exists today without a spec, so the suite stays green while the
backfill happens. Each spec written shrinks the list; a separate
assertion fails if a `backfill_pending` entry quietly gains a spec
without being removed from the list, so the gap stays honest.

When `backfill_pending` is empty, the test enforces specs
unconditionally and the allowlist is removed.

### Per-gate component-sync rule

The §Per-gate component-sync rule in `docs/ROADMAP.md` grows a fifth
artifact alongside showcase, pkgdown reference, gallery, and NEWS.
The Quality Gate item 6 (Tests) covers the mechanical check via
`test-doc-coverage.R`; item 15 (Interaction-style parity) becomes
"review against the spec doc, not from memory", with the spec's
reference screenshot as the anchor.

## Consequences

**Positive:**

- Visual parity becomes verifiable. A reviewer can walk every state
  listed in the spec and check off the corresponding render in the
  showcase.
- Token drift is caught at PR time — `bg-secondary` vs `bg-muted` is
  visible in a 5-line table, not buried in 200 lines of CSS diff.
- Deliberate divergences from shadcn become explicit and reviewable
  (e.g. "we keep the label outside the trigger to match Shiny's input
  id contract"), instead of unspoken assumptions.
- When shadcn updates upstream, the committed reference screenshot
  surfaces the delta. The spec is updated deliberately rather than
  silently drifting.

**Negative / accepted costs:**

- One short markdown file per exported component. ~30 lines of mostly
  mechanical content. Scales linearly with surface area, which is the
  intended cost — every new component is a parity commitment.
- Reference screenshots have to be captured manually until shadcn
  exposes them as static assets at stable URLs. Acceptable: the
  screenshot is a once-per-component task and a once-per-shadcn-bump
  refresh.
- Backfill is real work. Mitigated by the `backfill_pending`
  allowlist — the rule applies to new components today, existing
  components catch up incrementally without blocking other work.

**Out of scope for this ADR:**

- Automated pixel-diff against shadcn-react. The setup cost outweighs
  the value before v0.1; revisit post-CRAN if drift becomes a real
  problem.
- Cross-framework parity (matching the bslib port, the Vue port).
  Each framework adapts shadcn under its own constraints; chasing
  cross-framework pixel parity is a moving target.
- Per-component playwright/shinytest2 visual regression. The existing
  Quality Gate item 11 already covers regression-against-self via
  `expect_screenshot()`. The spec doc covers parity-against-shadcn,
  which is a different question.

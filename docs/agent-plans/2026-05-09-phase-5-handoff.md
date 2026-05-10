# Phase 5 Hand-off (2026-05-09)

A consolidated, actionable hand-off plan for the next implementer
picking up Phase 5 of `shinyblocks`. Each slice below is sized to
land as one commit.

## Context

Phase 5 components have landed (forms, tabs, theme runtime), but the
shadcn-fidelity audit on 2026-05-09 surfaced three cross-cutting
visual drifts plus a reference-screenshot gap. The decisions and
scaffolding for follow-up are already in place:

- [ADR 0014](../decisions/0014-wrap-by-default-form-inputs.md) —
  wrap-by-default for form inputs.
- [ADR 0015](../decisions/0015-component-specs.md) — per-component
  spec doc with reference screenshot.
- [Shadcn fidelity audit](2026-05-09-shadcn-fidelity-audit.md) — the
  per-component drift findings the slices below derive from.
- [Per-gate component-sync rule](../ROADMAP.md#per-gate-component-sync-rule) —
  showcase, pkgdown reference, gallery, spec, NEWS must stay in sync.

The previous slice fixed the safe drifts (badge `rounded-full` +
`text-xs`, button link `text-primary`, button outline `shadow-xs`,
destructive `text-white` + dark-mode dim). What's left is structural.

## Slice order

The slices are listed in the order they should land. Slices 1 and 2
both touch every interactive component's CSS — bundle them so the
visual changes ship together.

### Slice 1 — Focus-visible redesign

**Why first:** the global focus-visible rule in `.sb-app *` overrides
component-specific focus styling. shadcn applies a softer 3px ring
per-component. Until this lands, every other focus-related fix is
working around the global rule.

**Scope:** Replace the global focus rule with per-component styling.

**Files to edit:**
- `inst/www/src/shinyblocks.css` — drop the rule at lines 70–74
  (`.sb-app :where(button, a, ...) :focus-visible { outline: 2px solid var(--ring) }`).
- Add `focus-visible` styling to each interactive base class:
  `.sb-button`, `.sb-badge` (link/anchor wrap),
  `.sb-nav-item`, `.sb-tabs .nav-link`, `.sb-tabs-trigger`,
  `.sb-select`, `.sb-checkbox-control:focus-visible + .sb-checkbox-indicator`,
  `.sb-switch-control:focus-visible + .sb-switch-track`.

**Concrete pattern** (apply to each interactive base):

```css
/* Replace `outline: 2px solid var(--ring); outline-offset: 2px;` */
.sb-button {
  /* existing rules */
  outline: none;
}

.sb-button:focus-visible {
  border-color: var(--ring);
  box-shadow: 0 0 0 3px color-mix(in oklch, var(--ring) 50%, transparent);
}
```

For controls without a border (e.g. `.sb-button-default`), the
`box-shadow` ring still renders correctly. Add `transition: all
0.15s ease` to the base if not already present so the ring animates.

**Tests likely to update:**
- `tests/testthat/test-shell.R` — class-shape tests should be
  unaffected (they assert classes, not CSS). Confirm by running
  `devtools::test()`.
- No snapshot tests assert focus styles directly.

**CSS rebuild:** `make build-css`.

**Validation:**
1. Run `make verify` and tab through each component in the showcase.
2. Compare against
   <https://ui.shadcn.com/docs/components/button> in light + dark.
3. Update `docs/component-specs/button.md` → "Token contract" → add
   `Focus ring | --ring` row if not already present (it is; reword if
   the visual changed). Note the new ring shape (3px, 50% opacity)
   in the divergences section if it doesn't match shadcn exactly.

**Definition of done:**
- Global `.sb-app *:focus-visible` rule removed.
- Every interactive component has its own `:focus-visible` styling
  using the 3px ring pattern.
- 275+ tests pass (no regressions).
- `make verify` shows the new ring on every component, light + dark.

---

### Slice 2 — `aria-invalid` cross-cut

**Why second:** pairs with the focus-ring change because both touch
the same CSS bases. Ship together if possible.

**Scope:** Add `aria-invalid` styling to every interactive component
so `block_field_invalid()` produces a consistent visual, and so any
control that gets `aria-invalid="true"` from server-side validation
renders correctly.

**Files to edit:**
- `inst/www/src/shinyblocks.css` — add to each interactive base:

```css
.sb-button[aria-invalid="true"],
.sb-button[aria-invalid="true"]:focus-visible {
  border-color: var(--destructive);
  box-shadow: 0 0 0 3px color-mix(in oklch, var(--destructive) 20%, transparent);
}

[data-theme="dark"] .sb-button[aria-invalid="true"] {
  box-shadow: 0 0 0 3px color-mix(in oklch, var(--destructive) 40%, transparent);
}
```

Apply the same pattern (selector adapted) to `.sb-select`,
`.sb-textarea`, `.sb-checkbox-control + .sb-checkbox-indicator`,
`.sb-switch-control + .sb-switch-track`, and any other control that
accepts `aria-invalid`.

- `R/field.R` — confirm `block_field_invalid()` already adds
  `aria-invalid="true"` to wrapped inputs (it does, at lines
  136–146). No change needed unless the audit pass surfaces a
  control it misses.

**Tests:**
- Add a test in `tests/testthat/test-shell.R` covering the
  `aria-invalid` attribute on each control type (button, select,
  textarea, checkbox, switch).
- Update `tests/testthat/_snaps/utils.md` if any snapshot drifts.

**Validation:**
- `make verify` + visit a showcase example wrapped in
  `block_field_invalid()`. Confirm the destructive ring appears in
  both light and dark modes.

**Definition of done:**
- Every interactive control honours `aria-invalid="true"` with the
  destructive ring.
- New tests cover the attribute pass-through and styling.
- Spec docs for the affected components note the new state in the
  "States" section.

---

### Slice 3 — Tabs refactor to shadcn's data-attribute model

**Why third:** independent of slices 1–2 but the largest piece of
work; tackle once the simpler cross-cuts are in.

**Scope:** Replace the Bootstrap-class-leaning `.nav-link.active` /
`.tab-pane[hidden]` markup with shadcn's
`data-state` / `data-orientation` / `data-variant` attribute model.
Add the `line` variant.

**Files to edit:**
- `R/tabs.R` — `block_tabs()` and `block_tab()` emit
  `data-state="active|inactive"`, `data-orientation="horizontal|vertical"`,
  `data-variant="default|line"`.
- `inst/www/src/shinyblocks.css` — replace the `.sb-tabs .nav-link`,
  `.sb-tabs .nav-link.active`, `.sb-tabs .tab-pane` rules
  (lines 200–231) with shadcn's selectors against the new
  attributes. Reference: the canonical source pulled in the audit
  doc.
- `inst/www/shinyblocks.js` — if the current tab activation logic
  toggles the Bootstrap classes, retarget it to the data-attributes.
- `inst/showcase/R/examples/tabs.R` — verify the example still
  renders both variants (default + new line).
- `tests/testthat/test-shell.R` — update tabs tests.
- `docs/component-specs/tabs.md` — new spec doc per ADR 0015.

**Reference:** the canonical shadcn tabs source extracted in the
audit doc, §Tabs.

**Definition of done:**
- Tabs markup is data-attribute-driven, no Bootstrap class names
  required.
- Both `default` and `line` variants render.
- Tabs-related tests pass.
- `tabs.md` spec doc lands and `tabs` is removed from
  `backfill_pending_specs` in
  [`tests/testthat/test-doc-coverage.R`](../../tests/testthat/test-doc-coverage.R).

---

### Slice 4 — Reference screenshots for seed specs

**Why:** the per-gate sync rule treats the reference screenshot as
the shadcn ground truth. Today the seed specs ([button.md](../component-specs/button.md),
[card.md](../component-specs/card.md)) link to the canonical URLs but
don't have committed images. Without the screenshot, Quality Gate
item 15 has no anchor.

**Scope:** Capture both light and dark-mode screenshots for the seed
specs.

**Steps (per [docs/component-specs/README.md](../component-specs/README.md)):**

1. Open `https://ui.shadcn.com/docs/components/button` in a clean
   browser window, default zoom, light theme. Render the canonical
   variant grid above the fold. Crop tight, no surrounding chrome.
   Save as `docs/component-specs/_screenshots/button.png`.
2. Toggle the shadcn site to dark mode, repeat. Save as
   `docs/component-specs/_screenshots/button-dark.png`.
3. Repeat for card.
4. Update both spec docs with the capture date in the "Reference
   screenshot" section.

**Definition of done:**
- Four PNGs committed under `docs/component-specs/_screenshots/`.
- Spec docs updated with capture dates.

---

### Slice 5 — Spec-doc backfill (incremental)

**Status:** completed. Every exported `block_*()` now has a written spec
doc. The remaining ADR 0015 work is reference-screenshot capture and
ongoing parity review against those captures.

**Scope per component (recipe):**

1. Copy [`docs/component-specs/_template.md`](../component-specs/_template.md)
   to `docs/component-specs/<slug>.md` (slug = function name minus
   `block_` prefix, with `_` replaced by `-`).
2. Pull the canonical shadcn source from
   `https://raw.githubusercontent.com/shadcn-ui/ui/main/apps/v4/registry/new-york-v4/ui/<name>.tsx`
   to fill in token contract + variants.
3. Capture light + dark screenshots from
   `https://ui.shadcn.com/docs/components/<slug>` per slice 4.
4. Document any deliberate divergences with reasoning.
5. Run `devtools::test(filter = "doc-coverage")` — the test now
   enforces specs for every exported `block_*()` unconditionally.

**Definition of done for Phase 5:**
- all spec docs are present
- reference screenshots are captured for each spec

---

### Slice 6 — Gallery resumption (blocked on WASM)

**Why blocked:** [ADR 0013](../decisions/0013-component-gallery-quarto.md)
requires a gallery `.qmd` page per component, but live shinylive
demos depend on a webR-loadable shinyblocks binary at
`repo.r-wasm.org`. The path-B WASM build was deferred — the gallery
test in
[`tests/testthat/test-doc-coverage.R`](../../tests/testthat/test-doc-coverage.R)
is `skip()`'d at line 61.

**When WASM unblocks:**
1. Drop the `skip()` call.
2. Author one `gallery/components/<name>.qmd` per exported component
   following the template in
   [`docs/decisions/0013-component-gallery-quarto.md`](../decisions/0013-component-gallery-quarto.md).
3. Author one `gallery/components/_examples/<name>.R` per
   component — a complete runnable Shiny app (not just a tag
   fragment).
4. Update `_pkgdown.yml` `articles:` to list every page (block was
   removed in commit `a787efc`; restore from git blame and extend).
5. Run `make gallery` and verify each page renders the live demo
   plus the visible source.

**Definition of done:**
- `test-doc-coverage.R` gallery test passes unconditionally.
- pkgdown navbar Components entry restored.
- `make gallery` serves the full set at `:4324`.

---

## Quality Gate at Phase 5 exit

Before tagging, every slice above must be green and:

1. `make gate` passes (runs build-css, lint, spell, urls, test, docs,
   check, pkgdown, budget, doc-links, verify).
2. `make verify` leaves both servers responding 200 — eyeball the
   showcase + pkgdown side by side.
3. Quality Gate item 15: walk every state listed in every spec
   against the showcase, in light and dark mode. The reference
   screenshot is the shadcn ground truth.
4. Critical-code-reviewer skill against the phase diff.
5. Manual a11y sweep on the showcase per Quality Gate item 13.
6. Performance budget: CSS ≤10 KB gzipped, JS ≤15 KB raw, sprite ≤25 KB gzipped.

## Files to read before starting

- [docs/agent-plans/2026-05-09-shadcn-fidelity-audit.md](2026-05-09-shadcn-fidelity-audit.md) — drift findings.
- [docs/decisions/0014-wrap-by-default-form-inputs.md](../decisions/0014-wrap-by-default-form-inputs.md).
- [docs/decisions/0015-component-specs.md](../decisions/0015-component-specs.md).
- [docs/component-specs/_template.md](../component-specs/_template.md) and the seed specs.
- [docs/ROADMAP.md](../ROADMAP.md) §Per-gate component-sync rule and §Quality Gate.
- [inst/www/src/shinyblocks.css](../../inst/www/src/shinyblocks.css) — full source.
- The canonical shadcn registry:
  <https://github.com/shadcn-ui/ui/tree/main/apps/v4/registry/new-york-v4/ui>

## Things not to break

- The wrap-by-default policy ([ADR 0014](../decisions/0014-wrap-by-default-form-inputs.md)).
  Don't reintroduce headless input runtimes.
- Tailwind v4 source contract ([ADR 0006](../decisions/0006-styling-foundation.md)).
  Compiled CSS must regenerate cleanly via `make build-css`.
- Per-gate sync rule. Every new spec/page/example/section must land
  with its component, not as follow-up.
- The showcase contract — every export shows up in
  `inst/showcase/`, enforced by `test-showcase.R`.
- The pkgdown reference parity, enforced by `test-doc-coverage.R`.

## Pitfalls

- The global `.sb-app *:focus-visible` rule (lines 70–74 of the CSS
  source) silently overrides per-component focus styles. Removing it
  is part of slice 1; until then any per-component focus work is
  invisible.
- `htmltools::tags$button(disabled = NA)` produces `<button disabled>`
  (boolean attribute). `disabled = TRUE` produces `disabled="TRUE"`.
  Tests assume the boolean form.
- `data-sb-child` markers (e.g. `card-header`, `alert-title`) are
  the contract that lets parents reuse pre-built region tags.
  Adding a new composition primitive means adding the marker.
- Quarto 1.4 vs 1.5 — the gallery is currently outside `vignettes/`
  to sidestep the 1.5 requirement. Don't move it back without
  upgrading the toolchain.

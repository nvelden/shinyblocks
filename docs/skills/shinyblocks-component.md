---
name: shinyblocks-component
description: End-to-end recipe for adding (or refactoring) a `block_*()` component in the shinyblocks R package. Covers the per-gate sync rule (R + CSS + showcase + tests + spec doc + pkgdown reference + NEWS), the shadcn-fidelity workflow against the `apps/v4/registry/new-york-v4` source, and the mechanical visual-parity harness under `tools/parity/`. Use when the user asks to "add a component", "implement block_X", "port shadcn X to shinyblocks", "wrap shiny::Y as a block", or "improve the parity of an existing block_*()".
metadata:
  version: "1.0"
---

# Adding a shinyblocks component

A new exported `block_*()` is **not** a single-file change. It must
land with six other artifacts in the same commit or the gate fails.
This skill is the recipe for getting all of them right and verifying
the result against shadcn mechanically.

## Required reading (do this first)

Read in this order. Each is short and load-bearing.

1. [`docs/decisions/0014-wrap-by-default-form-inputs.md`](../decisions/0014-wrap-by-default-form-inputs.md) — wrap-by-default policy for form inputs. **Do not** reinvent input runtimes when a Shiny widget already exists.
2. [`docs/decisions/0015-component-specs.md`](../decisions/0015-component-specs.md) — every component ships with a spec doc + reference screenshot.
3. [`docs/decisions/0016-visual-parity-harness.md`](../decisions/0016-visual-parity-harness.md) — the mechanical computed-style + DOM diff harness against pinned shadcn-react. POCs are in `tools/parity/`.
4. [`docs/ROADMAP.md` §Per-gate component-sync rule](../ROADMAP.md#per-gate-component-sync-rule) — the artifact-sync contract.
5. The canonical shadcn source for the component you're adding:
   `https://raw.githubusercontent.com/shadcn-ui/ui/main/apps/v4/registry/new-york-v4/ui/<name>.tsx`.

## Step 0 — Decide: wrap or build?

| Shadcn component is… | shinyblocks treatment | Examples |
| --- | --- | --- |
| A form input with a Shiny equivalent (select, slider, textarea, checkbox, switch, radio, etc.) | **Wrap.** Call `shiny::*Input()`, override the rendered widget's CSS to match shadcn. Per ADR 0014. | `block_select`, `block_slider`, `block_checkbox` |
| A presentational element (button, badge, card, alert, separator, skeleton, …) | **Build.** Emit `htmltools::tags$...` directly with shadcn-matching classes. | `block_button`, `block_card`, `block_alert` |
| A composition primitive (card-header, alert-title, …) | **Build** as a thin tagged wrapper with `data-sb-child` marker so parents can validate. | `block_card_header`, `block_alert_title` |

If unsure, default to **wrap**. ADR 0014 explains the cost of going the other way.

## Step 1 — Implement the R function

Put it in the right file:

| Component kind | File | Pattern to follow |
| --- | --- | --- |
| Layout shell | `R/layout.R` or `R/page.R` | `block_sidebar`, `block_header` |
| Content | `R/components.R` | `block_card`, `block_alert` |
| Form wrapper | `R/form-controls.R` or `R/field.R` | `block_checkbox`, `block_slider` |
| Form composition primitive | `R/field.R` | `block_field_*` |

Required scaffolding for every exported function:

```r
#' One-line title
#'
#' Detailed paragraph. Cross-link relevant ADRs.
#'
#' @param ... documented per param.
#' @return An `htmltools` tag.
#' @family <category>   # one of: layout, navigation, content, action, forms, icon
#' @export
block_<name> <- function(...) {
  # 1. Validate arguments early with stop(call. = FALSE).
  # 2. For wrappers: call the Shiny widget, modify with htmltools::tagQuery().
  # 3. For builders: emit tags directly.
  # 4. Always wrap the result in attach_shinyblocks_deps() so the CSS
  #    + sprite are picked up.
}
```

**Validation patterns** (copy these):

- `missing(value) || !is.numeric(value)` → `"must be one or two numeric values"`
- `min >= max` → `"must be strictly less than max"`
- `!variant %in% c(...)` → use `match_arg()` from `R/utils.R`

## Step 2 — CSS

Fetch the canonical class string from shadcn first. The harness will
compare against it, so getting this right up front saves churn:

```bash
curl -s https://raw.githubusercontent.com/shadcn-ui/ui/main/apps/v4/registry/new-york-v4/ui/<name>.tsx
```

Then edit `inst/www/src/shinyblocks.css`:

- Use `@apply` for Tailwind-utility-equivalents. Tailwind v4 source.
- Token contract: `var(--primary)`, `var(--muted)`, `var(--ring)`, etc. **Never raw colour values.** The one exception is `#ffffff` for the slider thumb fill (matches shadcn's `bg-white`).
- For wrappers (Selectize, ion.rangeSlider, …), use `!important` on every override. The underlying widget's CSS is loaded after yours and otherwise wins.
- For relative positioning of multiple roles (rail+thumb, trigger+chevron, …), prefer **`top: 50% !important; transform: translateY(-50%) !important;`** over fixed pixel offsets so the geometry survives any container-height changes.

Rebuild: `make build-css`. The compiled output at `inst/www/shinyblocks.css` is committed.

## Step 3 — Wire the seven artifacts (sync rule)

The per-gate sync rule says all seven land in the **same commit**:

| Artifact | Location | What to add |
| --- | --- | --- |
| R function | `R/<file>.R` | Step 1 above |
| Exported in NAMESPACE | auto via `devtools::document()` | Run `Rscript -e 'devtools::document()'` |
| pkgdown reference | `_pkgdown.yml` | Add `- block_<name>` under the matching category |
| Showcase example | `inst/showcase/R/examples/<name>.R` | A tag/tagList showing default + interesting variants |
| Showcase section | `inst/showcase/app.R` | Row in the `sections` list (id, label, icon, title, lead, file) |
| Unit tests | `tests/testthat/test-shell.R` | Tag-shape, attribute, validation, ARIA |
| Spec doc | `docs/component-specs/<slug>.md` | Five sections per template — link, states, tokens, divergences, reference screenshot |
| NEWS bullet | `NEWS.md` | One bullet under the dev-version heading |

The rule is enforced by [`tests/testthat/test-doc-coverage.R`](../../tests/testthat/test-doc-coverage.R) — every export must have a pkgdown entry **and** a spec doc, or the test fails.

The showcase part is enforced by [`tests/testthat/test-showcase.R`](../../tests/testthat/test-showcase.R) — every export must put its `sb-<name>` class somewhere in the rendered showcase UI.

## Step 4 — Spec doc

Copy [`docs/component-specs/_template.md`](../component-specs/_template.md) to `<slug>.md` where slug is the function name minus `block_`, with `_` → `-`. Fill in the five sections:

1. **Reference link** — `https://ui.shadcn.com/docs/components/<slug>`.
2. **States** — every visual state to verify. Default, hover, focus-visible, active, disabled, aria-invalid, plus component-specific open/checked/selected/etc.
3. **Token contract** — table mapping visual roles to CSS variables.
4. **Deliberate divergences** — anywhere shinyblocks knowingly differs. Each entry with reasoning.
5. **Reference screenshot** — add a markdown image pointing at
   ``_screenshots/<slug>.png`` plus the capture date in the spec doc.

For wrap-by-default components, the divergences section is usually 3–5 entries (different DOM, hidden default labels, etc.). Write them honestly.

## Step 5 — Parity harness

Copy [`tools/parity/slider-poc.mjs`](../../tools/parity/slider-poc.mjs) (the most complete POC) as the template. Adapt:

1. **`SHADCN_URL`** — the docs page for your component.
2. **`SHOWCASE_URL`** — `http://127.0.0.1:4321/#<section-id>`.
3. **`SECTION`** — the section id you added to `inst/showcase/app.R`.
4. **Selectors** — find the matching elements in both apps. For wrappers, the DOM differs (Selectize vs Radix, ion.rangeSlider vs Radix Slider, etc.) — map roles, not selectors.
5. **`PROPS` arrays** — split by role if the component has multiple parts (rail/range/thumb, trigger/dropdown/option).

**Property set must include** at minimum:

- Geometry: `width`, `height`, `display`, `position`, `top`, `marginTop`, `transform`.
- Visual: `backgroundColor`, `color`, `borderRadius`, `borderTopColor`, `borderTopWidth`, `borderTopStyle`, `boxShadow`.
- Typography (if text-bearing): `fontSize`, `fontWeight`, `lineHeight`, `letterSpacing`, `padding*`.

**Cross-element geometry check** — for multi-role components, add a
`getBoundingClientRect()` assertion that two parts are aligned. This
is the lesson from the slider POC; property-by-property diff missed
the off-centre thumb until we added this. Example pattern:

```js
const geometry = await page.evaluate(() => {
  const a = document.querySelector("...");
  const b = document.querySelector("...");
  const ra = a.getBoundingClientRect();
  const rb = b.getBoundingClientRect();
  return {
    aCenterY: ra.top + ra.height / 2,
    bCenterY: rb.top + rb.height / 2,
    delta: Math.abs((ra.top + ra.height / 2) - (rb.top + rb.height / 2)),
  };
});
// Fail if delta > 1.5px.
```

**Dark mode capture** — toggle `data-theme="dark"` on `<html>` (and
`class="dark"` on the shadcn side) before re-capturing. Diff each
mode against the matching shadcn mode. Don't assume "if light mode
matches, dark mode matches" — the slider POC confirmed dark-mode
tokens flow correctly, but only because dark mode was captured.

**Interactive states** — for components with hover/focus/open/etc.,
use `page.hover()`, `page.focus()`, or `page.click()` before
recapturing.

**Hidden-label audit** — for wrappers around Shiny widgets, audit
that any widget-default chrome you wanted to hide actually has
`display: none`. The slider POC does this for `.irs-min`, `.irs-max`,
`.irs-single`, etc.

## Step 6 — Run the harness, iterate

```bash
# In one terminal:
make showcase                # starts the live shinyblocks app on :4321

# In another:
node tools/parity/<name>-poc.mjs
```

Read the output:

- **Match** lines: nothing to do.
- **Drift** lines: either a real bug to fix, or a documented
  divergence. Decide which and act accordingly.
- **Geometry delta > 1.5px**: real bug. Fix.
- **Hover ring**: confirm `oklch(<ring> / 0.5) 0px 0px 0px 4px` (or
  shadow equivalent). If absent, missing `:hover` rule.
- **Hidden-label audit failures**: a Shiny-widget-default leaked
  through; add `!important` `display: none` for that selector.

**Common fixes by symptom:**

| Symptom in harness | Fix |
| --- | --- |
| `top: <pixels>` differs and geometry delta > 0 | Use `top: 50% !important; transform: translateY(-50%) !important;` |
| Computed value is e.g. `oklch(0.97 0 0)` while shadcn is `lab(96% 0 0)` | Same colour, different space. Harness limitation. Document in divergences. |
| Container height wrong | Pin with `!important` (ion.rangeSlider/Selectize defaults often win without it) |
| Inner wrapper messes up positioning | Set wrapper `height: 100% !important;` so percentage offsets work |
| Custom widget renders its own arrow/chevron next to ours | Hide the widget default with `!important; display: none` or `visibility: hidden`; mask in the Lucide glyph via `::after` with `mask-image:` |

Iterate: fix → `make build-css` → re-run harness → repeat until the
remaining drifts are all documented divergences.

## Step 7 — Document divergences in the spec

Every drift that the harness flags but you decided **not** to fix
goes into the spec's "Deliberate divergences from shadcn" section
with reasoning. Anyone running the harness later will see the same
drift; the spec is what tells them "this is expected, not a bug".

Categories you'll see:

1. **Colour-space normalisation** — `oklch` vs `lab` vs `rgb`. Same colour, different syntax. Harness limitation; ADR 0016 §Architecture covers the fix.
2. **DOM divergence** — wrap-by-default components have a different DOM than shadcn-react. The visual contract matches; the DOM doesn't. Document with the role mapping.
3. **Source vs docs-render** — sometimes shadcn's docs page renders thinner/smaller than its own published source spec. Match the source; document the docs-site discrepancy.
4. **Theme differences** — shadcn docs site customises `--primary` etc. shinyblocks uses default canonical tokens. Document and move on.

## Step 8 — Run the gate

```bash
make build-css                # CSS source matches compiled output
Rscript -e 'devtools::document()'   # NAMESPACE + man/ in sync
Rscript -e 'devtools::test()'       # all R tests including doc-coverage
make verify                   # showcase + pkgdown both responding 200
```

If `test-doc-coverage.R` reports a missing pkgdown entry or missing
spec, you skipped step 3 or 4. Go back.

If `test-showcase.R` reports a missing showcase section, you didn't
add the row to `inst/showcase/app.R`'s `sections` list. Go back.

If `make verify` fails to render: read `.verify-pkgdown.log` and
`.verify-showcase.log` for the actual error.

## Step 9 — Commit

One commit, all artifacts. Suggested commit-message shape:

```
feat: block_<name>() — <shadcn-component-name> wrapper / port

R/<file>.R          — wrap shiny::<widget> with token-driven styling
inst/www/src/       — ion.rangeSlider/Selectize/etc overrides for
                      shadcn parity
inst/showcase/      — gallery section + example
_pkgdown.yml        — Forms/Content/Action reference entry
tests/              — tag-shape + validation cases
docs/component-specs/<slug>.md   — spec per ADR 0015
tools/parity/<name>-poc.mjs      — visual-parity check

Parity harness verdict: X drifts surfaced, Y fixed, Z documented as
deliberate divergences. <bullet list of fixes>.
```

## Pitfalls (real bugs that have shipped)

- **Off-centre thumb in slider.** Symptom: thumb visually floats above the rail. Cause: harness `THUMB_PROPS` didn't include `top`/`transform`, and didn't cross-check rail vs thumb bounding rects. Fix: add positioning to property set and a centring assertion (the [slider-poc.mjs](../../tools/parity/slider-poc.mjs) is the corrected template).
- **Selectize trigger had `rounded-md` instead of `rounded-lg`.** Symptom: trigger looks rectangular vs shadcn's lozenge. Cause: relied on Selectize default for radius. Fix: explicit `border-radius: var(--radius-lg) !important;`.
- **Double-hover in select dropdown.** Symptom: keyboard-selected row and pointer-hovered row both lit up at the same time. Cause: `.option.selected` styled with the same accent fill as `.option:hover`. Fix: drop the `.option.selected` background; mark selected with font weight only.
- **Container height wrong.** ion.rangeSlider/Selectize set their container heights via their own CSS. Without `!important`, your shorter container loses. Always pin.

## Checklist (every component PR)

Before committing, run through this:

- [ ] `Rscript -e 'devtools::document()'` clean
- [ ] `Rscript -e 'devtools::test()'` clean (including `test-doc-coverage.R` and `test-showcase.R`)
- [ ] `make build-css` clean (committed CSS matches source)
- [ ] `make verify` brings up both servers at 200
- [ ] `node tools/parity/<name>-poc.mjs` runs, remaining drifts all listed in the spec's divergences
- [ ] Spec doc has all five sections filled out
- [ ] NEWS bullet mentions the component
- [ ] One commit, not several

If any box is unchecked, the gate isn't met.

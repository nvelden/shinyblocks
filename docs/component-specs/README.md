# Component specs

One file per exported `block_*()`. Each spec captures the shadcn
reference, the visual states the component must render, the token
contract, and any deliberate divergences. See
[ADR 0015](../decisions/0015-component-specs.md) for the design
rationale.

## Adding a spec

1. Copy [`_template.md`](_template.md) to `<name>.md`, where `<name>`
   is the `block_*()` function name minus the `block_` prefix
   (e.g. `block_card_header` → `card-header.md`).
2. Fill in each section. Keep it tight — five sections, ~30 lines.
   Prose is signal lost; bullet points and the token-mapping table
   are the artifact.
3. Capture the canonical shadcn screenshot and commit it under
   `_screenshots/<slug>.png`. Note the capture date in the spec.
4. Run [`tools/spec-screenshots.R`](../../tools/spec-screenshots.R)
   (or `make spec-screenshots`) to keep the screenshot inventory honest.
5. Regenerate [`SCREENSHOT-QUEUE.md`](SCREENSHOT-QUEUE.md) with
   `make spec-screenshots-md` when the capture queue changes.
6. Run `make spec-screenshots-check` before a handoff or commit if the
   queue file should already be up to date.

The generated queue is priority-sorted:
- `seed` — anchor captures for the parity pass (`button`, `card`,
  `select`, `tabs`)
- `high-risk` — interaction-heavy components most likely to force CSS
  follow-up
- `remaining` — everything else

Status values in the generated queue:
- `missing` — no committed screenshot file yet
- `captured-undated` — screenshot file exists but the spec still needs a
  real capture-date note
- `captured-dated` — screenshot file exists and the spec records a
  capture date

On macOS, Safari capture helpers exist for the seed, high-risk, and
full queue passes:
- `make spec-screenshots-seed`
- `make spec-screenshots-high-risk`
- `make spec-screenshots-all`
- `make showcase-capture SECTION=field OUT=/tmp/field-dark.png THEME=dark`
  for local showcase parity review

For theme-forced local captures, Safari must have
`Allow JavaScript from Apple Events` enabled under Developer settings.

Treat the output as maintainer assistance. The committed screenshots are
first-pass review artifacts; tighten the crop if a spec needs a more
focused reference image.

The `test-doc-coverage.R` suite now enforces that every exported
`block_*()` has a written spec doc. The screenshot queue is therefore
the parity-review worklist, not a backlog of undocumented components.

## Screenshot capture

Until shadcn exposes stable static-asset URLs, the canonical
screenshot is captured by hand:

1. Open the matching shadcn docs page in a clean browser window
   (default light theme, default zoom).
2. Render the canonical example shadcn shows above the fold —
   typically the default state, sometimes a small variant grid.
3. Crop tight to the component, no surrounding chrome.
4. Save as `_screenshots/<slug>.png`.

When shadcn updates upstream, refresh the screenshot and bump the
date in the spec. The diff is the audit trail.

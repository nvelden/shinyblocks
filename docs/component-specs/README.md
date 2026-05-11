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

The `test-doc-coverage.R` suite enforces that every exported
`block_*()` has a written spec doc.

For components already migrated into the Playwright parity harness,
the committed computed-style baselines live separately under
[`_parity/`](_parity/). Those JSON snapshots complement the written
specs; they do not replace them.

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

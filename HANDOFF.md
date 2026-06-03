# Handoff: Issue #41 - Refactor runtime, CSS, R helpers, and tests

## Status (2026-06-03)

Issue: https://github.com/nvelden/shinyblocks/issues/41

Issue #41 decomposition work is handled locally:

- Runtime component bodies were extracted from `frontend/src/index.jsx` into
  focused files under `frontend/src/components/`.
- `R/components.R` was split into focused R files (`card.R`, `button.R`,
  `badge.R`, `code.R`, `alert.R`, `overlays.R`, `indicators.R`) and the
  `DESCRIPTION` `Collate` list was updated.
- The oversized shell and utility test files were split by concern, with
  snapshots moved to matching split test names.
- Popover/tooltip now share overlay positioning helpers in
  `frontend/src/runtime/overlays.js`.

Current local changes:

```text
 M HANDOFF.md
 M DESCRIPTION
 M R/components.R
 A R/alert.R
 A R/badge.R
 A R/button.R
 A R/card.R
 A R/code.R
 A R/indicators.R
 A R/overlays.R
 D tests/testthat/_snaps/utils.md
 A tests/testthat/_snaps/utils-controls.md
 A tests/testthat/_snaps/utils-core.md
 A tests/testthat/_snaps/utils-theme.md
 M tests/testthat/test-shell.R
 A tests/testthat/test-shell-content.R
 A tests/testthat/test-shell-forms.R
 A tests/testthat/test-shell-layout.R
 M tests/testthat/test-utils.R
 A tests/testthat/test-utils-controls.R
 A tests/testthat/test-utils-core.R
 A tests/testthat/test-utils-overlays.R
 A tests/testthat/test-utils-runtime-updates.R
 A tests/testthat/test-utils-theme.R
 M tools/check-legacy-audit.R
 A frontend/src/runtime/overlays.js
 M frontend/src/components/popover.jsx
 M frontend/src/components/tooltip.jsx
 M inst/www/shinyblocks-runtime.js
 D tests/testthat/_snaps/utils-controls.md
 D tests/testthat/_snaps/utils-theme.md
 M tests/testthat/test-utils-controls.R
 M tests/testthat/test-utils-theme.R
 ?? .vscode/
```

Do not include `.vscode/` unless explicitly requested.

Last verification:

```bash
npm run build:runtime
npm run test:runtime
make check-fast
make check-slice
make showcase-health
```

`make check-slice` passed with the existing `_pkgdown.yml` skip. Showcase was
restarted after the runtime batch and `make showcase-health` returned
`HTTP/1.1 200 OK`.

## Next Slice

No required follow-up for Issue #41 is known after this local batch. Before
closing the issue or opening a PR, review the diff, then run the preferred
pre-PR gate (`make gate`) if time permits.

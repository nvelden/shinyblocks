# Handoff: Issue #41 — Refactor runtime, CSS, R helpers, and tests

## Status (2026-06-03) — THIRD SLICE COMPLETE

Created tracked issue:

```text
https://github.com/nvelden/shinyblocks/issues/41
```

Goal: make the package layers smaller and easier to change without changing the
public API. The review found no emergency defects, but the codebase has several
large mixed-responsibility files and verbose tests that now slow refactors.

Primary targets:

1. `frontend/src/index.jsx` (~3,000 lines): split into component modules,
   runtime hooks, syntax highlighting, and a small registry/mounter entry file.
2. `frontend/src/styles/runtime.css` (~2,000 lines): split source CSS by
   responsibility and consolidate repeated focus/invalid/disabled/profile rules.
3. `R/components.R` (~1,000 lines): split by component family while preserving
   exported function names.
4. R updater/form helper duplication: add small internal helpers for payload
   setters, clearable fields, width styles, and hidden native inputs.
5. `tests/testthat/test-shell.R` and `tests/testthat/test-utils.R`: consolidate
   fake Shiny session setup and replace brittle raw-string assertions with
   payload/custom expectations where possible.

Suggested first slice:

1. Add test helpers for captured Shiny input/custom messages. **Done:**
   `tests/testthat/setup.R` now provides `local_input_message_session()` and
   `local_custom_message_session()`, and the updater coverage in
   `tests/testthat/test-utils.R` uses those helpers instead of per-test fake
   session capture blocks.
2. Use them to slim `test-utils.R` updater tests. **Done.**
3. Then extract small R updater helpers and verify behavior remains unchanged.
   **Done:** `R/runtime-input-update.R` now owns shared helpers for payload
   setters, clearable payload fields, normalized style payloads, width style
   strings, and hidden native input/textarea construction. The helpers are used
   across form controls, select, radio group, and button/dialog/popover updater
   paths.

Verification so far:

```bash
Rscript -e "devtools::load_all('.'); testthat::test_file('tests/testthat/test-utils.R')"
# 0 failures, 0 warnings, 16 CRAN skips
Rscript -e "devtools::load_all('.'); testthat::test_file('tests/testthat/test-shell.R')"
# 0 failures, 0 warnings
Rscript -e "devtools::load_all('.'); testthat::test_file('tests/testthat/test-runtime-payload.R')"
# 0 failures, 0 warnings, 1 CRAN skip
make showcase-health
# HTTP/1.1 200 OK
make check-fast
# 0 failures, 0 warnings; theme static/drift/leanness and diff check passed
npm run build:runtime
# built runtime JS/CSS successfully
npm run test:runtime
# Runtime smoke test passed; Select overflow smoke test passed
make showcase-health
# HTTP/1.1 200 OK after escalated showcase restart on :4321
make check-slice
# 0 failures, 0 warnings, 1 skip; doc links, legacy audit, theme/static drift,
# style leanness, and diff check passed
```

Suggested second slice:

1. Split `frontend/src/index.jsx` around low-risk modules first:
   `highlighting/*`, `components/basic/*`, then overlay/input hooks.
   **Partly done:** syntax highlighting now lives in
   `frontend/src/highlighting/code.jsx`; shared JSX helpers live in
   `frontend/src/components/shared.jsx`; stateless/basic runtime components
   (`badge`, `separator`, `spinner`, `skeleton`, `empty`, `value-box`, `alert`)
   live in `frontend/src/components/basic.jsx`. `frontend/src/index.jsx`
   dropped from ~3,000 lines to ~2,500 lines. Stateful controls, overlays,
   `button`, `code`, and the mounter remain in `index.jsx`.
2. Run runtime/build checks after each extraction. **Done for this slice.**

Suggested third slice:

1. Split `frontend/src/styles/runtime.css` into source partials.
   **Done:** `frontend/src/styles/runtime.css` is now an import entry and the
   runtime rules live in focused partials under `frontend/src/styles/runtime/`
   (`00-tokens.css` through `08-style-profiles.css`).
2. Consolidate shared profile rules for `luma` and `rhea`.
   **Deferred:** the split preserved behavior and kept profile selectors in
   one partial; consolidation is the next low-risk CSS follow-up.
3. Rebuild generated runtime assets; do not hand-edit `inst/www` outputs.
   **Done:** `npm run build:runtime` and `make check-slice` rebuilt runtime
   assets. Generated CSS content stayed behaviorally unchanged.

Build/theme tooling update:

- Added `tools/css-source.mjs` to inline local CSS `@import` partials.
- `tools/build-runtime.mjs` now minifies the inlined runtime CSS source before
  writing `inst/www/shinyblocks-runtime.css`.
- Theme token, default-token drift, and style leanness gates now scan the
  inlined runtime source instead of only the import entry.

Verification targets:

```bash
make check-fast
make check-slice
```

Verification for third slice:

```bash
npm run build:runtime
# built runtime JS/CSS successfully
npm run test:themes-static
# passed
npm run test:themes-drift
# passed
npm run test:style-leanness
# passed
npm run test:runtime
# Runtime smoke test passed; Select overflow smoke test passed
make check-fast
# 0 failures, 0 warnings; theme static/drift/leanness and diff check passed
make check-slice
# 0 failures, 0 warnings, 1 skip; doc links, legacy audit, theme/static drift,
# style leanness, and diff check passed
make showcase-health
# HTTP/1.1 200 OK after escalated showcase restart on :4321
```

If runtime JS/CSS, showcase wiring, or update handlers change, restart the
showcase per `AGENTS.md`, then run the showcase health check.

Current commit candidate:

```text
 M AGENTS.md
 M HANDOFF.md
 M NEWS.md
 M R/components.R
 M R/form-controls.R
 M R/radio-group.R
 M R/runtime-input-update.R
 M R/select.R
 M R/style-profiles.R
 M frontend/src/index.jsx
 M inst/www/shinyblocks-runtime.js
 M tests/testthat/setup.R
 M tests/testthat/test-utils.R
 A frontend/src/components/basic.jsx
 A frontend/src/components/shared.jsx
 A frontend/src/highlighting/code.jsx
```

`.vscode/` remains untracked and should not be included in the issue #41
commit unless explicitly requested.

---

# Previous Handoff: Issue #40 — CSS isolation audit

## Status (2026-06-03) — RESOLVED

Implemented the **composable** option (a). All three actionable findings fixed,
documented in [ADR 0022](docs/decisions/0022-css-isolation.md) and `NEWS.md`:

1. Preflight reset scoped under `.sb-app` via granular Tailwind imports +
   generated `inst/www/src/preflight.scoped.css` (`tools/build-preflight.mjs`,
   chained into `make build-css`). `block_page()` emits a page-owner
   `body{margin:0;padding:0}` reset (`sb-page-chrome`).
2. Shell tokens moved from `:root` → `.sb-app` (and `[data-theme="dark"]` →
   `[data-theme="dark"] .sb-app`) in `inst/www/src/tokens.css`.
3. Bare `localStorage["theme"]` read removed (`inst/www/shinyblocks.js`, reads
   only `sb-theme`).

Finding 4 (global `@property --tw-*` defaults) left as a documented note (inert).
`make check-slice` green; showcase restarted on :4321 and visually verified
(light + dark). The historical audit detail below is retained for reference.

---

Tracked issue:

```text
https://github.com/nvelden/shinyblocks/issues/40
```

## Decision Needed First

shinyblocks currently assumes it **owns the whole page**. Before fixing, decide:

- **(a) Make it composable** — scope the Preflight reset + design tokens under
  `.sb-app` / `.sb-page` so shinyblocks can be embedded in an existing
  Shiny/bslib app; or
- **(b) Page-owning only** — keep current behavior and document the constraint
  (ADR 0006 / 0009 area).

Findings 1 and 2 below only need fixing under option (a). Finding 3 is worth
fixing either way.

## Findings (full detail in issue #40)

1. **Tailwind Preflight reset ships globally unscoped** (`inst/www/shinyblocks.css`,
   `@layer base`). Resets `*`, `ol,ul,menu`, `h1..h6`, `img/svg/video`,
   `[hidden]` document-wide. Partly cushioned by `@layer` (unlayered author CSS
   wins) but still clobbers UA defaults. Fix: scope under `.sb-app`/`.sb-page`
   in `inst/www/src/shinyblocks.css`, then `make build-css`.
2. **Unprefixed `:root` tokens** (`inst/www/src/tokens.css`): `--background`,
   `--foreground`, `--primary`, `--border`, `--input`, `--ring`, `--radius`, …
   collide with any other shadcn-token lib on the page. Token *names* are a
   public theming contract (renaming = major release), so scope rather than
   rename.
3. **Bare `localStorage["theme"]` read** (`inst/www/shinyblocks.js:9`) — writes
   prefixed `sb-theme` but reads generic `"theme"` first. Drop/gate the bare
   read. Fix regardless of option a/b.
4. Global `@property --tw-*` defaults — note only, no action.

## Confirmed Clean (no action)

- `htmlDependency` name `"shinyblocks"` (`R/deps.R:4`)
- `addResourcePath` prefix `"shinyblocks"` (`R/zzz.R:3`)
- Message handler `"sb:theme"` guarded (`inst/www/shinyblocks.js:344`)
- Input handler `"shinyblocks.button"` (`R/zzz.R:7`)
- No vendored jQuery/Bootstrap; React runtime is a self-contained IIFE
- `setInputValue` uses `{priority:"event"}` (`inst/www/shinyblocks.js:119`)
- Idempotent wiring guards + MutationObserver + `shiny:connected` resync

## Suggested Fix Steps (next chat, if option a)

1. Scope Preflight + tokens under `.sb-app`/`.sb-page` in `inst/www/src/`.
2. `make build-css` to regenerate the committed `inst/www/shinyblocks.css`.
3. Remove the bare `localStorage["theme"]` read.
4. Re-run parity harness (`tools/parity/`) + `make check-slice`; restart
   showcase on 4321 per `AGENTS.md`.
5. Add/extend ADR documenting the isolation contract; update NEWS.

## Runtime State

Local servers may be running (see `AGENTS.md` before restarting):

```bash
lsof -nP -iTCP:4321 -sTCP:LISTEN   # showcase
lsof -nP -iTCP:5173 -sTCP:LISTEN   # parity reference app
```

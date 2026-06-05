# Handoff: Reactive block_table() + unified formatting (Issue #51)

## Current work (2026-06-05)

Issue: https://github.com/nvelden/shinyblocks/issues/51
Plan: `docs/agent-plans/2026-06-05-table-reactive-formatting.md`
Branch: `table-reactive-formatting`

Follow-up to the static `block_table()` v1 (#49/#50). Goal: close the gap to
Shiny `tableOutput()`/`renderTable()` — make the table reactive and route data
loading, column formatting, and row formatting through one R-side serializer
used by both the UI render and server-side updates.

Decisions (locked 2026-06-05): (1) reactive surface = `update_block_table()`
reusing `runtime_input_update`; (2) row formatting = `row_format(row, i)`
returning `{class, style}`; (3) NA default stays `""` (opt in via `na=`).

**Slice 1 — DONE.** R formatting pipeline + update helper, R-only (no
runtime/CSS yet, so no showcase restart needed):

- `R/table.R`: extracted `table_build_payload()` as the single payload source
  for both `block_table()` and `update_block_table()`. Added `update_block_table()`.
  `block_table()` gained `na`, `digits`, `rownames`, `row_format`, `striped`,
  `hover`, `bordered`, `id` (all defaulted, back-compatible). `table_column()`
  gained per-column `digits`/`na`. `row_format` -> per-row `rowMeta {class,style}`.
- `tests/testthat/test-table.R`: na/digits/rownames, row_format->rowMeta,
  pipeline-identity guarantee, update message target/payload, loading-only,
  new validation. 43 pass.
- `devtools::document()` regenerated `man/update_block_table.Rd` + content-family
  `@family` cross-refs + NAMESPACE.
- Verification: `Rscript -e "devtools::load_all(); testthat::test_file('tests/testthat/test-table.R')"`
  — 43 passed. `make check-fast` — passed.

**Slice 2 — NEXT (runtime delivery binding).** Shiny routes input messages by
the mount DOM id and only to an element a registered InputBinding owns; the
table has none, so `update_block_table()` builds/sends correctly but won't reach
the DOM yet. Add a receive-only runtime binding for `table` in
`frontend/src/runtime/bindings.js` (`find` matches the mount, `getValue` -> null,
`subscribe`/`unsubscribe` no-op, `receiveMessage` -> `el.__sbTableReceive`),
register it in `BINDING_NAMES`/`BINDING_CONFIGS`, add `"table"` to
`RUNTIME_INPUT_COMPONENTS`. Open question: whether the null `input$<id>` value is
acceptable or should be suppressed. Then slice 3 reads `rowMeta`/`loading`/
`striped`/`bordered` in `table.jsx` + CSS (first slice that needs a showcase
restart). See the plan for slices 4-7.

---

# Handoff: Issue #49 - Add block_table() (shadcn table port)

## Status (2026-06-05)

Issue: https://github.com/nvelden/shinyblocks/issues/49
Plan: `docs/agent-plans/2026-06-05-table-component.md`
Branch: `issue-49-block-table`

Phase 1 / slices 1-5 are complete: R API + strict payload + tests + roxygen,
runtime render + CSS + theme/style registry coverage, the full showcase
playground, docs-site playground/spec sync, and the slice gate.

Phase 3 dogfooding is complete for the showcase and docs-site API-reference
tables. Showcase API-reference tables now render through `block_table()` with
standardized headings, live showcase health/browser smoke passed after restart,
and the docs-site React API table has been restyled with matching shadcn table
slots/token classes.

Implemented:

- `R/table.R`: exported `block_table()` and `table_column()`.
- `R/runtime.R`: added `"table"` to `RUNTIME_COMPONENT_NAMES`.
- `tests/testthat/test-table.R`: validation, column overrides, formatting,
  missing values, truncation, zero-row tables, payload shape.
- `NAMESPACE`, `man/block_table.Rd`, `man/table_column.Rd`, and content-family
  Rd links regenerated with `devtools::document()`.
- `DESCRIPTION`: added `R/table.R` to explicit `Collate:`.
- `frontend/src/components/table.jsx`: runtime table renderer.
- `frontend/src/index.jsx`: registered `table` in the COMPONENTS map.
- `frontend/src/styles/runtime/09-table.css`: shadcn-style table slot CSS,
  semantic theme tokens, and profile-sensitive spacing via shared control
  tokens.
- `tools/theme/theme-registry.mjs`: table theme response bindings.
- `tools/theme/style-registry.mjs`: table style-profile parity binding.
- `inst/showcase/R/examples/table.R`: full table playground and stable
  `.sb-parity-table` fixture.
- `inst/showcase/R/server_table.R`: table preview, generated code, and API
  reference wiring.
- `inst/showcase/app.R`: registered the Table showcase page.
- `inst/showcase/R/examples/code.R`: removed the temporary table parity fixture.
- `inst/showcase/www/showcase.css`: table custom-class showcase hook.
- `docs-site/content/previews/table.R`: docs preview snippet.
- `docs-site/playgrounds/table/app.R`: interactive Shinylive Table playground.
- `docs-site/lib/preview-manifest.json`: registered the Table component preview
  and playground metadata.
- `docs-site/lib/api-reference.ts`: Table API metadata.
- `docs-site/public/playgrounds/table/`: generated Shinylive playground export.
- `docs-site/app/components/[slug]/page.tsx`: docs-site API-reference table
  restyled with matching shadcn `data-slot` attributes and semantic token
  classes.
- `docs-site/public/shinyblocks-runtime-override.css`: regenerated runtime
  override bundle with table CSS + showcase custom hook.
- `docs/component-specs/table.md`: component spec documenting the static v1
  contract, NA handling, payload shape, shadcn slot map, and divergences.
- `docs/component-specs/SCREENSHOT-QUEUE.md`: queued the table reference
  screenshot.
- `NEWS.md`: user-facing table entry.

Verification:

- `Rscript -e "devtools::test(filter = 'table')"` — 23 passed.
- `make check-fast` — passed.
- `make build-css build-runtime` — passed.
- Showcase restarted on port 4321; `make showcase-health` returned HTTP 200.
- `npm run test:runtime` — passed.
- `Rscript -e "devtools::test(filter = 'table|runtime-css|runtime-js')"` —
  100 passed.
- `npm run test:themes` — passed outside the sandbox.
- `Rscript -e "devtools::test(filter = 'showcase|table')"` — 227 passed.
- `make build-css build-runtime` — passed.
- Showcase restarted on port 4321; `make showcase-health` returned HTTP 200.
- `make check-fast` — passed.
- `npm run test:themes` — passed outside the sandbox after moving the table
  parity fixture.
- `Rscript scripts/generate-previews.R` in `docs-site/` — passed.
- `Rscript scripts/generate-playgrounds.R` in `docs-site/` — passed; warnings
  were from missing local `playgrounds/_wasm` staging assets in this checkout.
- `Rscript -e "devtools::test(filter = 'doc-coverage|table')"` — 25 passed,
  1 skip for repo-root `_pkgdown.yml` path under the test harness.
- `npm exec tsc -- --noEmit` in `docs-site/` — passed.
- `Rscript -e 'devtools::load_all(\".\"); app <- source(\"docs-site/playgrounds/table/app.R\")$value; stopifnot(inherits(app, \"shiny.appobj\"))'`
  — passed.
- `make build-css build-runtime` — passed.
- `make check-fast` — passed.
- Showcase restarted on port 4321; `make showcase-health` returned HTTP 200.
- `make check-slice` — passed; 1110 R test expectations passed, 1 known
  doc-coverage skip for repo-root `_pkgdown.yml` under the test harness.
- Showcase restarted on port 4321 after the slice gate; `make showcase-health`
  returned HTTP 200.
- `npm run test:themes-browser` — passed outside the sandbox; table token
  response was verified in light and dark mode, and table style-profile parity
  passed across all style profiles.
- Phase 3 showcase API-table dogfooding local checks:
  `Rscript -e "devtools::test(filter = 'showcase|table')"` — 227 passed;
  `npm run test:themes-static` — passed; `npm run test:style-leanness` —
  passed; `git diff --check` — passed; `make build-css build-runtime` —
  passed. No `shiny::tableOutput()` / `shiny::renderTable()` API-reference
  calls remain under `inst/showcase/R/examples` or
  `inst/showcase/R/server_*.R`.
- `make showcase-health` against the restarted live showcase on
  `http://127.0.0.1:4321/` — passed with HTTP 200.
- `npm run test:showcase` — passed outside the sandbox.
- Targeted Playwright smoke against the live showcase API-reference tables —
  passed for all 29 sections; each `showcase_*_api_table` output rendered
  runtime table slots (`data-slot="table"`, `table-head`, `table-cell`) and the
  standardized `Argument` heading.
- `npm exec tsc -- --noEmit` in `docs-site/` — passed after the docs-site API
  table restyle.
- `./node_modules/.bin/next build` in `docs-site/` — passed outside the
  sandbox. A sandboxed first attempt failed with Turbopack's process/port
  permission error before rerun.

## Decisions (locked 2026-06-05)

- **Data API:** data.frame-driven. `block_table(data, columns, caption,
  max_rows, class, style)` + `table_column(label, align, format, width)`. R
  formats every cell to a string and serializes a strict
  `{columns, rows, caption, truncated, totalRows}` payload.
- **v1 scope:** static / presentational only. No `input$` binding, no
  `update_block_table()`.
- **Ownership:** runtime React component (`frontend/src/components/table.jsx`),
  not R-side htmltools — phase-2 interactivity reuses the same mount path
  (ADR 0017).
- **Faithful shadcn port:** mirror `table.tsx` 1:1 (`data-slot` set + token
  classes). No invented variants (no striped/bordered/dense). `max_rows` is the
  only shinyblocks-only affordance; it renders in `tfoot`.
- **Selection styling hook in v1:** `TableRow` emits `hover:bg-muted/50` +
  `data-[state=selected]:bg-muted` now (nothing sets selected yet) so phase-2
  selection only toggles the attribute.
- **No DT / host widget.**

## Phase 1 — static component + both playgrounds (do this first)

Slice order (each slice ends with rebuild + showcase restart + manual confirm):

1. **R API + payload** — `R/table.R` (`block_table()` + `table_column()`),
   validation, R-side formatting, strict payload. Add `"table"` to
   `RUNTIME_COMPONENT_NAMES` in `R/runtime.R`. Tests in
   `tests/testthat/test-table.R`. `make check-fast`. **Done 2026-06-05.**
2. **Runtime render + CSS** — `frontend/src/components/table.jsx`, register in
   `frontend/src/index.jsx` COMPONENTS, `frontend/src/styles/runtime/09-table.css`
   (semantic tokens, mirror shadcn class strings), theme-registry entry in
   `tools/theme/theme-registry.mjs` + `.sb-parity-table` fixture.
   `npm run build:runtime`, `npm run test:themes`. **Done 2026-06-05.**
3. **Showcase playground** — `inst/showcase/R/examples/table.R` +
   `server_table.R`, register in `inst/showcase/app.R`. **Done 2026-06-05.**
4. **Docs playground + spec** — `docs-site/playgrounds/table/app.R`, manifest /
   metadata / `lib/api-reference.ts`, `generate-playgrounds.R` webR assets,
   `docs/component-specs/table.md`, `devtools::document()`, NEWS.
   **Done 2026-06-05.** No R docs changed in this slice, so
   `devtools::document()` was not rerun.
5. **Slice gate** — `make check-slice`, browser/parity light+dark.
   **Done 2026-06-05.** The table slice uses the theme/style browser harness
   for light/dark parity coverage; `tools/parity/registry.mjs` does not define
   a standalone shadcn table visual-diff entry.

## Phase 2 — actions (later, separate ADR)

Reference is the shadcn TanStack `data-table` example (not the `table`
component). Lightweight runtime reimplementation, no TanStack dep. Order:
row selection (binding `shinyblocks.table` + `update_block_table()`), then
sorting, pagination, row action buttons. See plan "Phase 2" section.

## Phase 3 — migrate existing tables (dogfooding)

- **Showcase: 28 API-reference tables** — `shiny::renderTable()` +
  `shiny::tableOutput()` in `inst/showcase/R/server_<name>.R` /
  `examples/<name>.R` (output ids `showcase_<name>_api_table`). Add a shared
  `showcase_api_table()` helper wrapping `block_table()`, migrate in batches of
  ~5-6 per slice. Retire the old renderTable CSS in
  `inst/showcase/www/showcase.css`.
  - **Done:** added `showcase_api_table()`, migrated all
    showcase API-reference tables to `block_table()`, standardized headings to
    `Argument`, `Type`, `Default`, and `Description`, and retired the old
    native Shiny table CSS. Live showcase health and browser smoke passed after
    restart.
- **Docs-site: 1 React `<table>`** at
  `docs-site/app/components/[slug]/page.tsx:136`. Docs-site is a separate
  Next.js app and can't call R `block_table()`. Shinylive playgrounds already
  dogfood the real component.
  - **Done:** used option 1 and restyled the docs-site API table in place with
    matching `data-slot` attributes and semantic token classes.

## Working rules (do not skip)

- After **every** slice: `make build-css build-runtime`, restart showcase on
  port 4321, `make showcase-health`, then point the user at
  `http://127.0.0.1:4321/#table` for manual confirmation before the next slice.
  Run the restart/health outside the command sandbox.
- Verification gates: `make check-fast` during edits, `make check-slice` per
  slice, `make gate` before PR.
- Do not include `.vscode/` unless explicitly requested.
- Never hand-edit generated `inst/www/*.js|*.css` or `man/` — rebuild.

## Open questions to resolve

- None for Phase 3 dogfooding.

## Resolved during slice 1

- **NA cell rendering:** render missing values as empty strings in the payload.
  Document this in `docs/component-specs/table.md` when the spec slice lands.

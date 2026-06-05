# Handoff: Issue #49 - Add block_table() (shadcn table port)

## Status (2026-06-05)

Issue: https://github.com/nvelden/shinyblocks/issues/49
Plan: `docs/agent-plans/2026-06-05-table-component.md`
Branch: `issue-49-block-table`

Slices 1-2 are complete: R API + strict payload + tests + roxygen, then runtime
render + CSS + theme/style registry coverage. Next slice is the full showcase
playground.

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
- `inst/showcase/R/examples/code.R`: temporary `.sb-parity-table` fixture until
  the dedicated table showcase page lands.

Verification:

- `Rscript -e "devtools::test(filter = 'table')"` — 23 passed.
- `make check-fast` — passed.
- `make build-css build-runtime` — passed.
- Showcase restarted on port 4321; `make showcase-health` returned HTTP 200.
- `npm run test:runtime` — passed.
- `Rscript -e "devtools::test(filter = 'table|runtime-css|runtime-js')"` —
  100 passed.
- `npm run test:themes` — passed outside the sandbox.

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
   `server_table.R`, register in `inst/showcase/app.R`.
4. **Docs playground + spec** — `docs-site/playgrounds/table/app.R`, manifest /
   metadata / `lib/api-reference.ts`, `generate-playgrounds.R` webR assets,
   `docs/component-specs/table.md`, `devtools::document()`, NEWS.
5. **Slice gate** — `make check-slice`, browser/parity light+dark.

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
- **Docs-site: 1 React `<table>`** at
  `docs-site/app/components/[slug]/page.tsx:136`. Docs-site is a separate
  Next.js app and can't call R `block_table()`. **Open decision:** restyle the
  `<table>` with matching `data-slot`/token classes (option 1, recommended) or
  extract a parallel React `<Table>` (option 2). Confirm with maintainer before
  implementing. Shinylive playgrounds already dogfood the real component.

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

- Docs-site migration approach (option 1 vs 2 above).

## Resolved during slice 1

- **NA cell rendering:** render missing values as empty strings in the payload.
  Document this in `docs/component-specs/table.md` when the spec slice lands.

# Handoff: Add `block_file_input()` (Shiny upload, shadcn-styled)

## Status (2026-06-08) — PLAN READY, NOT STARTED

Plan: `docs/agent-plans/2026-06-08-file-input-component.md` (Status: **READY**)
Branch: still on `main` — create `file-input` before committing.
Issue: https://github.com/nvelden/shinyblocks/issues/54

## Goal

`block_file_input()`: a shadcn-styled file picker (button + filename text) whose
uploads flow through Shiny's existing file-upload machinery, so `input$<id>` is
the standard data.frame (`name`, `size`, `type`, `datapath`) — identical
semantics to `shiny::fileInput()`. Single slice: button picker + both
playgrounds (showcase + docs site), ending with rebuild + showcase restart.

## Decisions (locked 2026-06-08)

- **D1 — Upload transport: reuse Shiny's native `FileUploadBinding`** (approved
  wrapper exception). R emits the real `<input type="file" class="shiny-input-file">`
  + progress markup into `[data-shinyblocks-children]`; React renders only the
  styled UI into `[data-shinyblocks-react]` and finds the native input via
  `root.querySelector("input.shiny-input-file")`. No custom binding registered.
- **D2 — v1 scope: button picker only.** Drag-and-drop dropzone deferred.
- **D3 — No `update_block_file_input()` in v1** (Shiny has no `updateFileInput()`).
- **D4 — Faithful, minimal API.** Mirror `shiny::fileInput()` knobs
  (`multiple`, `accept`) + shadcn styling hooks. No `label` arg (compose with
  `block_field_label()`, matching `block_input`/`block_textarea`).

## Implementation notes (read before coding)

- **Do not reuse `hidden_native_input()` as-is** — it hardcodes
  `data-shiny-no-bind-input` (`R/runtime-input-update.R:76`), which blocks Shiny
  from binding the file input. Add `native_file_input()` (or extend with
  `shiny_no_bind = FALSE`). Native input must be bindable and visible-but-styled-away
  (not `display:none`) so the file dialog works.
- **Mirror Shiny's fileInput markup exactly:** native `<input>` with the progress
  wrapper `id = paste0(input_id, "_progress")`, classes
  `progress active shiny-file-input-progress`, and a nested `.progress-bar`.
- **Children are R-emitted, not React-rendered** (`R/runtime.R:84` vs `:83`).
- **Shiny id lives on the native input** (binding uses `el.id`), so pass
  `input_id = NULL` to `runtime_component()` (no `data-sb-input-id`). Register
  **no** `BINDING_CONFIGS` / `RUNTIME_INPUT_COMPONENTS` entry; verify `Shiny.bindAll`
  runs over the mount so the native binding attaches.

## Files (per plan)

- R: `R/form-controls.R` (`block_file_input()` + `native_file_input()` helper);
  add `"file-input"` to `RUNTIME_COMPONENT_NAMES` in `R/runtime.R`.
- Runtime: `frontend/src/index.jsx` (+ `FileInput.jsx`). Do **not** touch
  `bindings.js`.
- CSS: `frontend/src/styles/runtime/06-inputs.css` (input-like tokens; reuse/add
  `--sb-input-*` style-profile vars).
- Showcase: `inst/showcase/R/examples/file_input.R`, `server_file_input.R`,
  register in `app.R`, `.sb-parity-file-input` fixture, API-table CSS in
  `inst/showcase/www/showcase.css`.
- Theme: `tools/theme/theme-registry.mjs` (runtime) **and**
  `tools/theme/style-registry.mjs` (style-profile coverage).
- Docs: `docs/component-specs/file-input.md`, docs-site metadata + Shinylive
  playground (`docs-site/playgrounds/file-input/`), `NEWS.md`, `devtools::document()`.
- Tests: `tests/testthat/` (R payload/validation), `tools/runtime-shiny-smoke.mjs`
  (real upload → `input$<id>` data.frame, disabled, module namespacing).

## Working rules

- **Every slice ships the showcase `file_input` playground and restarts the app.**
  The showcase app must always carry the new `block_file_input()` playground
  (full Content/State/Styling/Actions + `input$` display + API table). After each
  slice: `make build-css build-runtime`, restart showcase on port 4321 (outside
  the sandbox), `make showcase-health`, then point the user at
  `http://127.0.0.1:4321/#file_input` for manual confirmation before continuing.
- Gates: `make check-fast` during edits · `make check-slice` per slice · `make
  gate` before PR.
- Never hand-edit generated `inst/www/*.js|*.css` or `man/` — rebuild.

## Open questions

None — D1/D2/D3 locked.

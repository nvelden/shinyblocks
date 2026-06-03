# Handoff: Issue #41 - Refactor runtime, CSS, R helpers, and tests

## Status (2026-06-03)

Issue: https://github.com/nvelden/shinyblocks/issues/41

The latest local slice extracted `Popover` from `frontend/src/index.jsx` into
`frontend/src/components/popover.jsx`, rebuilt the runtime bundle, and restarted
the showcase. The issue remains open because `frontend/src/index.jsx`,
`R/components.R`, and the large test files still have decomposition work left.

Current local changes:

```text
 M HANDOFF.md
 A frontend/src/components/popover.jsx
 M frontend/src/index.jsx
 M inst/www/shinyblocks-runtime.js
 ?? .vscode/
```

Do not include `.vscode/` unless explicitly requested.

Last verification:

```bash
npm run build:runtime
npm run test:runtime
make check-fast
make check-slice
```

`make check-slice` passed with the existing `_pkgdown.yml` skip. Showcase was
restarted and printed `Listening on http://127.0.0.1:4321`, but the required
escalated `make showcase-health` call was rejected by the approval layer because
the session hit the usage limit. Run `make showcase-health` before treating the
slice as fully verified.

## Next Slice

Extract `Tooltip` from `frontend/src/index.jsx` into
`frontend/src/components/tooltip.jsx`.

Suggested implementation:

1. Move the existing `Tooltip` component without behavior changes.
2. Import it into `frontend/src/index.jsx` and keep the existing `COMPONENTS`
   registry entry.
3. Rebuild generated runtime assets with `npm run build:runtime`.
4. Run `npm run test:runtime`, `make check-fast`, and `make check-slice`.
5. Because runtime JS changes, restart showcase per `AGENTS.md` and require
   `make showcase-health` success.

Keep this as a move-only slice. Save shared overlay hook extraction for a
later pass after `Tooltip` has been separated.

# Handoff: Issue #41 - Refactor runtime, CSS, R helpers, and tests

## Status (2026-06-03)

Issue: https://github.com/nvelden/shinyblocks/issues/41

The latest local slice extracted `Code` from `frontend/src/index.jsx` into
`frontend/src/components/code.jsx`, rebuilt the runtime bundle, and restarted
the showcase. The issue remains open because `frontend/src/index.jsx`,
`R/components.R`, and the large test files still have decomposition work left.

Current local changes:

```text
 M HANDOFF.md
 A frontend/src/components/code.jsx
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
make showcase-health
```

`make check-slice` passed with the existing `_pkgdown.yml` skip. Showcase is
running at `http://127.0.0.1:4321/` and `make showcase-health` returned
`HTTP/1.1 200 OK`.

## Next Slice

Extract `Button` from `frontend/src/index.jsx` into
`frontend/src/components/button.jsx`.

Suggested implementation:

1. Move the existing `Button` component without behavior changes.
2. Import it into `frontend/src/index.jsx` and keep the existing `COMPONENTS`
   registry entry.
3. Rebuild generated runtime assets with `npm run build:runtime`.
4. Run `npm run test:runtime`, `make check-fast`, and `make check-slice`.
5. Because runtime JS changes, restart showcase per `AGENTS.md` and require
   `make showcase-health` success.

After `Button`, continue with the same pattern for another focused runtime
group before taking on shared overlay/input hooks.

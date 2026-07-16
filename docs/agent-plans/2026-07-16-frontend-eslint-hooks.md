# Frontend ESLint hook cleanup

## Goal

- Resolve all current frontend ESLint findings and make zero warnings the permanent lint contract.
- Preserve runtime input single-writer behavior, receive ordering, notification semantics, overlay focus/portal behavior, and exact cleanup ownership.

## Assumptions

- Public R APIs and payload shapes do not change.
- DOM expandos remain the synchronous source of truth for Shiny bindings.
- Receive handlers must remain installed once per mounted root unless an effect owns a genuinely changing external subscription.
- Generated runtime assets are rebuilt from `frontend/src`; generated files are not edited directly.

## Proposed API

- No public API changes.
- Internal React helpers may use `useCallback`, latest-value refs, or a focused reusable latest-ref hook where that keeps receive handlers stable.
- `npm run lint` will invoke ESLint with `--max-warnings=0`.

## Files to edit

- `package.json`.
- Warning-bearing files under `frontend/src/components/` and `frontend/src/runtime/select-popover.js`.
- Focused runtime/browser test fixtures or smoke assertions under `tools/` where stale closures, duplicate effects, focus return, or cleanup need regression coverage.
- Generated `inst/www/shinyblocks-runtime.js` and `inst/www/shinyblocks-runtime.css` via `npm run build:runtime`.

## Tests and checks

- Baseline and final `npm run lint -- --max-warnings=0`.
- Focused runtime regression checks for receive updates, notifications, overlay focus/cleanup, timers, and controls whose callbacks become stable.
- `npm run build:runtime` and `Rscript -e 'devtools::test()'`.
- Outside sandbox: `npm run test:runtime`, `npm run test:runtime-shiny`, and `npm run test:showcase`.
- `make check-slice`, then `make gate`.
- If runtime lifecycle behavior changes, fully restart the showcase after checking/stopping stale port 4321 listeners and require `make showcase-health` to succeed.

## Open questions

- None. Each warning will be resolved independently according to whether it is mount initialization, a long-lived receive subscription, a reactive overlay effect, or cleanup capture.

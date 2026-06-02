# Handoff: Issue #38 Implemented

## Status (2026-06-02)

Issue #38 is implemented locally and ready to push to `origin/main`.

Tracked issue:

```text
https://github.com/nvelden/shinyblocks/issues/38
```

Plan:

```text
docs/agent-plans/2026-06-02-docs-home-playground-theme-controls.md
```

## Issue #38 Work Landed

- Added session-only docs home gallery controls for:
  - `gallery_style_profile`, populated from `block_style_profiles()`;
  - `gallery_theme_preset`, populated from `block_theme_presets()`.
- Kept the gallery default at `style = "default"` and `preset = "neutral"` so
  the first-load home page remains visually stable.
- Applied theme changes through a dynamic scoped `block_theme(..., scope =
  ".sb-app")` render target.
- Applied style token changes through `block_style(..., scope = ".sb-app")` and
  a Shiny custom message that updates the gallery `.sb-app` `data-sb-style`
  marker so Luma/Rhea shell-profile CSS activates.
- Increased the gallery iframe height from `1240` to `1360` in the playground
  generator and docs-site preview manifest.
- Updated the docs-site gallery e2e test so generated `app.json` must include
  the style/preset controls and the style-profile message handler.

## Files Changed

```text
docs-site/playgrounds/gallery/app.R
docs-site/scripts/generate-playgrounds.R
docs-site/lib/preview-manifest.json
docs-site/tests/e2e/gallery.spec.ts
HANDOFF.md
```

## Verification

Passed locally:

```bash
make check-fast
npm run test:e2e -- --grep "landing page gallery"
git diff --check
```

Notes:

- The first docs e2e attempt failed inside the command sandbox because the
  Playwright web server could not create the `tsx` IPC pipe. The same command
  passed outside the sandbox.
- `air` is not installed in this environment, so `air format .` was not run.
- `Rscript scripts/generate-playgrounds.R` was run from `docs-site/`. The
  generated `docs-site/public/playgrounds/` output is ignored by git; tracked
  broad preview/runtime build churn was restored, keeping only the intended
  gallery manifest height change.

## Current Runtime State

Previous handoff noted local servers may be running:

- showcase: `make showcase` on port `4321`;
- parity reference app:
  `python3 -m http.server 5173 --directory parity/dist`.

Before any new agent-driven showcase restart, follow `AGENTS.md`:

```bash
lsof -nP -iTCP:4321 -sTCP:LISTEN
lsof -nP -iTCP:5173 -sTCP:LISTEN
```

Stop stale listeners first, then restart `make showcase` outside the sandbox and
verify with `make showcase-health` outside the sandbox.

## Next Suggested Action

After pushing this commit, watch CI and close or comment on Issue #38 with the
passing checks.

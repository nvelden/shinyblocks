# Handoff: Issue #48 - Official shadcn style alignment

## Status (2026-06-04)

Issue: https://github.com/nvelden/shinyblocks/issues/48
Plan: `docs/agent-plans/2026-06-04-official-shadcn-styles-themes.md`
Branch: `issue-48-official-shadcn-styles`

Issue #48 supersedes the issue #42 direction that added shinyblocks-owned
profiles. Built-in `block_style()` profiles should now be official shadcn/ui v4
registry styles only, plus the no-op `default`.

## Implemented

- `R/style-profiles.R`: removed shinyblocks-owned `mono`, `soft`, `brutal`, and
  `glass`; kept `luma`/`rhea`; added official `lyra`, `maia`, `mira`, `nova`,
  `sera`, and `vega` as token-data profile ports.
- Internal translucency infrastructure remains available:
  `--sb-surface-backdrop`, `--sb-card-surface`, `--sb-value-box-surface`,
  `--sb-select-content-surface`, `--sb-dialog-surface`, and
  `--sb-popover-surface`.
- Runtime CSS now reads the per-surface translucency hooks with opaque
  fallbacks, preserving default visuals.
- `R/theme-presets.R` documents theme-preset provenance: `neutral`, `stone`, and
  `zinc` are official shadcn/create base-color scales; `mauve`, `olive`,
  `mist`, and `taupe` remain shinyblocks compatibility palettes for now.
- Tests, style-registry parser tests, parity registry, component specs,
  showcase style preview wrapping, and `NEWS.md` are updated for the official
  profile set.
- Source/provenance notes live in
  `docs/research/2026-06-04-style-profile-sources.md`.

## Verified

- Upstream shadcn registry checked on 2026-06-04:
  `apps/v4/registry/styles` contains `style-luma.css`, `style-lyra.css`,
  `style-maia.css`, `style-mira.css`, `style-nova.css`, `style-rhea.css`,
  `style-sera.css`, and `style-vega.css`; no `style-glass.css`.
- `Rscript -e "devtools::test(filter = 'style|theme')"`: 194 pass.
- `npm run test:style-registry`: 7 pass.
- `npm run test:style-leanness`: pass.
- Restarted showcase outside the sandbox and confirmed `make showcase-health`
  returns HTTP 200.
- `npm run test:themes-runtime`: 82 pass, 0 fail.
- `npm run test:style-parity`: 116 pass, 0 fail across `luma`, `lyra`, `maia`,
  `mira`, `nova`, `rhea`, `sera`, and `vega`.
- `make check-slice`: pass, with 1063 R tests passing and one expected
  doc-coverage skip for missing `_pkgdown.yml`.
- `make gate`: pass when rerun outside the command sandbox. The first sandboxed
  attempt failed at Playwright/Chromium launch with the known macOS Mach-port
  IPC permission error; the escalated rerun completed all automated gate steps.

## Remaining Before PR Exit

- Manual phase-exit items printed by `make gate`: shinytest2 showcase smoke if
  applicable, manual a11y sweep, critical-code-reviewer on the diff, NEWS and
  DESCRIPTION version bump, phase-exit checklist, and phase tag.

Do not include `.vscode/` unless explicitly requested.

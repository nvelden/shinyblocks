# Agent Instructions

`shinyblocks` is an R package of shadcn-inspired, composable UI blocks for Shiny.
shadcn/ui is design-system source material — translate it into the package's
runtime, R API, and assets, not React source dropped into the package.

## Architecture

- Maintainer-owned **React/TS runtime** in `frontend/src`, built with Vite to
  `inst/www/shinyblocks-runtime.{js,css}`. R emits a payload rendered under
  `[data-shinyblocks-root]`.
- CSS source in `inst/www/src/` builds to `inst/www/shinyblocks.css` and
  `preflight.scoped.css`; app styles scoped under `.sb-app`.
- Next.js docs site in `docs-site/`.
- `inst/www/*.js|*.css`, `man/`, and the icon sprite are generated — edit the
  source and rebuild, never the output.
- `components.json` / root `package.json` exist only for shadcn CLI/agent
  context and are excluded from the R package build.

## Installed skills

Local under `.agents/skills/<name>` and `.claude/skills/<name>`:

- `shinyblocks-component` — end-to-end recipe for adding/refactoring a
  `block_*()`: per-gate sync (R + runtime + CSS + showcase + tests + spec +
  docs-site + NEWS), shadcn fidelity, and the parity harness under
  `tools/parity/`. **Invoke for any add-a-component / port / parity request.**
- `shadcn` — shadcn conventions, tokens, composition, accessibility.
- `r-package-development` — package structure, roxygen2, devtools, NEWS, checks.
- `testing-r-packages` — `testthat` 3 patterns, fixtures, snapshots, cleanup.
- `critical-code-reviewer` — defect/regression/maintainability reviews.
- `caveman` — ultra-terse output when asked.

## Working style

- Read the Architecture section above and the relevant component spec before
  implementing. Historical ADR files are not present in this checkout.
- Keep changes small and vertical: one component or planning artifact at a time.
- App-author code stays `htmltools`/`shiny`; never push a frontend build onto
  users. A new framework or a reversal of the runtime port needs a new ADR.
- Exported functions: roxygen docs, focused tests, `devtools::document()` when
  docs change. Follow the r-package-development / testing-r-packages skills.
- Accessible, keyboard-friendly markup; examples runnable on a standard
  R/Shiny install.
- After editing runtime JS/CSS, showcase wiring, or update handlers, fully
  restart the showcase.
- Verification tiers: `make check-fast` while editing · `make check-slice` per
  slice · `make gate` before PR/phase exit · `make gate-release` before release.
  Run parity/browser checks at slice boundaries.

### Agent-session gotchas

- Run `make showcase` outside the command sandbox / with escalation. A sandboxed
  process can log `Listening on http://127.0.0.1:4321` while staying unreachable
  — do not treat the log line as proof the showcase works.
- Before a showcase restart, run `lsof -nP -iTCP:4321 -sTCP:LISTEN` and stop any
  stale listener so old CSS/JS cannot persist. After the escalated restart, run
  `make showcase-health` (escalated) and require an HTTP success response.
- Run targeted Playwright/browser checks and docs-site commands that invoke
  `tsx` outside the command sandbox / with escalation. In sandboxed Codex
  sessions, `tsx` can fail with IPC permission errors before the real test runs.
- Run GitHub-mutating `gh` commands that require network access, such as
  `gh issue create`, outside the command sandbox / with escalation on the first
  attempt. Use `--body-file` for longer issue bodies so shell quoting does not
  fail before `gh` reaches GitHub.
- Prefer temp files / `--body-file` / here-docs for complex shell payloads.
  Don't inline long `gh ... --body "..."` or nested `Rscript -e "..."` strings
  with parentheses, backticks, quotes, or Markdown — zsh/sandbox wrapping can
  fail before the real command runs.

## Important files

- `AGENTS.md` — current architecture summary; historical ADR files are
  intentionally absent from this checkout.
- `HANDOFF.md` — in-flight work / current issue context.
- `R/` — exported R API. `frontend/src/` — runtime. `inst/www/src/` — CSS source.
- `inst/templates/` — starter app templates. `tests/testthat/` — package tests.

## Commands

```bash
Rscript -e "devtools::document()"   # or R CMD check . if devtools is unavailable
Rscript -e "devtools::test()"
npm exec -- shadcn@latest docs button card sidebar tabs   # shadcn reference
```

## Coding constraints

- Do not hand-edit generated `man/` files or build outputs under `inst/www/`.
- Do not commit `.Rproj.user`, `.Rhistory`, `.RData`, or check directories.
- Add tests for each exported helper once behavior is defined.

## Agent planning

Save plans under `docs/agent-plans/YYYY-MM-DD-short-title.md` with: goal,
assumptions, proposed API, files to edit, tests/checks, open questions.

# Agent Instructions

This repo is an R package scaffold for `shinyshadcn`, a Shiny dashboard package inspired by shadcn/ui.

## Installed Skills

- `shadcn`: installed locally under `.agents/skills/shadcn` and `.claude/skills/shadcn`.
- `r-package-development`: installed locally under `.agents/skills/r-package-development` and `.claude/skills/r-package-development`.
- `testing-r-packages`: installed locally under `.agents/skills/testing-r-packages` and `.claude/skills/testing-r-packages`.
- `critical-code-reviewer`: installed locally under `.agents/skills/critical-code-reviewer` and `.claude/skills/critical-code-reviewer`.
- `shinyblocks-component`: installed locally under `.agents/skills/shinyblocks-component` and `.claude/skills/shinyblocks-component`. End-to-end recipe for adding a `block_*()` component: per-gate sync rule (R + CSS + showcase + tests + spec + pkgdown + NEWS), shadcn-fidelity workflow against the `apps/v4/registry/new-york-v4` source, and the mechanical visual-parity harness under `tools/parity/`. **Invoke whenever the user asks to add a component, port a shadcn component, wrap a Shiny widget as a block, or improve parity of an existing `block_*()`** — don't reinvent the workflow each time.
- `caveman`: installed locally under `.agents/skills/caveman` and `.claude/skills/caveman`. Ultra-compressed communication mode. Cuts token usage ~75% by dropping filler, articles, and pleasantries while keeping full technical accuracy. Use when user says "caveman mode", "talk like caveman", "use caveman", "less tokens", "be brief", or invokes /caveman.


Use the shadcn skill for shadcn/ui component conventions, naming, composition rules, theming tokens, and accessibility patterns. This repo is not a React app, so translate those patterns into R, `htmltools`, Shiny, and package assets instead of adding React components directly.

Use the r-package-development skill for R package structure, roxygen2 docs, `devtools`, `testthat`, `NEWS.md`, and package checks.

Use the testing-r-packages skill when writing, organizing, or improving `testthat` tests, including fixtures, snapshots, mocking, cleanup, and test structure.

Use the critical-code-reviewer skill when the user asks for a review, critique, pull request review, or risk-focused assessment. Keep review output focused on concrete defects, regressions, missing tests, and maintainability risks.

The root `components.json` and `package.json` exist only to provide shadcn project context to AI agents and the `shadcn` CLI. They are excluded from the R package build.

## Working Style

- Read `PLAN.md` and `docs/ROADMAP.md` before implementing.
- Keep changes small and vertical: one component or one planning artifact at a time.
- Prefer idiomatic R package structure over custom conventions.
- Use `htmltools`, `shiny`, and package assets under `inst/` before introducing a frontend build step.
- Do not add a Node/Tailwind build unless a decision record explicitly approves it.
- Do not run `npx shadcn@latest add` into this package unless a decision record explicitly approves using generated React source as research material.
- Use accessible markup and keyboard-friendly interactions.
- Keep examples runnable with a standard R/Shiny installation.
- Follow the r-package-development skill when adding exported functions: roxygen docs, focused tests, and `devtools::document()` when docs change.
- Follow the testing-r-packages skill for modern `testthat` 3 patterns when adding or refactoring tests.
- After editing runtime JS/CSS, showcase wiring, or component update handlers, fully restart the local showcase.
- In Codex/agent sessions, always run `make showcase` outside the command sandbox / with escalation. A sandboxed process can print `Listening on http://127.0.0.1:4321` while remaining unreachable from later commands, so do not try a sandboxed launch first and do not treat the log line as proof that the showcase is usable.
- Before every agent-driven showcase restart, run `lsof -nP -iTCP:4321 -sTCP:LISTEN`. If a stale listener exists, stop that process first so stale CSS/JS cannot remain active. After the escalated restart, run `make showcase-health` outside the sandbox / with escalation and require an HTTP success response.
- In Codex/agent sessions, prefer temp files / `--body-file` / here-docs for complex shell payloads. Do not inline long `gh issue comment ... --body "..."` strings or heavily nested `Rscript -e "..."` expressions when they contain parentheses, backticks, quotes, or Markdown; zsh parsing and sandbox command wrapping can fail before the real command runs.

## Important Files

- `PLAN.md`: current product and architecture plan.
- `docs/ROADMAP.md`: implementation sequence.
- `docs/decisions/`: architecture decision records.
- `R/`: exported R API.
- `inst/www/`: CSS and JavaScript assets.
- `inst/templates/`: starter app templates or examples.
- `tests/testthat/`: package tests.

## Commands

Use these when dependencies are installed:

```bash
Rscript -e "devtools::document()"
Rscript -e "devtools::test()"
Rscript -e "devtools::check()"
```

If `devtools` is unavailable:

```bash
R CMD check .
```

For shadcn reference context:

```bash
npm exec -- shadcn@latest info --json
npm exec -- shadcn@latest docs button card sidebar tabs
```

## Coding Constraints

- Do not rewrite generated `man/` files by hand.
- Do not commit local `.Rproj.user`, `.Rhistory`, `.RData`, or package check directories.
- Add exported functions with roxygen comments.
- Keep public API examples simple and runnable.
- Add tests for each exported helper once behavior is defined.

## Agent Planning

When creating a plan, save it under `docs/agent-plans/YYYY-MM-DD-short-title.md`.

Plans should include:

- goal;
- assumptions;
- proposed API;
- files to edit;
- tests/checks;
- open questions.

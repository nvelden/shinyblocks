# Agent Instructions

This repo is an R package scaffold for `shinyshadcn`, a Shiny dashboard package inspired by shadcn/ui.

## Installed Skills

- `shadcn`: installed locally under `.agents/skills/shadcn` and `.claude/skills/shadcn`.
- `r-package-development`: installed locally under `.agents/skills/r-package-development` and `.claude/skills/r-package-development`.

Use the shadcn skill for shadcn/ui component conventions, naming, composition rules, theming tokens, and accessibility patterns. This repo is not a React app, so translate those patterns into R, `htmltools`, Shiny, and package assets instead of adding React components directly.

Use the r-package-development skill for R package structure, roxygen2 docs, `devtools`, `testthat`, `NEWS.md`, and package checks.

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

# Agent Instructions

This repo is an R package scaffold for `shinyshadcn`, a Shiny dashboard package inspired by shadcn/ui.

## Working Style

- Read `PLAN.md` and `docs/ROADMAP.md` before implementing.
- Keep changes small and vertical: one component or one planning artifact at a time.
- Prefer idiomatic R package structure over custom conventions.
- Use `htmltools`, `shiny`, and package assets under `inst/` before introducing a frontend build step.
- Do not add a Node/Tailwind build unless a decision record explicitly approves it.
- Use accessible markup and keyboard-friendly interactions.
- Keep examples runnable with a standard R/Shiny installation.

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

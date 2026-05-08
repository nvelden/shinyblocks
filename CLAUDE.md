# Claude Instructions

You are working on `shinyshadcn`, an R package for shadcn-inspired Shiny dashboards.

The official shadcn skill is installed locally under `.claude/skills/shadcn` and `.agents/skills/shadcn`. Use it for component composition rules, semantic token conventions, form patterns, icon rules, and CLI docs.

The Posit r-package-development skill is installed locally under `.claude/skills/r-package-development` and `.agents/skills/r-package-development`. Use it for R package structure, roxygen2 documentation, testthat tests, devtools workflows, package checks, and NEWS guidance.

The Posit testing-r-packages skill is installed locally under `.claude/skills/testing-r-packages` and `.agents/skills/testing-r-packages`. Use it when writing, organizing, or improving `testthat` tests, including fixtures, snapshots, mocking, cleanup, and test structure.

The Posit critical-code-reviewer skill is installed locally under `.claude/skills/critical-code-reviewer` and `.agents/skills/critical-code-reviewer`. Use it when asked for code reviews, PR reviews, critiques, or risk-focused assessments.

Important: this repository is an R package, not a React app. Treat shadcn/ui as design-system source material. Translate concepts into `htmltools`, Shiny tags, CSS variables, and small JavaScript behaviors only when needed.

Start with the planning docs:

1. `PLAN.md`
2. `docs/ROADMAP.md`
3. `docs/decisions/`
4. `AGENTS.md`

## Expectations

- Keep implementation incremental.
- Preserve R package conventions.
- Prefer clear API design and documented decisions over large speculative code.
- Do not introduce React, Tailwind, Vite, or other frontend tooling without an architecture decision record.
- Do not add shadcn React component source into `R/` or `inst/` unless a decision record explicitly approves it as reference material.
- When adding user-facing R functions, follow the r-package-development skill: exported functions get roxygen docs, tests live in `tests/testthat`, and docs are regenerated with `devtools::document()`.
- When adding or refactoring tests, follow the testing-r-packages skill for modern `testthat` 3 practices.
- Use `htmltools` and `shiny` primitives first.
- For UI components, think in states: default, hover, focus, disabled, active, selected, loading, error.
- For every component plan, include accessibility notes.

## Useful Task Pattern

When asked to plan a component:

1. Describe the component contract.
2. Sketch the R function signature.
3. Define generated HTML structure.
4. List CSS variables/classes needed.
5. Identify any JavaScript behavior.
6. Add tests and examples.

## Files Claude Can Add

- `docs/agent-plans/*.md`
- `docs/decisions/*.md`
- `R/*.R`
- `inst/www/*`
- `inst/templates/*`
- `tests/testthat/*.R`

Keep generated docs out of hand edits unless explicitly asked.

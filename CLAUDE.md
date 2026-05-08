# Claude Instructions

You are working on `shinyshadcn`, an R package for shadcn-inspired Shiny dashboards.

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

---
title: Component-by-component runtime rollout
date: 2026-05-13
---

# Goal

Move from the button/select runtime spike into a repeatable component
workflow: update one component, update its docs and showcase page, run
focused checks, then pause for manual approval before touching the next
component.

# Assumptions

- `block_button()` and `block_select()` are the current runtime baseline.
- Runtime payloads should be strict. Normalize at the R boundary and let
  malformed payloads fail instead of adding duplicate browser fallbacks.
- The showcase is part of the component contract, not a separate demo.
- The button and select showcase pages define the documentation
  structure for future components: live playground, generated source,
  server source where relevant, and API reference table.
- Manual approval remains the gate between components.

# Proposed API

- Keep exported `block_*()` helpers idiomatic R functions.
- Keep runtime payload shapes explicit and stable:
  - R parses user-facing convenience inputs such as CSS declaration
    strings.
  - React receives already-normalized values.
  - Shiny update helpers mutate only the documented runtime props/state.
- Add `update_block_*()` helpers only when a component needs true
  server-side runtime updates. Presentational components can re-render
  through `renderUI()`.

# Files To Edit Per Component

- `R/<component>.R` or `R/components.R`
- `frontend/src/index.jsx` only when runtime rendering changes
- `inst/www/src/shinyblocks.css` only when tokens/styles change
- `inst/showcase/R/examples/<component>.R`
- `inst/showcase/R/server_<component>.R`
- `tests/testthat/`
- `docs/component-specs/` and parity metadata when applicable
- `NEWS.md` and generated docs when public behavior changes

# Showcase Page Contract

Every component migration must update the Shiny showcase in the same
component slice. A component is not done if the runtime works but the
showcase still has a static, old, or incomplete example.

Use the button/select pages as the required structure:

- **Interactive Playground** at the top of the component page.
- **Preview** rendered from current control values.
- **UI Definition** source block that prints the exact `block_*()` call
  currently used for the preview.
- **Server Action** source block for stateful/updateable components.
  Presentational components should still show a short comment explaining
  that re-rendering through `renderUI()` is the update path.
- **Controls grouped by purpose**:
  - Data: labels, values, choices, content, icons, or children.
  - State: disabled, invalid, selected, open, checked, loading, etc.
  - Styling: size, variant, width, style, class, alignment, placement.
  - Actions: server-side update buttons where the component has an
    `update_block_*()` helper or other runtime mutation.
- **API Reference** table at the bottom of the page.

The API table should be generated in the component server file from a
small, explicit data frame/list rather than hand-written in prose, and
it should include:

- argument name;
- default value;
- accepted values where finite;
- purpose;
- whether the argument affects data, state, styling, accessibility, or
  server update behavior.

For stateful components, the page must also include at least one visible
server update path and one visible output/value readback so manual
review can verify Shiny reactivity without reading code.

# Tests And Checks

- Targeted `devtools::test()` filter for the component and runtime
  payload helpers.
- `npm run build:runtime` when React runtime source changes.
- `npm run test:runtime` for generic mount/update regressions.
- `npm run test:showcase` when the interactive showcase changes.
- Showcase smoke coverage must confirm the page has the playground
  structure: preview, UI source, server source/comment, controls, and
  API table.
- Manual browser approval at `http://127.0.0.1:4321/#<component>`.

# Rollout Steps

1. Pick one component.
2. Review the existing R helper, CSS, showcase page, docs, and tests.
3. Implement the smallest vertical runtime/doc/showcase change.
4. Update the Shiny showcase page to the playground/API/source contract.
5. Remove compatibility fallback code that only hides payload defects.
6. Add focused regression coverage for the behavior that changed.
7. Run the targeted checks and rebuild generated assets.
8. Start the showcase and pause for manual approval.

# Open Questions

- Which component follows button/select: badge as the low-risk runtime
  control, or separator as the next already-registered parity component?
- Should presentational components without Shiny input state get any
  browser smoke coverage beyond runtime mount checks?
- Should `make gate` eventually include `showcase-test`, or should it
  remain a component-slice check until the showcase smoke suite is broad?

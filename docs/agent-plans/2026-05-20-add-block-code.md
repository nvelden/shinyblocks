# Plan — Add `block_code()` component

This plan details the addition of a shadcn-docs-style `block_code()` component.

## Goals
- Add the `block_code()` R export representing a pre-formatted,
  token-driven code frame with line numbers.
- Register and hydrate the corresponding `<Code />` component in the frontend runtime (`frontend/src/index.jsx`) featuring a clipboard-copy button with copy-success micro-animations.
- Implement docs-style monospace typography, line gutters, copy controls,
  and light/dark theme variables under `frontend/src/styles/runtime.css`.
- Add documentation, a spec sheet, unit tests, and showcase wiring matching the standard per-gate sync rule checklist.

## Proposed API
```r
block_code <- function(
  code,
  language = NULL,
  copyable = TRUE,
  line_numbers = TRUE,
  header = FALSE,
  variant = c("default", "outline"),
  class = NULL,
  style = NULL,
  ...
)
```

## Proposed Changes

### 1. R Package Exports
- **`R/components.R`**: Define `block_code(...)` returning a `runtime_component("code", ...)` payload.
- **`NAMESPACE`**: Export `block_code` (auto via `devtools::document()`).
- **`man/block_code.Rd`**: Generated documentation (auto via `devtools::document()`).

### 2. Frontend Runtime
- **`frontend/src/index.jsx`**:
  - Implement `<Code payload={payload} />` component.
  - Mount clipboard copy click handler with visual feedback (changing Lucide checkmark icon for 2s).
  - Register it in `RuntimeMount`.
- **`frontend/src/styles/runtime.css`**: Add styles for `.sb-code-block`
  (pre, code, line numbers, copy button, optional header, hover states, and
  dark-mode normalization).

### 3. Verification & Showcase
- **`inst/showcase/app.R`**: Register `code` in the sections list.
- **`inst/showcase/R/examples/code.R`**: Interactive playground.
- **`inst/showcase/R/server_code.R`**: Wire showcase outputs, R code preview, and the API reference table.
- **`inst/showcase/www/showcase.css`**: Style `#showcase_code_api_table`.
- **`_pkgdown.yml`**: Add entry under "Content" reference category.
- **`tests/testthat/test-components.R`** (or `test-shell.R`): Add tag-shape, variants, and copyable validation cases.
- **`docs/component-specs/code.md`**: Fill standard spec sheet with tokens and screenshot pointer.
- **`NEWS.md`**: Add changelog bullet.

### 4. Docs Site
- **`docs-site/content/previews/code.R`**: Static example payload.
- **`docs-site/content/previews/_registry.R`**: Register the `code` slug.
- **`docs-site/lib/api-reference.ts`**: Document function parameters.

## Verification Plan
1. **R Package Tests**: Run `Rscript -e 'devtools::test()'` to ensure 100% test coverage and per-gate doc coverage compliance.
2. **CSS Build**: Run `make build-css` and `make build-runtime` to bundle CSS/JS.
3. **Showcase Visual Verification**: Start showcase via `make showcase` (or check active background server on port `4321`) and inspect page visually.
4. **Docs Site Verification**: Compile static previews and verify the docs-site preview compiles cleanly.

## Completion Notes

- `block_code()` renders through the package runtime and is documented,
  tested, exported, and listed in the showcase.
- The runtime code block wraps long lines instead of horizontally
  scrolling. The behavior is shared by the Shiny showcase and the static
  docs site.
- The Shiny showcase now uses `block_code()` for UI Definition, Server
  Action, `input$...` value readouts, and section View source panels.
- The docs site preview generator emits a `codeHtml` field for every
  component recipe by rendering `shinyblocks::block_code(...)`; component
  detail pages use that generated HTML in the R Code section.
- Verified with focused R tests, docs build, docs Playwright detail test,
  and browser DOM checks against both `http://127.0.0.1:4321/` and
  `http://localhost:4173/shinyblocks/`.

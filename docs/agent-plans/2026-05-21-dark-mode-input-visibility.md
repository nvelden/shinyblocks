# Plan: Align Dark and Light Mode Theme Colors for Input Components

**Goal**: Resolve poor control contrast and visibility of input components (inputs, textareas, selects, checkboxes, radio groups) inside dark containers in dark mode, aligning default colors with shadcn/ui.

## Assumptions
- Custom styling variables are defined under `[data-theme="dark"]` in `frontend/src/styles/runtime.css`.
- Inputs currently use `background-color: transparent` which blends with parent containers like the playground sidebar.
- Updating background colors to `var(--background)` will provide a strong, crisp visual contrast, matching shadcn's original design language.

## Proposed API / Style Changes
No new R APIs are introduced. This is a CSS refinement in the package's runtime stylesheet.

### Files to Edit
1. `frontend/src/styles/runtime.css`

## Steps to Execute
1. **Modify Inputs backgrounds**: Update `.sb-textarea-control`, `.sb-input-control`, `.sb-select-trigger`, and `.sb-radio-group-button` to use `background-color: var(--background)`.
2. **Remove Dark overrides**: Clean up the `[data-theme="dark"]` custom overrides for `.sb-checkbox-button` and `.sb-select-trigger` so they cleanly use `var(--background)`.
3. **Rebuild Asset**: Run `npm run build:runtime` to minify and compile to `inst/www/shinyblocks-runtime.css`.
4. **Cache Busting**: Increment CSS version tag in `inst/showcase/app.R` to ensure clean reloading.

## Verification
1. Run automated checks: `devtools::test()`.
2. Launch `make showcase`, toggle dark mode, and verify that controls in the sidebar are clearly visible and well-defined.

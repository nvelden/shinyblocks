# Plan: Universal Showcase Preview CSS in Core Runtime

This plan details how to make the custom showcase preview class styles universally available to all Shiny and Shinylive apps using the `shinyblocks` package. It does this by compiling the custom classes directly into the package's core runtime CSS instead of relying on duplicate, ad-hoc inline styles.

## Goal
Ensure custom showcase preview styles (e.g., `.showcase-select-preview-custom`, `.showcase-button-preview-custom`, etc.) are robust, correctly scoped to nested controls (e.g., button triggers, text areas), and compile directly into the `shinyblocks-runtime.css` asset, so that they render correctly in sandboxed playgrounds, Shinylive apps, and standard R/Shiny dashboards.

## Assumptions
- Playground applications (e.g., `docs-site/playgrounds/select/app.R`) run in sandboxed `<iframe>` elements that automatically load `shinyblocks-runtime.css` but do not load `showcase.css`.
- Classes passed to `class` in `block_*` functions propagate to `sb-runtime-mount` (which has `data-shinyblocks-root = ""`) and/or inner components.
- Standard R/Shiny dashboards and Shinylive apps will immediately get access to these styles when we compile the runtime CSS and update the Wasm package binaries.

## Proposed CSS Rules
Add the following scoped preview rules to `frontend/src/styles/runtime.css`:

```css
/*
 * Custom showcase preview classes for high fidelity demonstrations.
 * Built into the core runtime to ensure visual parity in all Shiny and Shinylive apps.
 */
[data-shinyblocks-root].showcase-select-preview-custom .sb-select-trigger,
.showcase-select-preview-custom .sb-select-trigger {
  border: 2px dashed var(--ring) !important;
}

[data-shinyblocks-root].showcase-button-preview-custom .sb-button,
.showcase-button-preview-custom .sb-button,
[data-shinyblocks-root].showcase-button-preview-custom,
.showcase-button-preview-custom {
  border: 2px dashed var(--ring) !important;
}

[data-shinyblocks-root].showcase-dialog-preview-custom .sb-dialog-content,
.showcase-dialog-preview-custom .sb-dialog-content,
[data-shinyblocks-root].showcase-dialog-preview-custom,
.showcase-dialog-preview-custom {
  border: 2px dashed var(--ring) !important;
}

[data-shinyblocks-root].showcase-popover-preview-custom .sb-popover-content,
.showcase-popover-preview-custom .sb-popover-content,
[data-shinyblocks-root].showcase-popover-preview-custom,
.showcase-popover-preview-custom {
  border: 2px dashed var(--ring) !important;
}

[data-shinyblocks-root].showcase-tooltip-preview-custom .sb-tooltip-content,
.showcase-tooltip-preview-custom .sb-tooltip-content,
[data-shinyblocks-root].showcase-tooltip-preview-custom,
.showcase-tooltip-preview-custom {
  border: 2px dashed var(--ring) !important;
}

[data-shinyblocks-root].showcase-checkbox-preview-custom .sb-checkbox-button,
.showcase-checkbox-preview-custom .sb-checkbox-button {
  border: 2px dashed var(--ring) !important;
}

[data-shinyblocks-root].showcase-textarea-preview-custom .sb-textarea-control,
.showcase-textarea-preview-custom .sb-textarea-control {
  border: 2px dashed var(--ring) !important;
}

[data-shinyblocks-root].showcase-input-preview-custom .sb-input-control,
.showcase-input-preview-custom .sb-input-control {
  border: 2px dashed var(--ring) !important;
}

[data-shinyblocks-root].showcase-input-group-preview-custom,
.showcase-input-group-preview-custom {
  border: 2px dashed var(--ring) !important;
}

[data-shinyblocks-root].showcase-switch-preview-custom .sb-switch-button,
.showcase-switch-preview-custom .sb-switch-button {
  outline: 2px dashed var(--ring) !important;
  outline-offset: 2px;
}

[data-shinyblocks-root].showcase-radio-group-preview-custom .sb-radio-group-control,
.showcase-radio-group-preview-custom .sb-radio-group-control {
  border: 2px dashed var(--ring) !important;
  padding: 0.75rem !important;
  border-radius: 0.5rem !important;
}

[data-shinyblocks-root].showcase-slider-preview-custom .sb-slider-thumb,
.showcase-slider-preview-custom .sb-slider-thumb {
  border: 2px dashed var(--ring) !important;
}

[data-shinyblocks-root].sb-code-custom,
.sb-code-custom {
  border: 2px dashed var(--ring) !important;
  background-color: color-mix(in oklch, var(--muted) 80%, var(--primary) 20%) !important;
}
```

## Files to Edit
1. **MODIFY** [runtime.css](file:///Users/nielsvandervelden/Documents/2026%20github/shinyblocks/frontend/src/styles/runtime.css): Append the custom showcase styles at the end of the file.
2. **MODIFY** [app.R](file:///Users/nielsvandervelden/Documents/2026%20github/shinyblocks/docs-site/playgrounds/select/app.R): Remove the inline `htmltools::tags$head(...)` tag block setting custom border styling.

## Build and Compilation
Run `npm run build` from the workspace root directory to compile `frontend/src/styles/runtime.css` into `inst/www/shinyblocks-runtime.css`.
Run `Rscript scripts/generate-playgrounds.R` in `docs-site/` (if needed) to regenerate playground assets.

## Verification Plan
1. **Local Build Check**: Run `npm run build` to verify standard build pipeline and CSS minification pass correctly.
2. **Playground Verification**: Run a local preview or verify that the compiled CSS matches expectations.
3. **Clean git status check**: Verify that the built asset `inst/www/shinyblocks-runtime.css` is generated and contains the new classes.

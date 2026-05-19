# Legacy Audit Allowlist

The runtime migration is allowed to carry only explicit transitional debt. Run:

```bash
make legacy-audit
```

The audit scans `R/`, `inst/`, `tests/`, `tools/`, and `docs/` for old wrapper and host-framework patterns such as Selectize, ionRangeSlider, Shiny widget wrappers, Bootstrap tab internals, and legacy button classes.

## Current Allowed Categories

- Historical ADRs and agent plans may mention old approaches for context.
- `docs/ROADMAP.md` may track removed and pending migration work.
- `docs/troubleshooting.md`, `R/tabs.R`, `inst/www/shinyblocks.js`, and tab tests may mention Bootstrap/Shiny tab internals until issue #10 is complete.
- Runtime CSS tests may list forbidden host selectors because they assert those selectors are absent from `shinyblocks-runtime.css`.
- Runtime Shiny collision fixtures may create host Bootstrap/Selectize-like nodes to prove scoped runtime CSS does not affect them.
- `inst/www/src/shinyblocks.css` and `R/dark-mode.R` may keep `.sb-button-*` only for `block_dark_mode_toggle()` until shell migration removes that dependency.
- Showcase source snippets may keep `.sb-button-*` only for action-button examples until those snippets migrate to `block_button()`.
- `docs/component-specs/slider.md` may state that slider no longer wraps `shiny::sliderInput()` / ionRangeSlider.
- `docs/skills/shinyblocks-component.md` may retain historical pitfall notes until the runtime-skill refresh is completed.

## Rule

A new hit is not acceptable just because it works. Either remove it, move it to historical documentation, or add a narrow allowlist entry with a removal trigger.

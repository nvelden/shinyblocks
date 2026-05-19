# Legacy Audit Allowlist

The runtime migration is allowed to carry only explicit transitional debt. Run:

```bash
make legacy-audit
```

The audit scans `R/`, `inst/`, `tests/`, `tools/`, and `docs/` for old wrapper and host-framework patterns such as Selectize, ionRangeSlider, Shiny widget wrappers, Bootstrap tab internals, and legacy button classes.

## Current Allowed Categories

- Historical ADRs and agent plans may mention old approaches for context.
- `docs/ROADMAP.md` may track removed and pending migration work.
- `docs/troubleshooting.md` may mention Bootstrap as user-facing host context.
- Tab tests may mention old Bootstrap/Shiny tab internals only to assert they are absent from the rendered shinyblocks contract.
- Runtime CSS tests may list forbidden host selectors because they assert those selectors are absent from `shinyblocks-runtime.css`.
- Runtime Shiny collision fixtures may create host Bootstrap/Selectize-like nodes and one nested raw Shiny text input to prove scoped runtime CSS does not affect them.
- `inst/www/src/shinyblocks.css` may still contain `.sb-button-*` while shell/showcase cleanup migrates the remaining non-runtime button snippets. `R/dark-mode.R` is no longer an allowlisted reason for keeping those selectors.
- Showcase source snippets may still reference `.sb-button-*` only through the centralized `showcase_action_button()` helper in `inst/showcase/R/render_example.R`, because those server-update controls still need native `actionButton()` click semantics. Do not reintroduce per-example wrappers.
- `docs/component-specs/slider.md` may state that slider no longer wraps `shiny::sliderInput()` / ionRangeSlider.
- `docs/skills/shinyblocks-component.md` may retain historical pitfall notes until the runtime-skill refresh is completed.
- `block_input_group()` and `block_input_group_addon()` are not audit failures by themselves: they are explicitly classified as R-side composition/layout primitives. New examples should compose them with runtime controls such as `block_input()` rather than reintroducing wrapped Shiny inputs.
- New live code should not reintroduce `shiny::textInput()` inside migrated field/showcase paths. If a raw Shiny text input is still needed for a collision or child-binding fixture, it must be narrowly allowlisted with its reason.

## Rule

A new hit is not acceptable just because it works. Either remove it, move it to historical documentation, or add a narrow allowlist entry with a removal trigger.

---
title: Expand visual parity harness to all shinyblocks components
date: 2026-05-11
---

# Goal

Take the current ADR 0016 parity harness from a `button`-only proof of
completion to a repeatable workflow that covers every exported
`block_*()` component with an auditable baseline and a gate that does
not over-claim its coverage.

# Status

- Completed on 2026-05-11:
  - `make parity-ci` now iterates over the shared registry instead of
    hardcoding `button`.
  - The shared registry + committed baselines now cover `button`,
    `checkbox`, `select`, `slider`, and `switch`.
  - The shared capture/diff path supports role-mapped components and
    state-specific selectors for wrapper controls.
- Remaining scope:
  - migrate the rest of the high-risk components
  - remove standalone POCs once the shared harness fully duplicates
    their coverage

# Assumptions

- The current shared harness under `parity/` + `tools/parity/` is the
  long-term path; standalone POCs are transitional.
- `docs/component-specs/*.md` and committed screenshots remain useful
  review artifacts even after computed-style parity becomes the primary
  gate.
- Gallery `.qmd` coverage remains blocked on the WASM track and is not
  part of this parity-expansion slice.
- Some wrapper components will need role-mapped selectors and a small
  set of documented known divergences rather than strict DOM parity.

# Proposed API

- Keep `node tools/parity/diff-styles.mjs --component <name>` as the
  per-component entrypoint.
- Add `make parity COMPONENT=<name>` for targeted local work.
- Change `make parity-ci` to iterate over every registered component
  instead of hardcoding `button`.
- Keep `docs/component-specs/_parity/<name>.json` as the committed
  baseline format.

# Files To Edit

- `Makefile`
  - parameterize `parity`
  - make `parity-ci` loop over the registry
  - keep background-process cleanup robust on failure
- `tools/parity/registry.mjs`
  - add one config per supported component
  - group property sets by component family where possible
  - add a machine-readable list/export for CI iteration
- `tools/parity/capture-styles.mjs`
  - support richer states beyond `default` / `hover` / `disabled`
  - add role-aware capture for multi-part components
- `tools/parity/diff-styles.mjs`
  - support known divergences from baseline metadata
  - emit clearer per-role output for wrappers
- `parity/src/main.js`
  - add a reference route/render for each migrated component
- `docs/component-specs/_parity/`
  - add one baseline JSON per migrated component
- `docs/skills/shinyblocks-component.md`
  - sync instructions with the actual harness files and commands
- `docs/ROADMAP.md`
  - stop claiming full parity coverage until the registry actually has it
- `docs/phase-exits/TEMPLATE.md`
  - replace deleted screenshot-queue checks with the real parity gate

# Tests And Checks

- `make parity COMPONENT=button`
- `make parity COMPONENT=select`
- `make parity COMPONENT=slider`
- `make parity COMPONENT=checkbox`
- `make parity COMPONENT=switch`
- `make parity-ci`
- `Rscript -e 'devtools::test()'`
- `Rscript -e 'pkgdown::build_site(preview = FALSE)'`
- manual spot-check of at least one wrapper and one presentational
  component in light/dark mode

# Rollout Order

1. Fix scope honesty first.
   Update the Makefile/docs/template so the gate description matches the
   code that exists today.

2. Migrate existing high-value POCs into the shared registry.
   `select` and `slider` are complete; use the same shared-harness
   shape for the next wrappers instead of growing new one-off scripts.

3. Add components by family.
   Suggested order:
   - action/content primitives: `badge`, `alert`, `separator`,
     `skeleton`, `spinner`, `empty`
   - form wrappers: `textarea`
   - composites/navigation: `tabs`, `nav-item`, `sidebar`,
     `dark-mode-toggle`

4. Add baseline metadata for intentional divergences.
   Do not force strict equality where the repo has already accepted
   wrapper DOM differences or source-vs-docs rendering differences.

5. Only after the registry is broad enough, tighten the roadmap/gate
   language to say parity is the primary cross-component verifier.

# Open Questions

- Should layout-shell components such as `block_page()`, `block_body()`,
  and `block_header()` participate in the parity registry, or remain
  spec-and-showcase reviewed only?
- Do we want a `known_divergences` key in the baseline JSON now, as ADR
  0016 describes, before migrating more wrappers?
- Should the remaining screenshot-only review workflow be further
  reduced once the registry covers the same component set?

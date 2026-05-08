# ADR 0012: Rename Package to shinyblocks

## Status

Accepted (2026-05-08)

## Context

`shinyshadcn` described the design lineage, but the name is hard to spell,
hard to remember, and too tightly coupled to an upstream project name. The
package should be easy for Shiny users to recall and type.

Name availability was checked on 2026-05-08:

- CRAN: no exact or case-insensitive package match for `shinyblocks`.
- Bioconductor: no exact package match for `shinyblocks`.
- R-universe: no `shinyblocks` search result.
- npm: no `shinyblocks` package.
- `github.com/nvelden/shinyblocks`: unavailable response was 404, so the
  repository name was available under the maintainer account.
- GitHub globally: `DEITrust/shinyblocks` exists as an unrelated TypeScript
  smart-contract project; this is not an R/Shiny package.

## Decision

Rename the project and package to `shinyblocks`.

The public R API uses the `block_*` prefix instead of `shadcn_*`:

- `block_page()`
- `block_header()`
- `block_sidebar()`
- `block_nav_item()`
- `block_card()`
- `block_button()`
- future helpers such as `block_tabs()`, `block_field()`,
  `block_theme()`, and `block_icon()`

The package keeps shadcn/ui as an upstream design reference, but not as the
package identity. Documentation should say "inspired by shadcn/ui" where
relevant.

Internal names change as follows:

- package assets use `inst/www/shinyblocks.css` and
  `inst/www/shinyblocks.js`;
- CSS classes use the `sb-` prefix;
- CSS custom properties use the `--sb-*` prefix;
- Shiny custom message names use `sb:*`;
- local storage keys use `sb-*`;
- internal package options use the `shinyblocks.*` namespace.

## Consequences

- The package is easier to remember and less dependent on upstream naming.
- Existing scaffold functions and docs must be renamed before Phase 1A begins.
- Since the package has not been released, no compatibility aliases are needed.
- Upstream sync docs still use `shadcn/ui` because that is the actual upstream
  design system being reviewed.

## References

- CRAN package index checked on 2026-05-08.
- GitHub repository search checked on 2026-05-08.
- npm package lookup checked on 2026-05-08.

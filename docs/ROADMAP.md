# Roadmap

The strategy lives in
[`agent-plans/2026-05-08-port-strategy.md`](agent-plans/2026-05-08-port-strategy.md).
This document is the implementation sequence.

Each phase ends by passing the **Quality Gate** below before the next
phase begins.

## Current Status

> **Phase 0 complete** — ADRs `0006`–`0012` are accepted.
> Next: start Phase 1A, the asset dependency and static shell slice.

Update this line at every phase exit.

## Repository Policy

The public GitHub repository is kept package-facing: source under `R/`,
assets under `inst/`, generated `man/`, tests, package metadata, and
human-facing package docs. Agent instructions, scratch plans, local
tooling notes, and long-form implementation planning can remain in the
maintainer workspace until they are intentionally promoted.

When this roadmap says "commit" a planning artifact, read that as:
commit it if the artifact is part of the public repo at that point;
otherwise update the maintainer planning workspace. Package-facing
artifacts such as `DESCRIPTION`, `NEWS.md`, `README.md`, source files,
tests, package assets, and CI files must be committed when created.

## Quality Gate (Every Phase)

No phase is complete until every step below passes, **in this order**.
Order matters: cheap automated checks run first so reviewers and
humans never waste attention on issues a tool catches. The gate is
runnable as `make gate` (script invokes everything in sequence and
prints a summary).

Versioned inputs are never assumed current. Before a phase changes any
dependency, package, JS library, R package, build tool, upstream
component contract, API documentation, deployment tool, or compatibility
assumption, verify the latest available version from the authoritative
source and record the check in the relevant ADR, sync log, roadmap note,
or phase-exit file.

### A. Verify — automated

1. **Build pipeline.** `make build-css` is clean; the committed
   `inst/www/shinyblocks.css` matches what the source produces
   (CI drift check).
2. **Lint.** `lintr::lint_package()` is clean. Style violations are
   fixed, not silenced.
3. **Spelling.** `devtools::spell_check()` is clean. New jargon goes
   into `inst/WORDLIST`.
4. **URLs.** `urlchecker::url_check()` is clean. Dead `\url{}` and
   `\href{}` in roxygen are fixed before merge.
5. **Latest-version verification.** All versioned inputs touched in
   the phase have been checked against authoritative current sources:
   CRAN/BioConductor/r-universe/r-wasm for R packages as applicable,
   npm or upstream release tags for JS tools, official docs for API
   behavior, and upstream project releases or commits for shadcn/ui,
   Tailwind, Shinylive, Shiny, htmltools, bslib, and related
   libraries. The exact source/date/version checked is recorded.
6. **Tests.** `devtools::test()` is clean. Every new exported
   function has tag-shape, validation, ARIA, and (where relevant)
   `merge_classes()` tests. Tests follow the `testing-r-packages`
   skill: self-sufficient, snapshot-based for stable HTML, `withr`
   for cleanup.
7. **Documentation.** `devtools::document()` produces no warnings.
   Generated `man/` files are committed.
8. **Package check.** Routine phase gates use
   `devtools::check(remote = TRUE, manual = FALSE)` or
   `R CMD check --no-manual` on the built source package. Full manual
   PDF checks are release-gate work because they require a TeX setup.
   The routine check must be clean: no errors, warnings, or notes
   (or documented
   `cran-comments.md` exceptions). Run every phase, not just at
   release — early signal beats late surprise.
9. **pkgdown.** `pkgdown::build_site()` succeeds. New components have
   reference pages with rendered live examples. The component
   gallery index reflects new additions. Articles updated where
   APIs changed. When the public site is composed for deployment,
   pkgdown output is written under generated `site/` output rather
   than the maintainer planning `docs/` tree.

### B. Verify — semi-automated

10. **Showcase smoke test.** `shinytest2` launches
   `inst/showcase/app.R`, navigates every gallery section, and
   `expect_screenshot()`s each. Screenshots committed; visual diffs
   reviewed when they change. From Phase 1C onward, a Shinylive
   export smoke also stages the showcase, exports to `site/showcase/`,
   serves `site/` with `python3 -m http.server`, waits through the
   webR first load, enters the app iframe, and verifies the shell,
   sidebar, theme, and at least one component on desktop and mobile.
11. **Performance budget.** A `tools/budget.R` script prints sizes
    of `inst/www/shinyblocks.css`, `shinyblocks.js`, and
    `icons/sprite.svg`. Targets: CSS ≤30 KB minified, JS ≤15 KB,
    sprite ≤25 KB gzipped. Over budget = blocking unless ADR'd.
12. **Accessibility sweep.** Manual on the showcase: keyboard tab
    order, visible focus on every interactive element, screen
    reader smoke (VoiceOver or Orca) on every component added in
    the phase. Findings logged in `docs/a11y/notes.md`.

### C. Review

13. **Roxygen audit.** Every exported function has `@param` for each
    argument, `@return`, `@export`, at least one runnable
    `@examples` block, and a `@family` tag. Internal helpers are
    `@noRd`. Cross-references resolve.
14. **Utility audit.** No copy-pasted helpers across `R/*.R`. Shared
    logic lives in `R/utils.R`. Internal helpers are not exported.
15. **Critical code review.** Invoke the `critical-code-reviewer`
    skill against the phase diff. Address every Blocking and
    Required item; log Suggestions deliberately accepted/declined.

### D. Document

16. **NEWS.md.** New user-visible changes summarized under the
    next dev-version heading (see step 18). Tone: changelog for
    users, not changelog for committers.
17. **`docs/` updates.** `ROADMAP.md` phase checkbox flipped.
    Strategy doc amended if scope changed. New or amended ADRs
    committed under `docs/decisions/`. `docs/upstream/sb-sync.md`
    gets an entry whenever shadcn upstream was reviewed during the
    phase. Cross-link check: a small script greps for
    `](.*\.md)` patterns and verifies every target file exists.

### E. Version and tag

18. **Version bump.** `DESCRIPTION`'s `Version:` field increments
    by one development counter per phase:
    `0.0.0.9000 → 9001 → 9002 → ...`. At Phase 7 release this
    becomes `0.1.0`. NEWS.md gains a heading for the new version.
19. **Single tidy commit on main** (or merged PR). Phase exit is
    one logical unit, not a stream of fixups.
20. **Git tag.** `git tag phase-N` so contributors can
    `git checkout phase-3` and get a working snapshot.
21. **CI green on main.** Nothing closes on a red branch.

### F. Optional from Phase 5 onward

22. **Deployed showcase refresh.** Build the Shinylive showcase and
    publish the generated static site artifact so the public-facing
    demo tracks `main`. Tag-aligned URLs (`/phase-3/`) optional.

## Phase Exit Process

Each phase exit is recorded as a checklist file under
`docs/phase-exits/`. At the start of the gate, copy
`docs/phase-exits/TEMPLATE.md` to `phase-N.md`. Tick items as they
pass. Commit when all green. The committed file is the audit trail —
future contributors can `git checkout phase-N` and see exactly what
was verified at that point in time.

This is more useful than a stale `make gate` log because it is:

- versioned alongside the code,
- interpretable months later,
- a forcing function for actually running each step rather than
  glossing over them.

## When Things Go Wrong

If a non-obvious problem surfaces during a phase, write a postmortem
under `docs/dev-notes/`. See
[`docs/dev-notes/README.md`](dev-notes/README.md) for when and how.
The strategy doc and ADRs are forward-looking; dev notes are
retrospective. Both have their place.

User-facing problems with known fixes go in
[`docs/troubleshooting.md`](troubleshooting.md), which ships as a
pkgdown article.

## Continuous Tracks

Two artifacts grow with every phase rather than being built once at
the end. Treat them as part of the work, not a doc pass after.

### A. pkgdown site

Modeled on <https://shiny.posit.co/r/components/>: a category-grouped
component reference where every component has a card on the index
page and a dedicated reference page with a live example and the
exact code that produced it.

- `_pkgdown.yml` defines reference categories: **Layout** (page,
  header, sidebar, body), **Navigation** (nav, nav_item, tabs),
  **Content** (card composition, value_box, badge, alert
  composition, separator, skeleton, spinner, empty), **Action**
  (button), **Forms** (field, field_group, field_label,
  field_description, field_set, field_legend, field_invalid,
  input_group, input_group_addon), **Theme** (theme,
  dark_mode_toggle, update_theme), **Icon**.
- Every exported function has a roxygen `@examples` block that
  pkgdown renders. Use `\dontrun{}` only when truly needed.
- Articles (`vignettes/`):
  `getting-started.Rmd`, `theming.Rmd`, `components.Rmd`,
  `coexistence.Rmd`, `accessibility.Rmd`.
- Per-component page layout: brief description → signature →
  embedded live preview (via `inst/www/shinyblocks.css` styling the
  rendered roxygen example) → copyable code block → parameter table
  generated from roxygen → "see also" listing related components
  via `@family`.
- The site rebuilds in CI. A failed build blocks the phase.

### B. Showcase app (dogfooded)

A Shiny app under `inst/showcase/` built with shinyblocks itself,
launchable via `shinyblocks::run_showcase()`.

- Sidebar nav with one entry per component category.
- Each component section is a `block_card` containing:
  1. A heading with the function name.
  2. A live rendered example.
  3. A `<pre><code>` block with the source for that example,
     read from a sibling `.R` file at runtime so the displayed code
     and the rendered example cannot drift apart.
- Light/dark mode toggle visible in the header at all times.
- Source organization:
  ```
  inst/showcase/
    app.R
    R/
      examples/
        button.R       # source of truth for "buttons" example
        card.R
        value-box.R
        ...
      render_example.R # reads file, runs it, renders + code block
  ```
- The app exercises every v0.1 component and is the visual
  acceptance test for each phase. If a component does not appear
  here with code, the phase is not done.
- The hosted showcase is exported with Shinylive from a clean staging
  directory, never from the repository root. The staged app copies
  only required showcase files, selected package R helpers, and
  `inst/www` assets. Until `shinyblocks` has a WebAssembly binary,
  the staged app uses `library(shiny)` and `library(htmltools)` and
  relies on Shiny's automatic `R/` sourcing instead of
  `library(shinyblocks)`.
- `shinyblocks_dependency()` supports both package mode
  (`package = "shinyblocks", src = "www"`) and Shinylive app-asset
  mode (`src = c(href = "shinyblocks")`, assets copied to
  `www/shinyblocks/`). The staged export sets an internal option
  such as `options(shinyblocks.asset_mode = "app")`; regular package
  users never set it.
- Shinylive output goes to `site/showcase/`. This avoids colliding
  with maintainer planning docs under `docs/` and leaves room to
  compose pkgdown output and the showcase into one static hosting
  artifact.

## Phase 0 — Decisions

Author the ADRs that pin down open decisions before any
implementation work begins. These are blocking; without them the
implementation drifts.

- `0006-styling-foundation.md` — formalize the dev-time Tailwind v4
  build that ships compiled CSS; document the build invocation, source
  layout under `inst/www/src/`, the `@theme` token mapping, the CI
  drift check, and the explicit non-use of CDN-loaded Tailwind.
- `0007-tabs-and-bootstrap.md` — `block_tabs()` as a styled wrapper
  around `shiny::tabsetPanel()`; rules for Bootstrap coexistence.
- `0008-icons-and-dark-mode.md` — Lucide subset selection; sprite
  generation; `data-theme` attribute; first-paint script for
  `prefers-color-scheme`.
- `0009-upstream-sync.md` — review cadence, sync log shape, deprecation
  policy for theme tokens.
- `0010-shinylive-showcase.md` — Shinylive showcase staging,
  asset-mode dependency resolution, webR package constraints, static
  site composition, and deployment policy.
- `0011-cran-ci.md` — CRAN-readiness GitHub Actions, workflow action
  version verification, routine cross-platform checks, and strict
  manual release checks.
- `0012-rename-to-shinyblocks.md` — project rename from
  `shinyshadcn` to `shinyblocks`, public API prefix change to
  `block_*`, and internal `sb-*` naming.

## Phase 1A — Asset Dependency and Static Shell

Goal: a minimal static dashboard shell that renders without JavaScript
and attaches package assets correctly.

- `R/deps.R`: `shinyblocks_dependency()`, `attach_shinyblocks_deps()`.
  Attaches the package CSS and, once present, JS/icons through
  `htmltools::htmlDependency()`. The dependency is a function, not a
  top-level object.
- `R/utils.R`: `merge_classes()` (R equivalent of `cn()`) and
  `validate_children()` (Group/Item contract enforcer). Both are
  used by every component from this phase forward.
- `R/page.R`: `block_page()`, `block_body()`.
- `R/header.R`: `block_header()`.
- `R/sidebar.R`: `block_sidebar()` static layout (no collapse yet).
- Keep CSS handwritten or minimally generated for this slice if that
  lets the shell ship cleanly. Tailwind source plumbing belongs to
  Phase 1B.

Tests: tag shape, semantic landmarks, single dependency attachment.

Exit criterion: a Shiny app using `block_page()` renders the shell
correctly with JS disabled, using only package assets in `inst/www/`.
`devtools::test()` and package check pass.

## Phase 1B — CSS Build Pipeline

Goal: dev-time Tailwind v4 build wired up without changing the public
R API from Phase 1A.

Build pipeline:

- `inst/www/src/tokens.css`: vendored shadcn oklch tokens (`:root`
  and `[data-theme="dark"]` blocks). Header comment pins the upstream
  commit synced from.
- `inst/www/src/shinyblocks.css`: `@import "tailwindcss"`, `@import
  "./tokens.css"`, `@theme` mapping shadcn tokens into Tailwind
  namespace, and the initial `@layer components` rules.
- `Makefile` target `build-css` and `package.json` script `build:css`:
  both invoke `npx @tailwindcss/cli --input inst/www/src/shinyblocks.css
  --output inst/www/shinyblocks.css --minify`.
- `package.json` gains `tailwindcss` and `@tailwindcss/cli` as
  `devDependencies`.
- CI step runs `make build-css` and fails on `git status` drift in
  `inst/www/shinyblocks.css`.
- `inst/www/shinyblocks.css` (compiled) is committed.

Exit criterion: generated CSS is reproducible, committed output has no
drift, and no Node tooling is required at package install time.

## Phase 1C — Package Infrastructure and Continuous Tracks

Goal: add the project infrastructure that is useful after the first
working shell exists.

- **pkgdown:** scaffold `_pkgdown.yml` with the seven reference
  categories. Build the site even if it only contains the shell
  components. CI builds it and fails on errors.
- **CRAN CI:** scaffold `.github/workflows/R-CMD-check.yaml` using
  latest verified workflow action majors. As of 2026-05-08, use
  `actions/checkout@v6` and `r-lib/actions/*@v2`
  (`setup-pandoc`, `setup-r`, `setup-r-dependencies`,
  `check-r-package`). The routine matrix checks Ubuntu R devel,
  Ubuntu R release, Ubuntu R oldrel-1, macOS R release, and Windows
  R release.
- **CRAN release gate:** scaffold
  `.github/workflows/cran-release-check.yaml` with
  `workflow_dispatch`. It runs strict release checks:
  `R CMD check --as-cran`, PDF manual generation with
  `r-lib/actions/setup-tinytex@v2`, URL checks, spell checks,
  pkgdown build, and, once available, Shinylive export smoke. It may
  also run on a weekly schedule against the default branch.
- **Showcase:** scaffold `inst/showcase/app.R` and the
  `render_example()` helper that reads a source file and renders
  the rendered output beside the code. Add a "Page shell" section
  showing `block_page()` usage.
- **Shinylive export:** scaffold `tools/export-shinylive.R` and a
  clean staging flow. The script copies only the files needed by the
  showcase into `.shinylive-stage/`, sets app-asset dependency mode,
  runs `shinylive::export()` to `site/showcase/`, and reports
  `site/showcase/app.json` size. Add `.shinylive-stage/` and
  generated `site/` output to ignore rules unless a deployment
  workflow explicitly uploads them as artifacts.
- **webR package availability:** before any package is used inside
  the staged Shinylive app, check the target r-wasm package index.
  If a dependency is unavailable, remove it from the Shinylive path
  or defer that showcase feature.

Quality-gate infrastructure (also Phase 1 — the gate becomes
blocking from Phase 2 onward, so its tooling has to exist now):

- `Makefile` targets — split into two tiers so the inner loop stays
  fast and the gate is reserved for phase exits:
  - **Inner loop (run constantly):** `setup` (one-time:
    `npm ci` and install R dev deps), `watch-css` (Tailwind
    `--watch`), `dev` (`devtools::load_all()` in a session),
    `showcase` (load_all + `shiny::runApp("inst/showcase")`),
    `check-fast` (lint + test + build-css; ~20 seconds).
  - **Phase exit:** `build-css`, `test`, `check`, `lint`, `spell`,
    `urls`, `docs`, `pkgdown`, `shinylive-export`, `budget`, `gate`
    (runs the full sequence A–E from the Quality Gate).
  - **CI:** `R-CMD-check.yaml` mirrors `make check` across the CRAN
    operating-system/R-version matrix; `cran-release-check.yaml`
    mirrors the strict release gate.
  - **Release-only:** `deploy-site` (publishes generated `site/`
    artifact to GitHub Pages, Cloudflare Pages, Netlify, or another
    static host).
- `tools/budget.R` — prints CSS/JS/sprite sizes against targets.
- `tools/check-doc-links.R` — greps `docs/**/*.md` for broken
  inter-doc markdown links.
- `inst/WORDLIST` — initial wordlist for `spell_check()`.
- `tests/testthat/setup.R` — shared test setup (e.g., snapshot
  helpers, dependency stubbing).
- `tests/testthat/test-showcase.R` — `shinytest2` smoke test
  scaffolded; grows as components land.
- `tests/testthat/test-shinylive-export.R` or equivalent browser
  smoke scaffold — long timeout, iframe-aware, desktop and mobile.
- `cran-comments.md` — initial template, even pre-CRAN; documents
  any deliberate notes.
- `.github/workflows/R-CMD-check.yaml` — routine cross-platform
  package checks on push/PR.
- `.github/workflows/cran-release-check.yaml` — manual strict
  CRAN-style release checks.
- `.github/workflows/ci.yml` — optional umbrella workflow if a
  separate `make gate` workflow is still useful after the CRAN
  workflows are in place.
- `Suggests:` in `DESCRIPTION` gains: `lintr`, `urlchecker`,
  `pkgdown`, `shinytest2`, `spelling`, `withr`, and other tools only
  when their corresponding checks are actually wired into CI. Do not
  add unused `Suggests`.

Exit criterion: the automated gate runs on CI, routine CRAN matrix
checks are green, the manual CRAN release workflow exists, pkgdown
builds, the showcase app runs locally, the Shinylive export succeeds
from a clean stage, and the repo still passes package check without
requiring unused suggested packages.

## Phase 2 — Icons and Static Components

- `R/icon.R`: `block_icon()` backed by `inst/www/icons/sprite.svg`.
- Vendor curated Lucide subset (~80 icons, ISC license, attribution
  in `inst/www/icons/LICENSE`).
- `R/button.R`: variants (`default`, `secondary`, `outline`, `ghost`,
  `destructive`, `link`); sizes (`default`, `sm`, `lg`, `icon`).
- `R/badge.R`: variants (`default`, `secondary`, `destructive`,
  `outline`).
- `R/alert.R`: variants (`default`, `destructive`); title and
  description slots.
- Tests: variant validation, ARIA attributes, icon sprite reference.
- pkgdown: reference pages added under **Action** (button) and
  **Content** (badge, alert), plus **Icon**.
- Showcase: gallery sections for icon, button, badge, alert with
  every variant rendered and the source visible.

## Phase 3 — Composite Components

- `R/card.R`: full composition primitives — `block_card()`,
  `block_card_header()`, `block_card_title()`,
  `block_card_description()`, `block_card_content()`,
  `block_card_footer()`. Flat-argument convenience form composes
  into the same primitives internally.
- `R/value-box.R`: `block_value_box()` with title, value,
  description, trend indicator, icon slots; trend uses
  `block_badge()`, not custom span.
- `R/separator.R`: `block_separator(orientation)` — replaces
  `<hr>` and border divs across the package and showcase.
- `R/skeleton.R`: `block_skeleton(width, height)` — loading
  placeholder; pairs with Shiny's pending state.
- `R/spinner.R`: `block_spinner(size)` — animated SVG spinner.
  Required by the button loading-state composition pattern (no
  `loading=` arg on `block_button()`); the spinner is what users
  pass as the button's `icon`.
- `R/empty.R`: `block_empty(title, description, icon)` — empty
  states for dashboards.
- Tests: composition validation (children-class checks), slot
  composition, optional argument handling, separator orientation.
- pkgdown: reference pages under **Content** (card, value box,
  badge, separator, skeleton, empty); composition primitives appear
  with `@family` cross-links.
- Showcase: gallery sections for each, including a multi-card grid
  demonstrating composition and a "no data" example using
  `block_empty()`.

## Phase 4 — Navigation and Behavior

- `R/sidebar.R`: collapse/expand, mobile sheet open/close, keyboard
  navigation. JS module under `inst/www/shinyblocks.js`.
- `R/nav.R`: `block_nav()`, `block_nav_item()` with selected state.
- Tests: state attributes, keyboard handler smoke tests via headless
  browser if feasible (else deferred to Phase 7).
- pkgdown: reference pages under **Navigation**; the `theming`
  article gains a sidebar example.
- Showcase: convert the showcase's own sidebar to use `block_nav()`
  with selected state. Gallery section demonstrates collapse and
  mobile sheet behavior.

## Phase 5 — Tabs, Forms, and Theme Runtime

- `R/tabs.R`: `block_tabs()` + `block_tab()` wrap
  `shiny::tabsetPanel()` and use additive decoration only. Preserve
  `ul.nav.shiny-tab-input`, `.nav-link`, `data-bs-toggle`, and
  `data-value` so Shiny's tab input binding and Bootstrap tab JS keep
  working. Add roles/ARIA and `sb-tabs` classes; do not emit
  Radix-style replacement markup. Add `bslib` to `Imports` in this
  phase if `block_tabs()` depends on Shiny's bslib-backed tabset
  implementation.
- `R/field.R`: `block_field()`, `block_field_group()`,
  `block_field_label()`, `block_field_description()`,
  `block_field_set()`, `block_field_legend()`,
  `block_field_invalid()`. Wrap Shiny inputs in sb-styled field
  markup. Validation states emit `data-invalid` on the field and
  `aria-invalid` on the underlying control.
- `R/input-group.R`: `block_input_group()`,
  `block_input_group_addon()`. Prefixed/suffixed input layout for
  search bars, currency inputs, and inline-button inputs. Wraps a
  Shiny input.
- `R/theme.R`: `block_theme()` accepts named token overrides and
  emits a scoped `<style>` block. `update_block_theme()` for
  server-side updates via `session$sendCustomMessage`.
- `R/dark-mode.R`: `block_dark_mode_toggle()` button; toggle JS
  module reads/writes `data-theme` on `<html>`. First-paint inline
  script in `block_page()` head reads `prefers-color-scheme`.
- Tests: token override emission, dark-mode attribute toggling,
  no flash-of-wrong-theme on initial render.
- pkgdown: reference pages under **Navigation** (tabs), **Forms**
  (field family), and **Theme**; the `theming` article documents
  the full token list, `block_theme()` overrides, and dark-mode
  behavior; a new `forms` article shows `block_field()` wrapping
  Shiny inputs with validation states.
- Showcase: tabs section; forms section showing every field
  primitive with valid/invalid/disabled states; theme controls in
  the showcase header let visitors flip dark mode and override
  tokens live.

## Phase 6 — Documentation Polish

By this phase the pkgdown site and showcase app already exist and
have grown alongside each component. This phase is about polish, not
construction.

- `inst/templates/starter/`: a minimal one-file starter app distinct
  from the showcase — copy-paste ready for users beginning a project.
- Vignettes finalized: `getting-started.Rmd`, `theming.Rmd`,
  `components.Rmd`, `coexistence.Rmd`, `accessibility.Rmd`.
- pkgdown reference: every page has a thumbnail (rendered from the
  showcase example); category landing pages match the
  shiny.posit.co/r/components grid layout.
- Showcase: review every gallery section for clarity; ensure each
  example is the smallest useful demonstration; copy-to-clipboard
  buttons on every code block.
- `docs/upstream/sb-sync.md` initial entry: shadcn commit reviewed,
  tokens copied, components mirrored.
- README on the package homepage links to the pkgdown site, the
  hosted Shinylive showcase, and the local `run_showcase()` entry
  point. The showcase link warns that first visit can take 1-2
  minutes while webR and package binaries download and cache.

## Local Preview Before Going Public

Before making the repository public, build and review the full
presentation locally. This is a visual sanity check, not a formal
phase exit — it does not require the full Quality Gate.

1. **pkgdown site.** Run `pkgdown::build_site()` (or `make pkgdown`)
   and open `site/docs/index.html` in a browser. Walk the reference
   index, every component page, and each article. Verify live examples
   render correctly and the layout looks polished.
2. **Shinylive showcase.** Run `make shinylive-export` (or
   `tools/export-shinylive.R`) to produce the static export under
   `site/showcase/`. Serve locally
   (`python3 -m http.server -d site/showcase`) and verify in a browser
   that the app loads, dark mode works, and every gallery section
   renders.
3. **Local showcase app.** Run `shinyblocks::run_showcase()` to launch
   the dogfooded gallery. Confirm every component section is present
   with both the live render and the source code.
4. **README & package metadata.** Review `README.md`, `DESCRIPTION`,
   and `NEWS.md` for anything that looks incomplete or references
   internal-only artifacts.

Only make the repo public once all four pass.

## Phase 7 — Hardening and Release

- Full critical code review across the package using the
  `critical-code-reviewer` skill; address every Blocking and
  Required item.
- Accessibility pass against shadcn's documented ARIA contracts;
  manual screen-reader smoke test on the showcase app.
- Cross-browser check: Chromium, Firefox, Safari latest.
- `R CMD check --as-cran` clean, including manual/PDF checks with a
  TeX toolchain available.
- Manual `cran-release-check.yaml` run green on the release commit.
- pkgdown site and Shinylive showcase deployed as one static site
  artifact (for example pkgdown at `/` and the showcase at
  `/showcase/`) and linked from the README. If the repository remains
  private and GitHub Pages is unavailable, deploy the same artifact
  to Cloudflare Pages, Netlify, or another static host.
- NEWS.md written in user-facing voice.
- Tag v0.1.0.
- (Optional) CRAN submission.

## Post-v0.1 Candidates (for separate ADRs)

Listed for context only. Each requires its own ADR before work starts:

- Popover, tooltip, dropdown menu (Floating UI vendored, ~5 KB gzip).
- Dialog, sheet, drawer (focus traps, scroll lock).
- Toast/sonner notifications.
- Combobox and command palette.
- Form validation primitives integrating with Shiny inputs.
- Calendar and date picker.
- Data table with sorting, filtering, virtualization.
- Visual regression testing harness.
- Component-level Tailwind variants (e.g., `data-state` selectors)
  beyond the v0.1 baseline.

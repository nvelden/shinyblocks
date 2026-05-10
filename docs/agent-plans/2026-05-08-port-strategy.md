# Port Strategy for shinyblocks

Status: canonical strategy as of 2026-05-08. Replaces earlier brainstorming.

## Goal

Build `shinyblocks` as an R-first Shiny dashboard package whose authoring
ergonomics resemble `shinydashboard` and whose visual and interaction model
is faithful to shadcn/ui. End users install the package from CRAN like any
other R package; they never need Node, npm, Tailwind, Vite, or React.

The package is a **port of the design system**, not a port of the
implementation. shadcn/ui is React/Tailwind/Radix; Shiny is server-rendered
HTML plus reactive bindings. The connective tissue is the shadcn token set
and component contracts, both of which are framework-agnostic.

## Repository Policy

The public GitHub repository is package-facing. It should contain the R
package source, package assets, generated Rd files, tests, README, NEWS,
license, contribution guide, and any user-facing package docs that are ready
to maintain publicly.

Long-form strategy docs, agent instructions, scratch plans, and exploratory
tooling can remain in the maintainer workspace until intentionally promoted.
This keeps the user-facing package repository clean while still allowing a
high-detail planning workspace. When a planning artifact becomes part of the
public workflow (for example CI, pkgdown configuration, or a release checklist),
unignore it deliberately and commit it with the implementation it supports.

## Non-Goals

- Full shadcn/ui component parity in v0.1.
- Re-rendering Shiny apps through React.
- A drag-and-drop layout builder or visual theme editor.
- A Node/Tailwind build step required of package users.
- Replacing `shiny::tabsetPanel`, `shiny::actionButton`, or other Shiny
  input primitives where wrapping them yields the same UX.

## Version Verification Policy

Anything with a version must be checked against the latest authoritative
source before it shapes a planning or implementation decision. Do not
assume the current version of an R package, npm package, JS library,
documentation page, CLI, hosted service, browser API, shadcn/ui
component contract, Tailwind feature, Shinylive behavior, Shiny/htmltools
behavior, or webR/r-wasm package from memory.

The required check depends on the source:

- R packages: CRAN, BioConductor, r-universe, GitHub releases, or the
  r-wasm package index when the code runs in Shinylive.
- JS tools and libraries: npm metadata, upstream release tags, and
  official docs.
- shadcn/ui and Tailwind: upstream docs plus the exact reviewed commit
  or release.
- Shiny, htmltools, bslib, and Shinylive behavior: official package
  docs, source, or current release notes.
- Deployment tools: official provider docs for current behavior,
  limits, and private-repository constraints.
- GitHub Actions: upstream action repositories or Marketplace pages
  for the current major versions of workflow actions before adding or
  changing workflow files.

Record the source, date, and version checked in the relevant ADR,
`docs/upstream/sb-sync.md`, roadmap note, or phase-exit file. If
the latest version changes the decision, update the plan before coding.

Verified workflow action versions on 2026-05-08:

- `actions/checkout@v6`;
- `r-lib/actions/setup-r@v2`;
- `r-lib/actions/setup-r-dependencies@v2`;
- `r-lib/actions/setup-pandoc@v2`;
- `r-lib/actions/setup-tinytex@v2`;
- `r-lib/actions/check-r-package@v2`.

---

## Strategy Comparison

Four credible architectures were evaluated. Each is summarized with concrete
pros and cons before stating the chosen path.

### Strategy A — htmltools + handwritten CSS, no framework

R helpers return `htmltools::tag` objects. Assets are plain CSS and small
JS modules under `inst/www/`, attached via `htmltools::htmlDependency()`.
shadcn tokens are vendored verbatim as CSS custom properties.

- Pros
  - Zero runtime dependencies beyond `htmltools` and `shiny`.
  - shadcn's 2026 token set is pure CSS custom properties (oklch); copying
    them lossless is a one-file operation.
  - Smallest possible install footprint and fastest cold render.
  - Full control over markup, ARIA, and class names.
  - Maps cleanly onto shinydashboard's proven asset attachment pattern.
- Cons
  - Complex headless behavior (popover positioning, focus traps,
    combobox keyboard model) must be implemented in plain JS or borrowed
    piecemeal. Floating UI's vanilla build helps but is not Radix.
  - Wide component coverage is slow; the long tail of shadcn (command,
    calendar, sheet, drawer) requires real work each time.

### Strategy B — bslib overlay, shadcn tokens on top of Bootstrap

`bslib` provides theming, responsive grid, and base components; a
sb-flavored layer overlays its CSS variables and restyles selectively.

- Pros
  - Inherits a hardened Bootstrap baseline, runtime theme switching via
    `session$setCurrentTheme()`, and Sass compilation through `sass`.
  - `bslib::page_sidebar()`, `card()`, `value_box()` are already close in
    spirit; restyling them costs less than rebuilding.
- Cons
  - bslib is **Sass-variable centric**; shadcn is **CSS-custom-property
    centric**. The two theming surfaces do not map cleanly. Emitting
    shadcn's `--card`/`--card-foreground` token pairs through bslib means
    constantly bypassing its DSL.
  - shadcn's visual language fights Bootstrap's — typography scale,
    button density, focus rings, radius, form-control look. Restyling
    Bootstrap to look like shadcn ends up rewriting most of Bootstrap.
  - Locked to Bootstrap 5's class soup in generated markup, which leaks
    into user code via class names and selectors.
  - Verdict: wrong tool. bslib is excellent for Bootstrap-flavored apps,
    not for pretending Bootstrap is shadcn.

### Strategy C — `shiny.react` + reactR with pre-bundled JS

Use the actual shadcn React components, wrap each in R via `shiny.react`,
ship a pre-built JS bundle in `inst/www/` so end users never need Node.

- Pros
  - Maximum visual and behavioral fidelity to shadcn upstream.
  - Real Radix accessibility (focus traps, roving tabindex, Floating UI)
    inherited for free.
  - Adopting upstream changes can be partially mechanical.
- Cons
  - Ships a React runtime in every app (~150 KB gzip baseline before any
    components). Conflicts with Shiny's lightweight default model.
  - Every component needs an R wrapper, prop-marshalling, and a Shiny
    input/output binding where reactivity matters. This is per-component,
    not write-once.
  - Maintainers must run a Node + Vite/webpack pipeline. Appsilon's
    `shiny.fluent` proves it works, but `shiny.fluent` has a team. The
    one prior sb-for-Shiny attempt (`MohoWu/shiny.shadcn`, reactR +
    Tailwind + webpack) was abandoned at two components.
  - Composition with vanilla Shiny inputs becomes awkward in places that
    cross the React boundary.
  - Verdict: defensible for a funded team; unsustainable for a solo
    maintainer aiming at CRAN.

### Strategy D — htmltools + dev-time pipeline, runtime is plain CSS

Same R-facing surface as Strategy A. Internally, the package may use a
**developer-side** Tailwind v4 or Sass step to generate a small CSS bundle
that gets committed to `inst/www/` and shipped on CRAN. End users see only
plain CSS. This is exactly how `bslib` ships compiled Bootstrap and how
`bs4Dash` ships compiled AdminLTE.

- Pros
  - All of Strategy A's runtime properties (zero deps, fast install).
  - Authors can use shadcn's actual class names during development if
    they want, and let Tailwind v4 emit only the utilities used.
  - Enables a faithful aesthetic match without locking users into any
    build tooling.
- Cons
  - Adds a `package.json` and a Node toolchain for *maintainers* (the
    repo already has one for the shadcn agent context, so this is small).
  - Two sources of truth (R source + generated CSS) need a clean
    regeneration ritual and a CI check that the committed CSS matches
    what the source would produce.

---

## Chosen Strategy

**Strategy D — dev-time Tailwind v4 build, plain CSS at ship time.**
This matches the precedent set by `bslib` (ships compiled Bootstrap
from Sass source) and `bs4Dash` (ships pre-compiled AdminLTE). End
users get a single plain CSS file in `inst/www/`; only package
maintainers need Node.

Concretely for v0.1:

- All R helpers return `htmltools::tag` objects.
- Component styles authored in `inst/www/src/shinyblocks.css` using
  Tailwind v4 directives (`@theme`, `@layer`, `@apply`, arbitrary
  values) and shadcn's actual class patterns where useful.
- A `make build-css` step (or `npm run build:css`) invokes
  `npx @tailwindcss/cli` to compile the source into
  `inst/www/shinyblocks.css`. The compiled file is **committed to
  git** and shipped on CRAN.
- shadcn's oklch token set is registered through `@theme` and emitted
  as CSS custom properties in the compiled output. A header comment
  in the source file pins the upstream commit it was synced from.
- Behavior JS lives in `inst/www/shinyblocks.js` as small ES modules,
  attached through `htmltools::htmlDependency()` alongside the CSS.
- No bslib at the public R API level for the shell and static
  components. When `block_tabs()` lands, `bslib` should be listed in
  `Imports` because `shiny::tabsetPanel()` delegates to
  `bslib::buildTabset()`. Reimplementing the tab input binding to avoid
  that dependency is not worth the maintenance cost.
- No React. No Node at user install time.
- No CDN at runtime. Tailwind never executes in the user's browser.

---

## Shiny Integration Notes (Validated 2026-05-08)

The package depends on specific behaviors of `shiny` and `htmltools`.
These were validated against `rstudio/shiny` `main` and pinned here so
later refactors don't break silent contracts.

### Bootstrap is not auto-attached by inputs

`bootstrapDependency()` and `bootstrapLib()` are called by
`bootstrapPage()` / `fluidPage()` / `fillPage()` / `navbarPage()`, not
by individual inputs. `shiny::textInput()`, `selectInput()`,
`actionButton()` emit Bootstrap-flavored classes but do not call
`attachDependencies()`. This means **`block_page()` will render bare
without Bootstrap** — exactly the desired behavior. (`selectInput(..., 
selectize = TRUE)` does pull in selectize.js; document `selectize = FALSE`
in coexistence guidance if pure shadcn styling is wanted.)

### `tabsetPanel` delegates to bslib internally

`shiny::tabsetPanel()` no longer builds HTML directly — since Shiny
1.7 it dispatches to `bslib::buildTabset()`. This means:

- The package has a **bslib dependency at runtime** whenever tabs are
  used. Add `bslib` to `Imports` in the same phase that implements
  `block_tabs()`.
- Modern Shiny versions ship bslib by default, so this is acceptable.
- The stable policy is: no bslib at the public R API level for shell
  and static components; import bslib when tabs are implemented,
  because reimplementing the tab input binding is not worth the
  maintenance cost.

### Tab markup is structurally fixed

`BootstrapTabInputBinding` (Shiny's tab input binding, in compiled
`inst/www/shared/shiny.js`) targets specific selectors:

- Find: `ul.nav.shiny-tab-input` — must remain a `<ul>`, must keep
  the classes.
- Active value: `.nav-link.active`'s `data-value` — anchors must
  keep `class="nav-link"`, `data-bs-toggle="tab"`, `data-value=...`.
- Subscribe: `shown.bs.tab` events fired by Bootstrap's own tab JS.

**Tabs contract:** `block_tabs()` uses **additive decoration only**:

- Wrap `shiny::tabsetPanel()` and post-process the returned tag with
  `htmltools::tagQuery()`.
- Add `sb-tabs` to the wrapper, `role="tablist"` and ARIA
  attributes to the `<ul>`, `role="tab"` to each `<a.nav-link>`.
- Style via `.sb-tabs .nav-link.active` (Bootstrap toggles
  `.active`; we don't need our own `data-state`).
- Do **not** strip `shiny-tab-input`, `data-bs-toggle="tab"`, or
  `data-value`. Do **not** swap the `<ul>` for a `<div>`.

Recorded in `0007-tabs-and-bootstrap.md` so this constraint is
discoverable.

### `tagAppendAttributes()` does not dedupe classes

`htmltools::tagAppendAttributes(tag, class = "foo")` called twice
produces `class="foo foo"` because the implementation appends, it
does not deduplicate. **All package code uses `htmltools::tagQuery()`
for class manipulation**, never `tagAppendAttributes()` for classes.
The internal `merge_classes()` helper deduplicates input strings;
combine it with `tagQuery()$addClass()` for tag-level operations.

### `htmlDependency()` must be a function, not a top-level binding

A common pitfall (documented in `htmltools/R/html_dependency.R`): if
a package binds `dep <- htmlDependency(...)` at top level, the path
is baked in at install time, which breaks binary distributions and
across machines. **Always wrap `htmlDependency()` in a function**:

```r
shinyblocks_dependency <- function() {
  htmltools::htmlDependency(
    name = "shinyblocks",
    version = utils::packageVersion("shinyblocks"),
    src = "www",
    package = "shinyblocks",
    stylesheet = "shinyblocks.css",
    script = "shinyblocks.js",
    attachment = c(sprite = "icons/sprite.svg")
  )
}
```

Shiny's HTTP handler serves `inst/www/` of any package automatically
when `package = "shinyblocks"` is set. Dedup happens via
`htmltools::resolveDependencies()` keyed by `name`; nested calls
attach the dependency at most once.

### Inline `<head>` scripts are preserved

`tags$script(HTML("..."))` in `tags$head()` is preserved verbatim
through `htmltools::normalizeText()`. The dark-mode first-paint
script will run synchronously on parse, before stylesheets load —
ensuring no flash of wrong theme.

### Wrapping Shiny inputs in `block_field()`

`shiny::textInput()` returns:

```html
<div class="form-group shiny-input-container" style="...">
  <label class="control-label" id="ID-label" for="ID">...</label>
  <input id="ID" type="text" class="shiny-input-text form-control" ...>
</div>
```

When `label = NULL`, Shiny still emits an empty
`<label class="control-label shiny-label-null">` for
`aria-labelledby` purposes. Two strategies are acceptable:

- **(preferred)** Pass `label = NULL` and let `block_field_label()`
  emit the visible label *outside* the Shiny input. The empty
  `shiny-label-null` is hidden via CSS `.shiny-label-null { display: none }`.
- **(alternative)** Use `tagQuery(input)$find(".shiny-label-null")$remove()`
  to strip it.

The package uses the first strategy. **The `<input>`'s `id` is never
modified** — Shiny's input bindings key off it.

### Custom input bindings (v0.2)

Pattern for v0.2 components needing a Shiny input (e.g.
ToggleGroup): subclass `Shiny.InputBinding`, register via
`Shiny.inputBindings.register(binding, "shinyblocks.toggleGroup")`,
ship the JS through `htmlDependency(script = ...)`. htmltools places
dependency scripts after `shiny.js`, so `Shiny` is defined when the
binding file runs.

### `session$sendCustomMessage` for theme updates

`update_block_theme()` uses `session$sendCustomMessage("sb:theme",
list(mode = mode))`. The handler is registered top-level in
`shinyblocks.js` via `Shiny.addCustomMessageHandler("sb:theme",
fn)`. Registering top-level (not in `DOMContentLoaded`) ensures the
handler is in place before the WebSocket opens.

## Upstream Reference

shadcn/ui has multiple style and base variants. Pinning them makes
the upstream sync log reproducible.

- **Style:** `new-york`. (The default since the v4 migration.)
- **Base:** `radix`. The Radix variant is the source of truth for
  accessibility behavior — focus traps, roving tabindex, Floating UI
  positioning. v0.2 overlays must match Radix's contract, not the
  lighter `base` variant.
- **Icon library:** `lucide` (ISC).
- **Tailwind version:** `v4`.

These values mirror the maintainer-local `components.json` used for
shadcn CLI/tooling context. If that file is not part of a public
checkout, `docs/upstream/sb-sync.md` is the public source of truth.

## Architecture (Three Layers)

The package is structured as three layers with explicit stability
contracts. Decoupling these is the single most important architectural
decision because shadcn upstream evolves quickly.

1. **Public R API** — `block_page()`, `block_card()`, `block_button()`,
   etc. Stable. Changes only with deprecation paths.
2. **Internal HTML/CSS/JS** — generated markup, package classes
   (`sb-*`), CSS custom properties, JS modules. Internal. May change
   with any release.
3. **Upstream design reference** — shadcn/ui, reviewed periodically.
   Adopted selectively into layer 2. Never copied as React source into
   the package.

---

## Naming Decisions (Resolved)

- **Function prefix:** `block_*` for exported functions. Snake_case is
  R-idiomatic; `block_` makes the design lineage discoverable in
  autocomplete.
- **CSS class prefix:** `sb-` for all package-emitted classes. Short
  enough to not bloat markup, distinct enough to avoid Bootstrap and
  bslib collisions.
- **Data attributes:** mirror Radix conventions where useful
  (`data-state="open"`, `data-side="bottom"`). This is the cheapest way
  to track upstream behavioral conventions.
- **No `dashboard_*` aliases** in v0.1. The package is not a drop-in
  shinydashboard replacement; pretending it is creates support debt.

---

## CSS Build Pipeline

The pipeline is invisible to end users. The compiled artifact in
`inst/www/shinyblocks.css` is the authoritative thing the package
ships, just like `bslib` ships Bootstrap CSS compiled from its Sass
sources.

**Source layout:**

```
inst/www/
  src/
    shinyblocks.css      # @theme, @layer, @apply — Tailwind v4 source
    tokens.css           # vendored shadcn oklch tokens, imported by source
  shinyblocks.css        # COMPILED OUTPUT, committed to git
  shinyblocks.js
  icons/
    sprite.svg
```

**Source file shape:**

```css
@import "tailwindcss";
@import "./tokens.css";

@theme {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-card: var(--card);
  /* ... maps shadcn tokens to Tailwind theme namespace */
  --radius-default: var(--radius);
}

@layer components {
  .sb-card {
    @apply bg-card text-card-foreground rounded-lg border p-6 shadow-sm;
  }
  .sb-card-header { @apply flex flex-col gap-1.5 pb-4; }
  /* ... */
}
```

**Build invocation:**

```bash
npx @tailwindcss/cli \
  --input inst/www/src/shinyblocks.css \
  --output inst/www/shinyblocks.css \
  --minify
```

Wired up two ways:

- `Makefile` target `build-css` (preferred, no JS knowledge required to run).
- `package.json` script `"build:css"` for contributors who prefer npm.

Both invoke the same command. The `package.json` used for this build
may start maintainer-local; promote it into the public repository when
the reproducible CSS build is ready for contributors and CI.
Nothing in `DESCRIPTION` changes — Node is a maintainer tool, not a
package dependency.

**Reproducibility check:** a CI step runs `make build-css` and fails
if `git status` reports drift in `inst/www/shinyblocks.css`. This
prevents the source and the shipped CSS from diverging.

**Class scoping:** Tailwind compiles only utilities used in
`inst/www/src/**/*.css` — utilities are referenced through `@apply`
inside our own component layer, never sprinkled into user markup. The
compiled file is budgeted on compressed delivery size rather than raw
minified bytes: ≤10 KB gzipped for CSS, which reflects how the asset is
actually shipped to browsers.

**What end users see:** one `<link rel="stylesheet">` tag pointing at
the compiled file, attached automatically by
`shinyblocks_dependency()`. No Node. No CDN. No build at install time.

## Component API Conventions

These rules translate shadcn/ui's composition contracts into idiomatic
R. They apply to every exported component. Most are derived from the
`shadcn` skill's critical rules, restated here in `htmltools` terms.

### Full composition over flat arguments

shadcn components expose every region as its own primitive. The R API
mirrors this for any component with internal structure:

```r
block_card(
  block_card_header(
    block_card_title("Revenue"),
    block_card_description("Last 30 days")
  ),
  block_card_content(plotOutput("chart")),
  block_card_footer(block_button("View report"))
)
```

A flat-argument convenience form is allowed, but it composes into the
same primitives internally, never into a different markup shape:

```r
block_card(
  title = "Revenue",
  description = "Last 30 days",
  plotOutput("chart"),
  footer = block_button("View report")
)
```

This applies to `block_card`, `block_alert`, `block_field`, and any
v0.2 component with header/title/description/content/footer regions.

### Group/Item validation

shadcn enforces that items live inside their group: `SelectItem` →
`SelectGroup`, `TabsTrigger` → `TabsList`, `DropdownMenuItem` →
`DropdownMenuGroup`. The R API validates this at call time:

```r
block_nav(
  block_nav_item("Home", tabName = "home"),
  block_nav_item("Reports", tabName = "reports")
)
```

`block_nav()` calls a `validate_children()` helper that fails fast
with a clear R error if children are not all `block_nav_item` tags
(detected via `class = "sb-nav-item"`).

### Class-merging contract

Every exported component accepts `class = NULL`. The R-side helper
`merge_classes()` (in `R/utils.R`) deduplicates and joins package
classes with user-supplied classes. This is the R equivalent of
shadcn's `cn()` utility:

```r
block_card(class = "bg-muted")  # merges with "sb-card"
```

Components must never let user `class` overwrite required package
classes — only append.

### Icon integration

Icons inside components use `data-icon` attributes, not size classes:

```r
block_button("Search", icon = block_icon("search"))
# emits: <svg data-icon="inline-start" ...>...</svg>
```

`block_icon()` itself never emits `size-*` classes. Per-component
CSS rules size icons. `icon_position = "end"` flips to
`data-icon="inline-end"`.

**Deliberate divergence from shadcn upstream:** the skill's rule
"pass icons as objects, not string keys" applies to TypeScript where
icon symbols are imported. R has no equivalent of TS imports, so
`block_icon()` takes a string name validated against the vendored
sprite. As a fallback, `block_icon()` also accepts an
`htmltools::tag` directly, which lets users drop in custom SVGs
without forcing them into the package sprite.

### Loading state via composition, not a flag

`block_button()` has no `loading=` or `pending=` argument. shadcn
upstream is explicit on this point and shinyblocks matches it. To
render a button in a loading state, compose with `block_spinner()`:

```r
block_button(
  "Save",
  icon = block_spinner(),
  disabled = TRUE
)
```

The spinner gets `data-icon="inline-start"` automatically because the
button treats it as any other icon. This keeps the button API minimal
and prevents bespoke loading patterns from drifting away from shadcn.

### Overlay triggers accept any tag (v0.2 standing rule)

shadcn's `asChild` (Radix) and `render` (Base) props let any element
become the trigger of a `Dialog`, `DropdownMenu`, `Tooltip`, etc.
This pattern doesn't translate cleanly to R because htmltools has no
JSX child-cloning. The R equivalent for v0.2:

- The first positional argument of an overlay (`block_dialog()`,
  `block_dropdown_menu()`, etc.) is the trigger, accepting any
  htmltools tag.
- The wrapper attaches event handlers via
  `htmltools::tagAppendAttributes()`.
- No `asChild =` argument is exposed.

This is recorded here so v0.2 ADRs don't relitigate it.

### Required accessibility arguments

Components that demand a label or title for screen readers take it as
a *required* argument. `block_alert(title = ...)` errors if
omitted. Future overlays (`block_dialog`, `block_sheet`,
`block_drawer`) will require `title` as a non-default argument; a
`title_visible = FALSE` option emits the title with `class = "sr-only"`
for visually hidden but screen-reader-available text.

### Field layout (Shiny input wrapping)

Form layout follows shadcn's `FieldGroup`/`Field` model. shinyblocks
does not replace `shiny::textInput()` etc.; it wraps them in
`block_field()` markup so labels, descriptions, and validation
states match shadcn's visual contract.

```r
block_field_group(
  block_field(
    block_field_label("Email", `for` = "email"),
    shiny::textInput("email", NULL),
    block_field_description("We won't share it.")
  ),
  block_field(
    block_field_label("Plan", `for` = "plan"),
    shiny::selectInput("plan", NULL, choices = c("Free", "Pro"))
  )
)
```

Validation states use `data-invalid` on `block_field()` and
`aria-invalid` on the underlying input. A helper
`block_field_invalid(field, message)` flips both attributes and
attaches an error description.

### Use components, not custom markup

The showcase app and internal markup must use:

- `block_separator()` instead of `<hr>` or border divs.
- `block_skeleton()` for loading placeholders, not `animate-pulse` divs.
- `block_empty()` for empty states, not custom centered divs.
- `block_badge()` for status pills and trend markers, not styled spans.
- `block_alert()` for callouts.

This is enforced as a code-review rule, not a runtime check.

## Token System

shadcn's 2026 token set ships in oklch and is fully portable. Vendor it
unchanged into `inst/www/src/tokens.css` (imported by the build source):

```css
:root {
  --radius: 0.625rem;
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
  --card: oklch(1 0 0);
  --card-foreground: oklch(0.145 0 0);
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.145 0 0);
  --primary: oklch(0.205 0 0);
  --primary-foreground: oklch(0.985 0 0);
  --secondary: oklch(0.97 0 0);
  --secondary-foreground: oklch(0.205 0 0);
  --muted: oklch(0.97 0 0);
  --muted-foreground: oklch(0.556 0 0);
  --accent: oklch(0.97 0 0);
  --accent-foreground: oklch(0.205 0 0);
  --destructive: oklch(0.577 0.245 27.325);
  --border: oklch(0.922 0 0);
  --input: oklch(0.922 0 0);
  --ring: oklch(0.708 0 0);
  --sidebar: oklch(0.985 0 0);
  --sidebar-foreground: oklch(0.145 0 0);
  --sidebar-primary: oklch(0.205 0 0);
  --sidebar-primary-foreground: oklch(0.985 0 0);
  --sidebar-accent: oklch(0.97 0 0);
  --sidebar-accent-foreground: oklch(0.205 0 0);
  --sidebar-border: oklch(0.922 0 0);
  --sidebar-ring: oklch(0.708 0 0);
  --chart-1: ...;
  /* through --chart-5 */
}
[data-theme="dark"] { /* inverted oklch values, also vendored */ }
```

Token names are the public theming contract. Renaming or removing a
token is a major-release change. Adding tokens is a minor-release change.

The R-side `block_theme()` helper takes named overrides and emits a
`<style>` block of CSS custom-property assignments scoped to the page
root. No Sass compilation needed.

```r
block_theme(primary = "oklch(0.55 0.22 260)", radius = "0.5rem")
```

---

## Dark Mode

Setting `data-theme="dark"` on `<html>` is the shadcn convention,
but Shiny's page template only allows controlling `<head>` and
`<body>` — there is no public hook to set arbitrary attributes on
`<html>` (`R/shinyui.R::renderPage()` reads only `lang`).

The package therefore uses the standard web pattern: a tiny
**inline script in `<head>`** that sets
`document.documentElement.dataset.theme` *before* the stylesheet
links load. The script runs synchronously on parse, so the dark
token block is already applied by first paint — no flash of wrong
theme. CSS selectors `[data-theme="dark"] { ... }` then resolve at
the `<html>` level exactly as shadcn upstream expects.

Behavior:

- Inline head script reads `localStorage.getItem('sb-theme')` if
  present, else falls back to `prefers-color-scheme`.
- `block_dark_mode_toggle()` exports a small button that flips the
  attribute on `document.documentElement` and writes the choice to
  `localStorage` so it persists across reloads.
- `update_block_theme(session, mode = "dark")` sends a custom
  message handled in `shinyblocks.js`; the handler sets the
  attribute and updates `localStorage`.

---

## Icons

- Vendor a curated **Lucide** subset (ISC license) under
  `inst/www/icons/`. Target ~80 icons for v0.1, picked from typical
  dashboard needs (chevrons, arrows, search, settings, user, menu,
  status indicators, common file types).
- Combine into a single SVG sprite at build time, referenced by
  `<svg><use href="..."/></svg>` for cheap reuse.
- Export `block_icon(name, size = "1rem", class = NULL)`.
- Fallback: if `name` is not in the vendored set, attempt
  `shiny::icon(name)` so users can mix in Font Awesome icons that
  Shiny already ships. Document this is a fallback, not a recommended
  path.

Sprite size budget: ≤60 KB unminified, ≤25 KB gzipped.

---

## Bootstrap Coexistence

Shiny ships Bootstrap by default. shadcn assumes no Bootstrap. Strategy:

1. shinyblocks does not load Bootstrap itself.
2. If Shiny has already loaded Bootstrap, shinyblocks's CSS is loaded
   *after* and uses higher-specificity selectors scoped under
   `.sb-app` (the class on `block_page()`'s root).
3. For form controls and buttons inside shinyblocks components,
   shinyblocks provides explicit overrides; mixing Bootstrap-styled
   inputs with shinyblocks cards is supported but visually mixed by
   design — users should pick a lane.
4. A `vignette("coexistence")` documents what happens when bslib,
   shinydashboard, or bs4Dash are loaded in the same app: not
   supported, will look broken, and that is expected.

---

## JavaScript Strategy

Vanilla ES modules under `inst/www/shinyblocks.js`, organized one
module per behavior. No bundler in v0.1; modern browsers handle ESM
natively and Shiny's asset loader is fine with it.

Behaviors needed for v0.1:

- Sidebar: collapse/expand, keyboard nav, mobile sheet open/close.
- Tabs: keyboard navigation if not delegating to `shiny::tabsetPanel`.
- Dark-mode toggle: read/write `data-theme`.
- Disclosure (accordion-style sections inside cards).

Dependencies:

- Floating UI (vanilla build) for popover/tooltip positioning when
  those components arrive in v0.2. ~5 KB gzipped, MIT, vendored.

No external npm runtime. If a behavior is genuinely too complex for
hand-written JS (combobox, command palette), defer the component until
its complexity is justified rather than reaching for React.

---

## v0.1 Scope

**In scope:**

- Shell: `block_page()`, `block_header()`, `block_sidebar()`,
  `block_body()`.
- Navigation: `block_nav()`, `block_nav_item()` with selection state.
- Card composition: `block_card()`, `block_card_header()`,
  `block_card_title()`, `block_card_description()`,
  `block_card_content()`, `block_card_footer()`.
- Alert composition: `block_alert()`, `block_alert_title()`,
  `block_alert_description()`.
- Content: `block_value_box()`, `block_badge()`,
  `block_separator()`, `block_skeleton()`, `block_empty()`,
  `block_spinner()`.
- Buttons: `block_button()` with `default | secondary | outline | ghost
  | destructive | link` variants and `default | sm | lg | icon` sizes.
  Icons integrate via `data-icon`, never size classes.
- Tabs: `block_tabs()` + `block_tab()` as a **styled wrapper around
  `shiny::tabsetPanel()`**. Decoration only — Bootstrap-flavored
  classes (`nav`, `nav-link`, `shiny-tab-input`, `data-bs-toggle`,
  `data-value`) are left intact because `BootstrapTabInputBinding`
  keys off them. The wrapper adds `sb-tabs`, ARIA roles, and CSS
  styling. Add `bslib` to `Imports` when this wrapper lands because
  `tabsetPanel()` calls `bslib::buildTabset()` internally. ADR
  `0007-tabs-and-bootstrap.md`.
- Form layout: `block_field()`, `block_field_group()`,
  `block_field_label()`, `block_field_description()`,
  `block_field_set()`, `block_field_legend()`. These wrap Shiny
  inputs; they do not replace them.
- Input groups: `block_input_group()`, `block_input_group_addon()`
  for prefixed/suffixed inputs (search bars, currency inputs,
  inline buttons). Wraps a Shiny input; does not replace it.
- Theme: `block_theme()`, `block_dark_mode_toggle()`,
  `update_block_theme()`.
- Icons: `block_icon()` with vendored Lucide sprite.
- Utilities (internal): `merge_classes()`, `validate_children()`.
- One starter app under `inst/templates/starter/`, a dogfooded
  showcase app under `inst/showcase/`, and a Shinylive export path
  that stages the showcase as a static site under `site/showcase/`.

**Explicitly out of scope for v0.1** with one-line reason each, so
future scope discussions don't relitigate:

- **Dialog, Sheet, Drawer, AlertDialog** — need focus traps, scroll
  lock, and Floating UI; v0.2 with their own ADR.
- **Popover, Tooltip, HoverCard, DropdownMenu, ContextMenu, Menubar,
  NavigationMenu** — all need Floating UI for positioning; v0.2.
- **Toast** — wrap `shiny::showNotification()` rather than
  reimplement; v0.2 with restyle pass.
- **Combobox, Command palette** — substantial keyboard model and
  filtering logic; v0.3+.
- **Calendar, DatePicker** — heavy component with locale handling;
  defer or wrap a Shiny date input.
- **DataTable** — defer to existing R packages (DT, reactable);
  shinyblocks provides the surrounding card/empty/skeleton chrome.
- **Pagination** — pairs with DataTable; deferred together.
- **ToggleGroup** — needs a Shiny input binding so the toggle state
  is reactive; v0.2 with a small input-binding ADR.
- **Breadcrumb, NavigationMenu** — useful but not v0.1-critical;
  cheap to add in v0.2.
- **Avatar** — requires `AvatarFallback` as a non-default arg per
  skill; v0.2.
- **Accordion, Collapsible** — need a behavior module and proper
  ARIA; v0.2.
- **Progress** — Shiny has `withProgress()`; restyling its output
  cleanly needs design work. v0.2.
- **Resizable, ScrollArea** — niche; v0.3+.
- **Form validation primitives** beyond `block_field_invalid()`
  — full validation state management is v0.2.
- **Charts (`Chart`/Recharts wrapper)** — defer to existing R
  packages (ggplot2, plotly, echarts4r); shinyblocks supplies card
  chrome only.
- **Drag-and-drop, virtualized lists, animations beyond CSS
  transitions** — out indefinitely without a strong use case.
- **bslib, shinydashboard, or bs4Dash interop** — by design, not
  supported. Pick one framework per app.

---

## File Layout

```
DESCRIPTION
NAMESPACE
R/
  deps.R            # shinyblocks_dependency(), attach_shinyblocks_deps()
  page.R            # block_page(), block_body()
  header.R          # block_header()
  sidebar.R         # block_sidebar(), block_nav(), block_nav_item()
  card.R            # block_card() + card_header/title/description/
                    # content/footer composition primitives
  value-box.R       # block_value_box()
  button.R          # block_button() with data-icon integration
  badge.R           # block_badge()
  alert.R           # block_alert() + alert_title, alert_description
  separator.R       # block_separator()
  skeleton.R        # block_skeleton()
  spinner.R         # block_spinner()
  empty.R           # block_empty()
  field.R           # block_field, field_group, field_label,
                    # field_description, field_set, field_legend
  input-group.R     # block_input_group, input_group_addon
  tabs.R            # block_tabs(), block_tab() wrapping tabsetPanel
  theme.R           # block_theme(), update_block_theme()
  dark-mode.R       # block_dark_mode_toggle()
  icon.R            # block_icon()
  utils.R           # merge_classes(), validate_children(),
                    # variant validation helpers
  showcase.R        # run_showcase()
  zzz.R
tools/
  export-shinylive.R       # clean staging + shinylive::export()
.github/
  workflows/
    R-CMD-check.yaml       # routine cross-platform package checks
    cran-release-check.yaml # strict manual CRAN release checks
inst/
  www/
    src/
      shinyblocks.css      # Tailwind v4 source: @theme, @layer, @apply
      tokens.css           # vendored shadcn oklch tokens (imported)
    shinyblocks.css        # COMPILED, committed, shipped
    shinyblocks.js         # ES modules
    icons/
      sprite.svg           # vendored Lucide subset
      LICENSE              # ISC, attribution
    floating-ui.min.js     # deferred to v0.2; not shipped in v0.1
  templates/
    starter/               # one runnable example app
  showcase/
    app.R                  # local showcase source
    R/
Makefile                   # build-css target
package.json               # devDependencies: tailwindcss, @tailwindcss/cli
.shinylive-stage/          # GENERATED, ignored
site/                      # GENERATED, ignored; deployment artifact root
  pkgdown/                 # optional generated package docs
  showcase/                # generated Shinylive app
docs/
  decisions/
    0001-package-scope.md
    0006-styling-foundation.md     # to be authored
    0007-tabs-and-bootstrap.md     # to be authored
    0008-icons-and-dark-mode.md    # to be authored
    0009-upstream-sync.md          # to be authored
    0010-shinylive-showcase.md
    0011-cran-ci.md
    0012-rename-to-shinyblocks.md
  upstream/
    sb-sync.md         # token version, last reviewed components
  ROADMAP.md
  agent-plans/
    2026-05-08-port-strategy.md    # this file
tests/testthat/
vignettes/
  getting-started.Rmd
  theming.Rmd
  coexistence.Rmd
```

---

## Implementation Sequence

Each step ends with a green `devtools::check()` and at least one
deterministic test of generated tag shape.

1. **Asset dependency and static shell.** `R/deps.R` exposes
   `shinyblocks_dependency()` and `attach_shinyblocks_deps()`.
   `block_page()`, `block_header()`,
   `block_sidebar()`, `block_body()`. Renders without JS.
   Semantic landmarks: `<header>`, `<aside>`, `<main>`.
2. **CSS build pipeline.** `inst/www/src/tokens.css` and
   `inst/www/src/shinyblocks.css` contain tokens and the component
   CSS source. `Makefile` target `build-css` and `package.json`
   script `build:css` both invoke `@tailwindcss/cli`. CI verifies the
   committed compiled CSS matches what the source produces.
3. **Package infrastructure.** Add CRAN-readiness GitHub Actions,
   pkgdown, local showcase, Shinylive export, CI, budget script,
   doc-link check, and only the `Suggests` that are actually used by
   wired checks. The routine workflow checks Ubuntu R devel, Ubuntu R
   release, Ubuntu R oldrel-1, macOS R release, and Windows R release
   with latest verified workflow action majors. The manual release
   workflow runs `R CMD check --as-cran`, PDF manual checks with TeX,
   URL checks, spell checks, pkgdown, and Shinylive export smoke once
   available. The Shinylive path stages a clean app, copies only
   needed `R/` helpers and `inst/www` assets, verifies r-wasm package
   availability for every runtime dependency, exports to
   `site/showcase/`, and checks `site/showcase/app.json` size.
4. **Tokens and base styles.** Vendor the oklch token set into
   `:root` and `[data-theme="dark"]`. Add base typography, layout,
   focus-visible ring.
5. **Icons.** Vendor Lucide sprite. Implement `block_icon()`.
6. **Buttons, badges, alerts.** All static.
7. **Cards and value boxes.** Compose with icons and badges.
8. **Navigation.** `block_nav()` and `block_nav_item()` with
   selected state. Sidebar collapse JS module.
9. **Tabs.** Wrap `shiny::tabsetPanel()`. Add restyle CSS only.
10. **Theme runtime.** `block_theme()`, `block_dark_mode_toggle()`,
   `update_block_theme()`. Inline first-paint script for
   `prefers-color-scheme`.
11. **Example app, Shinylive public showcase, and vignettes.**
12. **R CMD check** clean, including manual/PDF checks at release.
    Tag v0.1.0.

---

## Tests and Checks

- Unit tests on generated tag shape for every exported function.
  Use snapshot tests sparingly and only for stable HTML; prefer
  attribute and class assertions.
- Validation tests: invalid `variant`, `size`, missing required args
  raise informative errors.
- Dependency attachment test: `block_page()` attaches exactly one
  copy of the dependency even when called inside a nested context.
- ARIA attribute tests: components emit the documented ARIA roles
  and properties.
- `devtools::test()` clean before commit; `devtools::check()` clean
  before tagging.
- Visual regression deferred until v0.2; v0.1 prioritizes deterministic
  R-level tests.
- GitHub Actions CRAN matrix from Phase 1C onward: routine push/PR
  checks run on Ubuntu devel/release/oldrel-1 plus macOS and Windows
  release. Release candidates additionally require a green manual
  `cran-release-check.yaml` run with `R CMD check --as-cran` and
  manual/PDF generation.
- Shinylive export smoke from Phase 1C onward: run the clean staging
  export to `site/showcase/`, serve generated `site/` with
  `python3 -m http.server`, wait through webR's first load, enter
  the app iframe, and verify the shell, sidebar, theme, and at least
  one component example at desktop and mobile widths.

---

## Shinylive Showcase

The showcase has two execution modes:

- **Local package mode:** `shinyblocks::run_showcase()` runs
  `inst/showcase/app.R` from the installed package or
  `devtools::load_all()` checkout.
- **Shinylive export mode:** `tools/export-shinylive.R` builds a
  clean `.shinylive-stage/` directory and runs
  `shinylive::export(appdir = ".shinylive-stage",
  destdir = "site/showcase")`.

The staged app contains only:

```text
app.R
R/
  shinyblocks/        # copied package helpers needed by showcase
  showcase/           # showcase code
www/
  shinyblocks/        # copied inst/www assets
```

Until `shinyblocks` has a webR/WASM binary, staged `app.R` uses
`library(shiny)` and `library(htmltools)` and relies on Shiny's
automatic `R/` sourcing. It does not call `library(shinyblocks)`.

`shinyblocks_dependency()` supports both runtime layouts:

- normal package mode uses
  `htmltools::htmlDependency(package = "shinyblocks", src = "www",
  ...)`;
- staged Shinylive mode uses
  `htmltools::htmlDependency(src = c(href = "shinyblocks"), ...)`
  with assets copied under `www/shinyblocks/`.

The staged export sets an internal option such as
`options(shinyblocks.asset_mode = "app")`. This option is not part of
the public user API.

The generated site root is `site/`, with the showcase at
`site/showcase/`. That avoids overloading root `docs/`, which already
holds maintainer planning docs and may conflict with pkgdown's common
`docs/` output convention. Deployment should upload the generated
`site/` artifact to GitHub Pages or another static host. If the
repository remains private and GitHub Pages is unavailable, the same
artifact can be deployed to Cloudflare Pages or Netlify.

User-facing links to the hosted showcase must warn that first visit
can take 1-2 minutes while webR and package binaries download and
cache.

---

## Upstream Sync

`docs/upstream/sb-sync.md` is a living log:

- shadcn/ui commit/version reviewed.
- Date of review.
- Tokens that changed; whether adopted.
- Components reviewed; what was adopted, adapted, or skipped.
- Open follow-ups.

Review cadence: every minor release of shinyblocks, or when shadcn
ships a major design refresh, whichever is sooner.

When upstream changes, run the question list:

1. Did tokens change? If yes, update the vendored block and document
   in NEWS as a theming change.
2. Did component variants change? Decide adopt/skip per component.
3. Did accessibility behavior improve? Adopt where compatible with
   the existing R API.
4. Is a public R API change required? If yes, deprecation cycle.

---

## Release Policy

- **Patch:** bug fixes, CSS fixes, accessibility fixes,
  documentation improvements.
- **Minor:** new components, new variants, additional theme tokens,
  visual refinements that do not break existing markup users may
  depend on.
- **Major:** R function/argument breaking changes, removed or
  renamed public theme tokens, structural HTML changes that user
  CSS would visibly depend on.

---

## Resolved ADRs

These pin down the previously open decisions and unblock implementation:

- `0006-styling-foundation.md` — formalize Strategy D, document the
  dev-time Tailwind build and the no-runtime-Tailwind decision.
- `0007-tabs-and-bootstrap.md` — wrap `shiny::tabsetPanel` while
  preserving Shiny/Bootstrap tab markup; add only classes, roles, and
  ARIA decoration; document Bootstrap coexistence rules.
- `0008-icons-and-dark-mode.md` — Lucide subset, sprite generation,
  `data-theme` attribute, first-paint script, and fixed-theme CSP
  fallback.
- `0009-upstream-sync.md` — review cadence, sync log shape, deprecation
  policy for tokens.
- `0010-shinylive-showcase.md` — Shinylive staging, app-asset
  dependency mode, r-wasm availability checks, static-site
  composition, and deployment policy.
- `0011-cran-ci.md` — CRAN-readiness GitHub Actions using latest
  verified workflow action majors; routine matrix checks and strict
  manual release checks.
- `0012-rename-to-shinyblocks.md` — rename package identity to
  `shinyblocks`, move public API prefix to `block_*`, and use
  `sb-*` for internal CSS/runtime naming.

# ADR 0013: Component Gallery with Quarto + Shinylive

## Status

Accepted (2026-05-08)

## Context

The pkgdown reference (auto-generated from roxygen) is good for function
signatures and short examples but does not show components running. For a
UI library the live render is the documentation — a static signature for
`block_button()` does not communicate variants, hover states, or focus
rings. The reference site we want to match is
<https://shiny.posit.co/r/components/>: each component has its own page
with an embedded Shinylive app at the top, the source code immediately
below, then "Relevant Functions" and "See also" sections.

That site is built with Quarto and the [`quarto-ext/shinylive`][ext]
extension, which provides `{shinylive-r}` and `{shinylive-python}` code
fences. The fence body is a complete Shiny app; the extension wraps it
in a `<shiny-app>` web component that boots webR in the page.

[ext]: https://github.com/quarto-ext/shinylive

The package already commits to Shinylive for the standalone showcase
export ([ADR 0010](0010-shinylive-showcase.md)). The component gallery
is the second consumer of the same Shinylive runtime.

## Decision

The component gallery is a Quarto-powered set of pkgdown articles, one
per exported component, modelled on shiny.posit.co/r/components.

### Tooling

- **Quarto** is a developer/CI dependency, not an end-user dependency.
  Required to build the pkgdown site; never required to install or use
  the R package.
- The **`quarto-ext/shinylive` Quarto extension** is checked into the
  repository under `_extensions/quarto-ext/shinylive/`, the same
  pattern shiny.posit.co uses. Installing it locally is one
  command — `quarto add quarto-ext/shinylive` — and the
  `Makefile` exposes that as `make quarto-setup`.
- pkgdown 2.1+ is required (it is the first version with first-class
  `.qmd` support).

### Layout

Pages live under `vignettes/articles/`, the pkgdown convention for
articles that are built into the site but not into the CRAN tarball
(they are listed in `.Rbuildignore`):

```
vignettes/articles/
├── components.qmd                          # gallery landing
└── components/
    ├── _examples/                          # shared example sources
    │   ├── button.R
    │   ├── badge.R
    │   ├── alert.R
    │   ├── card.R
    │   └── …
    ├── button.qmd
    ├── badge.qmd
    ├── alert.qmd
    ├── card.qmd
    └── …
```

Each component page follows a fixed template:

1. YAML front matter — `title`, optional `description`.
2. A one-paragraph lead.
3. A `{shinylive-r}` fence with `#| standalone: true`, `#| components:
   [viewer]`, `#| viewerHeight:` set per component, body via Quarto
   `{{< include _examples/<component>.R >}}`.
4. A plain `r` fence showing the same code (same include — single
   source of truth).
5. **Relevant Functions** — bulleted list of signature lines linking
   to the auto-generated pkgdown reference page.
6. **Details** — short prose, optionally a numbered list.
7. **See also** — sibling components and any related vignettes.

### Examples are the single source of truth

Each `_examples/<component>.R` file is a complete, runnable Shiny app
with `library(shiny)`, `library(shinyblocks)`, `ui <-`, `server <-`,
`shinyApp(...)`. The same file is included twice in the `.qmd` (once
for the live demo, once as the visible code listing) and is the
canonical example for the component. The maintainer-facing showcase
under `inst/showcase/` is a separate concern and may load these files
directly or wrap them.

### Taxonomy

The gallery groups components by purpose rather than by Posit's
inputs/outputs/messages split (shinyblocks is a layout/UI library,
not an inputs library). The grouping follows the existing pkgdown
reference categories: **Layout**, **Navigation**, **Content**,
**Action**, **Icon**.

### Build

- `make gallery` — runs `quarto render vignettes/articles/` and
  serves the built site locally.
- `make pkgdown` already builds the full pkgdown site, which calls
  Quarto under the hood for `.qmd` articles when Quarto is installed.
- CI installs Quarto and the shinylive extension as part of the
  pkgdown workflow; missing Quarto blocks the gate.

## Consequences

**Positive:**

- The gallery is the same shape as shiny.posit.co/r/components, which
  is the visual standard users already recognise.
- One source file per component drives both the live demo and the
  visible listing — no drift between what runs and what is shown.
- pkgdown reference pages stay focused on signatures; the gallery
  carries the visual story. Each links to the other.

**Negative / accepted costs:**

- Quarto becomes a hard dev/CI dependency. Contributors who only edit
  R code do not need it; anyone touching the gallery does.
- The shinylive extension is checked in under `_extensions/`, which is
  another vendored upstream tracked manually — analogous to the
  vendored Lucide sprite ([ADR 0008](0008-icons-and-dark-mode.md)).
- Component pages cannot live inside `man/` or roxygen comments — the
  gallery and the reference are two separate artifacts that have to
  cross-link manually.

**Out of scope for this ADR:**

- Editor-mode shinylive embeds (`components: [editor, viewer]`) — the
  gallery is viewer-only to keep pages short; an editor-mode "playground"
  page may come later.
- Per-component theming demos. The theming vignette ([ADR 0006](0006-styling-foundation.md))
  covers the token system in one place.
- Gallery deployment to a separate domain. The gallery is part of the
  pkgdown site under `articles/components/`, deployed alongside it.

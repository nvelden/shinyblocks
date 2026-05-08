# Troubleshooting

Common problems users hit when building dashboards with shinyshadcn,
and how to resolve them. This page is also published as a pkgdown
article.

If you hit something not listed here, open an issue with a minimal
reproducible example.

## My theme isn't applying

You're probably using `shiny::fluidPage()` or `shiny::bootstrapPage()`
instead of `shadcn_page()`. shinyshadcn does not load Bootstrap, and
its CSS is attached only when you use `shadcn_page()` as the page
constructor. Replace `fluidPage()` with `shadcn_page()`.

## Tabs aren't switching

`shadcn_tabs()` wraps `shiny::tabsetPanel()` and relies on Shiny's
existing tab input binding. The binding keys off specific classes
(`nav`, `nav-link`, `shiny-tab-input`, `data-bs-toggle="tab"`,
`data-value`). If you post-process the result of `shadcn_tabs()` and
strip those, switching breaks. Decorate with `tagQuery()$addClass()`
only — never replace the underlying elements.

## Dark mode briefly flashes light on first paint

The first-paint script lives in the `<head>` and runs synchronously
before stylesheets load. If you see a flash, check that you're using
`shadcn_page()` (the script is injected there) and that no other
script tag is being injected *before* it that defers parsing.

## My app uses a strict Content Security Policy

The default system-aware dark-mode behavior uses a tiny inline script
in `<head>` to avoid a first-paint theme flash. Strict CSP deployments
that disallow inline scripts should use a fixed initial theme such as
`shadcn_page(theme_mode = "light")` or
`shadcn_page(theme_mode = "dark")` once that argument is implemented.
Those modes avoid inline first-paint script injection and trade away
automatic system-theme detection.

## My Shiny inputs look like default Bootstrap

That's expected. shinyshadcn does not restyle every Shiny input
globally because Shiny ships Bootstrap and a global override would
collide with bslib/shinydashboard if also loaded. To get shadcn
styling on Shiny inputs, wrap them in `shadcn_field()` (for
labelled inputs) or `shadcn_input_group()` (for prefixed/suffixed
inputs). The wrapper supplies the styling scope.

## I see two labels on my input

You passed a `label` to both the Shiny input and `shadcn_field_label()`.
Pass `label = NULL` to the Shiny input so only the shadcn label is
visible. Shiny still emits an empty `<label class="shiny-label-null">`
for `aria-labelledby` purposes; shinyshadcn's CSS hides it.

## A ghost label is showing despite `label = NULL`

The CSS rule `.shiny-label-null { display: none }` is part of
shinyshadcn's stylesheet. If a ghost label is visible, the
stylesheet did not load. Check that `shadcn_page()` is the page
constructor and that the network tab shows `shinyshadcn.css` loaded.

## `shadcn_icon("foo")` errors

The icon name was not in the vendored Lucide subset (~80 icons).
Either pick a different name (see the Icon reference page on the
pkgdown site for the full list) or pass a custom SVG tag:

```r
shadcn_icon(htmltools::tag("svg", list(...)))
```

## My custom CSS variable override isn't taking effect

CSS custom properties cascade; setting `--primary` on a deeply nested
element only affects descendants of that element. Use
`shadcn_theme()` which scopes the override to the page root, or set
the variable on `:root` in your own stylesheet loaded after
shinyshadcn.

## Server-side `update_shadcn_theme()` doesn't change the theme

The custom message handler is registered in shinyshadcn's bundled
JS. If your app uses `removeUI()`/`insertUI()` to swap large parts of
the page, ensure the dependency is still present after the swap.
Also check that `session = shiny::getDefaultReactiveDomain()` is the
right session in non-trivial app architectures.

## Components from bslib / shinydashboard / bs4Dash look broken

shinyshadcn does not officially support coexistence with other
dashboard frameworks. Their CSS will collide with shadcn tokens and
their JS bindings may overlap. Pick one framework per app.

## My pkgdown build fails on a `shadcn_*` example

Roxygen `@examples` blocks render at site-build time without a Shiny
runtime. If your example needs a session, wrap in `\dontrun{}`. For
display-only components, the example renders fine without Shiny.

## The hosted showcase is slow the first time

The public showcase runs with Shinylive, so the browser downloads
webR and precompiled R package binaries on first visit. A first load
of 1-2 minutes can be normal. Reloads are faster after the browser
caches those assets.

## The Shinylive showcase says a package is unavailable

webR cannot install arbitrary R packages from source in the browser.
Every package used by the staged showcase must exist in the r-wasm
package index for the target R version. Remove the unavailable
dependency from the Shinylive path, replace it with browser-safe
code, or wait until a WebAssembly binary is available.

## The Shinylive export is unexpectedly huge

`shinylive::export()` recursively serializes the app directory into
`app.json`. Export only from the clean `.shinylive-stage/` directory,
never from the repository root. If `site/showcase/app.json` suddenly
grows, inspect the staged directory for copied caches, package check
output, local docs, screenshots, or unrelated assets.

## The Shinylive app is blank when served locally

Serve generated output with a static server that handles WebAssembly
assets correctly:

```bash
python3 -m http.server 8080 --directory site --bind 127.0.0.1
```

Then open `/showcase/`. Do not use the repository root as the server
directory when verifying the exported app.

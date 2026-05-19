# Troubleshooting

Common problems users hit when building dashboards with shinyblocks,
and how to resolve them. This page is also published as a pkgdown
article.

If you hit something not listed here, open an issue with a minimal
reproducible example.

## My theme isn't applying

You're probably using `shiny::fluidPage()` or `shiny::bootstrapPage()`
instead of `block_page()`. shinyblocks does not load Bootstrap, and
its CSS is attached only when you use `block_page()` as the page
constructor. Replace `fluidPage()` with `block_page()`.

## Tabs aren't switching

`block_tabs()` owns its rendered trigger and panel markup. If you
post-process the result and remove `data-sb-tabs`, trigger
`data-value` attributes, ARIA relationships, or the package-owned
classes, switching breaks. Prefer the public `class` argument for
styling and avoid replacing the underlying trigger/panel elements.

## Dark mode briefly flashes light on first paint

The first-paint script lives in the `<head>` and runs synchronously
before stylesheets load. If you see a flash, check that you're using
`block_page()` (the script is injected there) and that no other
script tag is being injected *before* it that defers parsing.

## My app uses a strict Content Security Policy

The default system-aware dark-mode behavior uses a tiny inline script
in `<head>` to avoid a first-paint theme flash. Strict CSP deployments
that disallow inline scripts should use a fixed initial theme such as
`block_page(theme_mode = "light")` or
`block_page(theme_mode = "dark")` once that argument is implemented.
Those modes avoid inline first-paint script injection and trade away
automatic system-theme detection.

## My Shiny inputs look like default Bootstrap

That's expected. shinyblocks does not restyle every Shiny input
globally because Shiny ships Bootstrap and a global override would
collide with bslib/shinydashboard if also loaded. Prefer runtime
controls such as `block_input()`, `block_textarea()`, `block_select()`,
`block_checkbox()`, and `block_slider()`. Use `block_input_group()`
when you need prefixed/suffixed composition around a runtime control.

## I see two labels on my input

You are probably still composing a raw Shiny input inside
`block_field()` while also adding `block_field_label()`. The supported
contract is to use runtime controls such as `block_input()` or
`block_textarea()` inside the field wrapper. If you keep a raw Shiny
input there, its label behavior is outside the migrated field contract.

## A ghost label is showing despite `label = NULL`

That points to a raw Shiny input still being used where a runtime
control should be used instead. Migrate that field to the corresponding
`block_*()` input helper rather than relying on the old wrapped-input
path.

## `block_icon("foo")` errors

The icon name was not in the vendored Lucide subset (~80 icons).
Either pick a different name (see the Icon reference page on the
pkgdown site for the full list) or pass a custom SVG tag:

```r
block_icon(htmltools::tag("svg", list(...)))
```

## My custom CSS variable override isn't taking effect

CSS custom properties cascade; setting `--primary` on a deeply nested
element only affects descendants of that element. Use
`block_theme()` which scopes the override to the page root, or set
the variable on `:root` in your own stylesheet loaded after
shinyblocks.

## Server-side `update_block_theme()` doesn't change the theme

The custom message handler is registered in shinyblocks's bundled
JS. If your app uses `removeUI()`/`insertUI()` to swap large parts of
the page, ensure the dependency is still present after the swap.
Also check that `session = shiny::getDefaultReactiveDomain()` is the
right session in non-trivial app architectures.

## A showcase runtime component preview is blank or stale

The local showcase uses hash navigation and hides inactive sections
client-side. Shiny may suspend `renderUI()` outputs while a section is
hidden, so an argument/code block can update while the actual preview
mount remains blank or stale.

For interactive showcase previews that live inside hidden sections,
set output suspension off for every related output:

```r
output$showcase_button_preview_ui <- shiny::renderUI({
  block_button("Continue")
})
shiny::outputOptions(
  output,
  "showcase_button_preview_ui",
  suspendWhenHidden = FALSE
)
```

Do the same for paired code, value, action, or API-table outputs if
they are expected to stay reactive after section switches.

## Runtime component style changes do not show in the showcase

First separate three possible failures:

1. The R payload is wrong.
2. The browser runtime cannot apply the payload.
3. The running Shiny app/browser tab is stale.

Check the R payload first. Inline styles for runtime React components
must be serialized as a JSON object, not a raw CSS string:

```bash
Rscript -e "devtools::load_all('.', quiet=TRUE); rt <- htmltools::renderTags(block_button('Continue', style='color: red;', id='preview')); html <- paste(rt$html, collapse=''); json <- sub('.*data-shinyblocks-payload=\"\">', '', html); json <- sub('</script>.*', '', json); cat(json)"
```

Expected shape:

```json
"attrs":{"style":{"color":"red"},"id":"preview"}
```

If the payload still contains `"style":"color: red;"`, normalize the
style before it reaches React. `block_button()` does this through
`normalize_runtime_style()`. The browser runtime intentionally expects a
style object and fails hard if a raw style string reaches React; keep the
string-to-object conversion in R so component behavior is tested before
the bundle runs.

Then verify the live browser behavior:

```bash
node -e "const { chromium } = require('playwright'); (async () => { const browser = await chromium.launch({headless:true}); const page = await browser.newPage(); await page.goto('http://127.0.0.1:4321/#button', {waitUntil:'domcontentloaded'}); await page.waitForSelector('#showcase_button_doc_style'); await page.fill('#showcase_button_doc_style','color: red;'); await page.waitForTimeout(500); const out = await page.evaluate(() => { const btn = document.querySelector('#showcase_button_preview'); if (!btn) return {exists:false}; const cs = getComputedStyle(btn); return {exists:true, text: btn.textContent.trim(), style: btn.getAttribute('style'), color: cs.color, display: cs.display}; }); console.log(JSON.stringify(out)); await browser.close(); })();"
```

Expected result includes:

```json
{"exists":true,"style":"color: red;","color":"rgb(255, 0, 0)","display":"inline-flex"}
```

If R and browser checks pass but the visible tab still looks wrong,
restart the local showcase process and hard refresh the browser:

```bash
make showcase
```

When port `4321` is already occupied, find and stop the stale server
before restarting:

```bash
lsof -nP -iTCP:4321 -sTCP:LISTEN
kill <PID>
make showcase
```

## Components from bslib / shinydashboard / bs4Dash look broken

shinyblocks does not officially support coexistence with other
dashboard frameworks. Their CSS will collide with shadcn tokens and
their JS bindings may overlap. Pick one framework per app.

## My pkgdown build fails on a `block_*` example

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

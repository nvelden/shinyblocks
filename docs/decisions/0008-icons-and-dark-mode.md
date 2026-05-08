# ADR 0008: Icons and Dark Mode

## Status

Accepted (2026-05-08)

## Context

Two cross-cutting concerns in v0.1: how the package emits icons, and
how it handles light/dark theme switching. Both must work without
JavaScript frameworks, both must match shadcn upstream conventions
where possible, and both must respect Shiny's page-rendering
constraints.

## Icons — Decision

- **Library:** Lucide (ISC license), matching `iconLibrary: lucide` in
  `components.json`.
- **Distribution:** vendored SVG sprite at `inst/www/icons/sprite.svg`.
  License attribution at `inst/www/icons/LICENSE`.
- **Subset:** ~80 icons, curated from typical dashboard needs (see
  `inst/www/icons/MANIFEST.json` for the list and the upstream commit
  pinned).
- **Sprite generation:** a small Node script `tools/build-icons.mjs`
  pulls from `lucide-static`, concatenates the chosen subset into
  `<symbol id="...">` blocks, and writes the sprite. Run via
  `make build-icons`. Output is committed.
- **R API:**

  ```r
  block_icon(name, class = NULL, ...)
  ```

  - `name` is either a string (validated against the sprite at call
    time) or an `htmltools::tag` (custom SVG passthrough).
  - Emits `<svg><use href="path/to/sprite.svg#icon-name"/></svg>`.
  - No `size` argument; per-component CSS sizes icons.
  - Components that consume an icon argument apply
    `data-icon="inline-start"` (default) or `"inline-end"` via
    `htmltools::tagQuery()`. Icon helpers and component CSS never
    emit `size-*` classes on the SVG itself.

- **String-vs-symbol divergence (acknowledged):** shadcn's "pass
  icons as objects" rule is JSX-specific. R has no equivalent of TS
  symbol imports; string names are idiomatic. The string is
  validated to fail fast on typos. Custom SVGs go through the
  tag-passthrough path.

- **Budget:** sprite ≤25 KB gzipped. Enforced by `tools/budget.R`.

## Dark Mode — Decision

- **Attribute target:** `<html data-theme="dark">`.
- **Mechanism:** Shiny's page template (`R/shinyui.R::renderPage()`)
  only writes `lang` on `<html>`. Setting the attribute server-side
  is not supported. shinyblocks injects a tiny synchronous **inline
  script in `<head>`** that runs before stylesheet links resolve:

  ```html
  <script>
  (function () {
    try {
      var t = localStorage.getItem('sb-theme');
      if (!t) {
        t = matchMedia('(prefers-color-scheme: dark)').matches
          ? 'dark' : 'light';
      }
      document.documentElement.dataset.theme = t;
    } catch (e) {}
  })();
  </script>
  ```

  The script runs synchronously on parse, so the dark token block is
  active by first paint. No flash of wrong theme.

- **CSS selectors:** `[data-theme="dark"] { ... }` at the `<html>`
  level. shadcn's `.dark` selector is replaced with
  `[data-theme="dark"]` for symmetry with the light default.

- **Toggling:**
  - `block_dark_mode_toggle()` exports a button. Its bound JS
    handler reads/writes `document.documentElement.dataset.theme`
    and persists the choice to `localStorage["sb-theme"]`.
  - `update_block_theme(session, mode = c("light", "dark", "system"))`
    sends a custom message; the JS handler applies it. `"system"`
    clears `localStorage` and re-reads `prefers-color-scheme`.

- **System preference observation:** the inline script falls back
  to `prefers-color-scheme` when no `localStorage` entry is set.
  An optional `MediaQueryList.addEventListener` keeps the page in
  sync if the user's system theme changes during the session and
  no explicit choice has been made.

- **Strict CSP fallback:** `block_page(theme_mode = "light")` and
  `block_page(theme_mode = "dark")` should be able to render without
  injecting the first-paint inline script. In those modes the page gets
  a deterministic theme and does not persist a user preference. The
  default `"system"` mode uses the inline script for no-flash behavior.

## Why not `<body data-theme>` instead

`<body data-theme>` works for descendants of `<body>`, but token
overrides on `:root` would still apply at the `<html>` level, leading
to a visible flash for any element that paints before `<body>`
attaches. `<html data-theme>` is the cleaner default and the standard
web pattern.

## Why not `R CMD` server-side detection

Shiny does not expose `prefers-color-scheme` to the R-side render
function (no headers, no cookies, no first-paint hook). Server-side
detection would either always pick light or require a round-trip,
both of which produce flashes.

## Consequences

- The icon sprite is one HTTP request, cached aggressively. Adding
  a new icon to the package requires a maintainer to edit the
  manifest and run `make build-icons`.
- Custom user SVGs are first-class through the tag-passthrough path.
- The dark-mode inline script is the only inline JS shinyblocks
  injects. Its CSP impact: requires `'unsafe-inline'` in `script-src`
  unless the host app supports `nonce` injection, which Shiny does
  not do for inline scripts in `tags$head()`. Document this caveat
  in the troubleshooting page. Strict CSP apps can set
  `theme_mode = "light"` or `"dark"` to avoid inline script injection
  and accept a fixed initial theme.
- `localStorage` is required for theme persistence. In incognito or
  storage-disabled contexts, the script falls back gracefully via
  the `try/catch` and uses `prefers-color-scheme` only.

## References

- [strategy: Dark Mode](../agent-plans/2026-05-08-port-strategy.md#dark-mode)
- [strategy: Icons](../agent-plans/2026-05-08-port-strategy.md#icons)
- `rstudio/shiny` `R/shinyui.R::renderPage()` and
  `inst/template/default.html` — confirms `lang` is the only
  template-rendered `<html>` attribute.
- [Lucide license](https://lucide.dev/license)

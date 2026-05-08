# ADR 0006: Styling Foundation

## Status

Accepted (2026-05-08)

## Context

shinyshadcn must look like shadcn/ui without forcing end users to install
Node, Tailwind, or any frontend toolchain. shadcn/ui in 2026 ships
Tailwind v4 with `@theme` blocks and oklch CSS custom properties; its
visual fidelity depends on Tailwind utility classes layered with
component styles.

Three foundations were considered:

1. **Standalone handwritten CSS.** Zero build complexity; slow to author;
   harder to track upstream visual refinements.
2. **bslib overlay.** Inherits Bootstrap baseline; philosophical mismatch
   (bslib is Sass-variable centric, shadcn is CSS-custom-property
   centric); ends up rewriting most of Bootstrap.
3. **Dev-time Tailwind v4 build, plain CSS at ship time.** Maintainers
   author with `@theme` and `@apply` against shadcn tokens; Tailwind
   compiles a small purged CSS file that gets committed and shipped.
   Same precedent as `bslib` shipping compiled Bootstrap and `bs4Dash`
   shipping compiled AdminLTE.

## Decision

Adopt option 3.

- CSS source in `inst/www/src/`:
  - `tokens.css` vendors shadcn's oklch CSS custom properties verbatim
    (`:root` and `[data-theme="dark"]` blocks). Header comment pins the
    upstream commit synced from.
  - `shinyshadcn.css` imports `tailwindcss`, imports `tokens.css`,
    declares an `@theme` block mapping shadcn tokens into the Tailwind
    namespace, and authors component styles inside `@layer components`
    using `@apply` with shadcn class patterns.
- Build: `make build-css` runs
  `npx @tailwindcss/cli --input inst/www/src/shinyshadcn.css --output
  inst/www/shinyshadcn.css --minify`. Output is committed to git.
- Drift: CI runs `make build-css` and fails on `git status` change in
  `inst/www/shinyshadcn.css`.
- End users see one `<link rel="stylesheet">` per `shadcn_page()`. No
  Node, no CDN, no runtime build, no Tailwind in the browser.
- Tailwind utility classes are referenced through `@apply` inside our
  own component layer only. They are not exposed to user markup, so
  Tailwind's purger has full visibility into what to keep — output
  size estimate is 15–30 KB minified, 4–8 KB gzipped.

## Why not handwritten CSS

Tracking shadcn upstream visual refinements without Tailwind's `@theme`
plumbing forces re-translating utility patterns into bespoke selectors
each time. The dev-time Tailwind path lets maintainers borrow shadcn's
exact class compositions and let the compiler emit them.

## Why not bslib

bslib's primary theming surface is Sass variables. Emitting shadcn's
`--card` / `--card-foreground` token pairs through bslib means bypassing
its DSL constantly. shadcn's typography scale, button density, focus
rings, and form-control look fight Bootstrap's; restyling Bootstrap to
look like shadcn rewrites most of Bootstrap. Wrong tool.

## Why not Tailwind from a CDN

Tailwind themselves mark the browser CDN as "for development and
prototyping only, not for production." It compiles in the browser
(slow first paint), can't read custom `@theme` config without inline
script tags, and breaks behind firewalls — a real fraction of Shiny
deployments. R package convention is to bundle assets locally; CRAN
discourages packages that fetch resources at runtime.

## Consequences

- Maintainers need Node (pinned in `.tool-versions`) to run
  `make build-css`. Contributors who only edit R don't.
- Two sources of truth (`inst/www/src/shinyshadcn.css` and committed
  `inst/www/shinyshadcn.css`) — the CI drift check enforces
  consistency.
- Adopting upstream visual refinements is a focused activity: edit
  source, run `make build-css`, log the upstream commit in
  `docs/upstream/shadcn-sync.md`.
- Future ADR could promote runtime theming (e.g., `sass`-style live
  recompilation via the `sass` R package) if dynamic theme generation
  becomes a feature. Out of scope for v0.1.

## Out of scope

- Tailwind utility classes in user markup. Users compose
  shinyshadcn's component-layer classes; they do not write Tailwind
  utilities. (They can if they load their own Tailwind, but
  shinyshadcn does not enable it.)
- Runtime sass compilation.
- Dynamic theme switching beyond CSS custom property overrides via
  `shadcn_theme()`.

## References

- [strategy: CSS Build Pipeline](../agent-plans/2026-05-08-port-strategy.md#css-build-pipeline)
- [bslib NEWS — Sass-variable centric theming](https://rstudio.github.io/bslib/news/index.html)
- [Tailwind v4 docs](https://tailwindcss.com/docs/v4-beta)

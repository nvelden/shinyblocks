# Handoff: Issue #40 — CSS isolation audit

## Status (2026-06-03) — RESOLVED

Implemented the **composable** option (a). All three actionable findings fixed,
documented in [ADR 0022](docs/decisions/0022-css-isolation.md) and `NEWS.md`:

1. Preflight reset scoped under `.sb-app` via granular Tailwind imports +
   generated `inst/www/src/preflight.scoped.css` (`tools/build-preflight.mjs`,
   chained into `make build-css`). `block_page()` emits a page-owner
   `body{margin:0;padding:0}` reset (`sb-page-chrome`).
2. Shell tokens moved from `:root` → `.sb-app` (and `[data-theme="dark"]` →
   `[data-theme="dark"] .sb-app`) in `inst/www/src/tokens.css`.
3. Bare `localStorage["theme"]` read removed (`inst/www/shinyblocks.js`, reads
   only `sb-theme`).

Finding 4 (global `@property --tw-*` defaults) left as a documented note (inert).
`make check-slice` green; showcase restarted on :4321 and visually verified
(light + dark). The historical audit detail below is retained for reference.

---

Tracked issue:

```text
https://github.com/nvelden/shinyblocks/issues/40
```

## Decision Needed First

shinyblocks currently assumes it **owns the whole page**. Before fixing, decide:

- **(a) Make it composable** — scope the Preflight reset + design tokens under
  `.sb-app` / `.sb-page` so shinyblocks can be embedded in an existing
  Shiny/bslib app; or
- **(b) Page-owning only** — keep current behavior and document the constraint
  (ADR 0006 / 0009 area).

Findings 1 and 2 below only need fixing under option (a). Finding 3 is worth
fixing either way.

## Findings (full detail in issue #40)

1. **Tailwind Preflight reset ships globally unscoped** (`inst/www/shinyblocks.css`,
   `@layer base`). Resets `*`, `ol,ul,menu`, `h1..h6`, `img/svg/video`,
   `[hidden]` document-wide. Partly cushioned by `@layer` (unlayered author CSS
   wins) but still clobbers UA defaults. Fix: scope under `.sb-app`/`.sb-page`
   in `inst/www/src/shinyblocks.css`, then `make build-css`.
2. **Unprefixed `:root` tokens** (`inst/www/src/tokens.css`): `--background`,
   `--foreground`, `--primary`, `--border`, `--input`, `--ring`, `--radius`, …
   collide with any other shadcn-token lib on the page. Token *names* are a
   public theming contract (renaming = major release), so scope rather than
   rename.
3. **Bare `localStorage["theme"]` read** (`inst/www/shinyblocks.js:9`) — writes
   prefixed `sb-theme` but reads generic `"theme"` first. Drop/gate the bare
   read. Fix regardless of option a/b.
4. Global `@property --tw-*` defaults — note only, no action.

## Confirmed Clean (no action)

- `htmlDependency` name `"shinyblocks"` (`R/deps.R:4`)
- `addResourcePath` prefix `"shinyblocks"` (`R/zzz.R:3`)
- Message handler `"sb:theme"` guarded (`inst/www/shinyblocks.js:344`)
- Input handler `"shinyblocks.button"` (`R/zzz.R:7`)
- No vendored jQuery/Bootstrap; React runtime is a self-contained IIFE
- `setInputValue` uses `{priority:"event"}` (`inst/www/shinyblocks.js:119`)
- Idempotent wiring guards + MutationObserver + `shiny:connected` resync

## Suggested Fix Steps (next chat, if option a)

1. Scope Preflight + tokens under `.sb-app`/`.sb-page` in `inst/www/src/`.
2. `make build-css` to regenerate the committed `inst/www/shinyblocks.css`.
3. Remove the bare `localStorage["theme"]` read.
4. Re-run parity harness (`tools/parity/`) + `make check-slice`; restart
   showcase on 4321 per `AGENTS.md`.
5. Add/extend ADR documenting the isolation contract; update NEWS.

## Runtime State

Local servers may be running (see `AGENTS.md` before restarting):

```bash
lsof -nP -iTCP:4321 -sTCP:LISTEN   # showcase
lsof -nP -iTCP:5173 -sTCP:LISTEN   # parity reference app
```

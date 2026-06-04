# Handoff: Issue #42 - Add more built-in style profiles

## Status (2026-06-04)

Issue: https://github.com/nvelden/shinyblocks/issues/42
Plan: `docs/agent-plans/2026-06-04-more-style-profiles.md`

Decisions are locked in the plan's "Decisions" section and mirrored on the
issue:

- Ship three shinyblocks-owned profiles, **one per PR**, ascending risk:
  `mono` -> `soft` -> `brutal`.
- Each is shinyblocks-owned (no upstream Radix source), so each needs a named
  visual target recorded under `docs/research/` to keep token values reviewable.
- `glass` and the shared translucent-surface refactor are **deferred** to a
  later issue (`glass` needs a backdrop/translucency token that does not exist
  yet).

Issue #41 (runtime/CSS/R decomposition) is done and is reflected in recent
commits on `main`; no #41 follow-up is outstanding.

## Done: `mono` (first profile)

Shipped as **pure token data** — no `[data-sb-style="mono"]` CSS was needed, so
the leanness gate is unaffected.

- `R/style-profiles.R`: `mono = list(...)` — mono-forward fonts (body/heading
  inherit the default `--sb-font-mono` stack), compact control heights, tight
  radii, flat (shadow-less) surfaces, 40% focus ring.
- `tests/testthat/test-style.R`: `mono` in `block_style_profiles()` order
  (`default`, `mono`, `luma`, `rhea`); token-emission checks for `mono`.
- `tools/theme/style-registry.mjs` + `check-style-parity.mjs`: generalized the
  parity sweep with per-profile `neutralProfiles` reasons (mono is data-only for
  shell families and switch/slider/radio/empty geometry).
- `docs/research/2026-06-04-style-profile-sources.md`: source/provenance audit.
- `NEWS.md`: entry under "Other changes" (issue #42).

Verified: `devtools::test(filter = 'style')` (74 pass), `npm run
test:style-leanness`. **Still owed before phase exit:** `npm run
test:style-parity` against the showcase on :4321 plus a light/dark visual pass,
then `make gate`.

## Next Slice: `soft` (second profile)

Airier rounded dashboard UI: larger surface padding/gaps, softer radii, lighter
shadows. All existing tokens — should stay data-first like `mono`.

1. **Source audit.** Record the visual target + provenance in
   `docs/research/2026-06-04-style-profile-sources.md`. List token-data vs
   structural CSS differences.
2. **Add the profile** to `R/style-profiles.R` (`soft = list(...)`), data-first.
   Add only unavoidable structural CSS in
   `frontend/src/styles/runtime/08-style-profiles.css` /
   `inst/www/src/shinyblocks.css`.
3. **Tests** in `tests/testthat/test-style.R`: profile appears in
   `block_style_profiles()` in stable order; token-emission checks for `soft`.
   Add `neutralProfiles.soft` reasons for any binding `soft` leaves unchanged.
4. **Checks:** `Rscript -e "devtools::test(filter = 'style')"`,
   `npm run test:style-leanness`, `npm run test:style-parity`,
   `npm run test:themes-runtime`, `make check-slice`.
5. **Showcase/docs:** confirm the style/theme playground selectors pick `soft`
   up dynamically (no hardcoded lists). Rebuild, then restart the showcase on
   port 4321 and run `make showcase-health` after any runtime/CSS edit.
6. Then repeat the same vertical slice for `brutal`, one PR each.
7. `make gate` before each PR/phase exit.

## Verification commands

```bash
Rscript -e "devtools::test(filter = 'style')"
npm run test:style-leanness
npm run test:style-parity
npm run test:themes-runtime
make check-slice
# after runtime/CSS/showcase edits:
lsof -nP -iTCP:4321 -sTCP:LISTEN
make showcase
make showcase-health
make gate   # before PR/phase exit
```

Do not include `.vscode/` unless explicitly requested.

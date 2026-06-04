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

## Done: `mono` (first profile) — merged

Shipped via PR #43 (squash-merged to `main` as `21eb7ea`, branch deleted).
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

Verified: `devtools::test(filter = 'style')` (74 pass),
`npm run test:style-leanness`, `npm run test:style-parity` against the showcase
on :4321 (60 pass / 0 fail), `npm run test:themes-runtime` (82 pass),
`make check-slice` (1023 pass), and `make gate` (automated steps green).
Known CI note: docs-site `e2e` smoke (`theme toggle switches and persists`) is
flaky on a docs-site theme-toggle assertion unrelated to style profiles.

## Done: `soft` (second profile) — PR open

Implemented and gated on branch `issue-42-soft-style-profile` (PR pending).
Airier rounded dashboard UI, shipped as **pure token data** — no
`[data-sb-style="soft"]` CSS, so the leanness gate is unaffected.

- `R/style-profiles.R`: `soft = list(...)` — roomier `surface_padding`/
  `surface_gap` (2rem), larger overlay padding, softer/larger component radii,
  lighter diffuse `surface_shadow`/`overlay_shadow`, 35% focus ring, 0.2s
  transition. Inserted after `mono` (order: `default`, `mono`, `soft`, `luma`,
  `rhea`).
- `tests/testthat/test-style.R`: `soft` in `block_style_profiles()` stable order;
  token-emission checks for `soft` (spacing, shadow, focus ring, radii).
- `tools/theme/style-registry.mjs`: `neutralProfiles.soft` reasons mirroring
  `mono` (switch/slider/radio/empty geometry + shell families).
- `docs/research/2026-06-04-style-profile-sources.md`: `soft` source/provenance.
- `NEWS.md`: entry under "Other changes" (issue #42).

Verified: `devtools::test(filter = 'style')` (88 pass),
`npm run test:style-leanness`, `npm run test:style-parity` on :4321
(74 pass / 0 fail across mono, soft, luma, rhea), `npm run test:themes-runtime`
(82 pass), `make check-slice`, and `make gate` (automated steps green).
Two gotchas hit & fixed: (1) the parity registry parses `R/style-profiles.R`
naively, so a comment containing `style="soft"` scraped a bogus token — keep
`key="value"` patterns out of profile comments. (2) `code_radius` default is
already 0.75rem, so `soft` needed 1rem to register a parity change; and the
legacy audit forbids `sb-button-` in tests, so the test asserts `--sb-badge-radius`
instead of `--sb-button-radius`.

## Next Slice: `brutal` (third profile)

Dense, high-contrast, square-ish product UI: low radii, stronger borders,
reduced shadows, crisp focus ring. Mostly token data, but **flag any value that
needs a new token** (e.g. border width) rather than adding bespoke
`[data-sb-style="brutal"]` CSS — that is the highest-risk profile of the three.

1. **Source audit.** Re-check upstream shadcn/Radix, record the visual target +
   provenance in `docs/research/2026-06-04-style-profile-sources.md`. List
   token-data vs structural CSS differences; call out any missing token.
2. **Add the profile** to `R/style-profiles.R` (`brutal = list(...)`),
   data-first. Add only unavoidable structural CSS in
   `frontend/src/styles/runtime/08-style-profiles.css` /
   `inst/www/src/shinyblocks.css`, and document each rule in the research file.
3. **Tests** in `tests/testthat/test-style.R`: profile appears in
   `block_style_profiles()` in stable order; token-emission checks for `brutal`.
   Add `neutralProfiles.brutal` reasons for any binding `brutal` leaves
   unchanged. Avoid asserting `--sb-button-*` tokens (legacy audit forbids
   `sb-button-` outside `R/style-profiles.R`).
4. **Checks:** `Rscript -e "devtools::test(filter = 'style')"`,
   `npm run test:style-leanness`, `npm run test:style-parity`,
   `npm run test:themes-runtime`, `make check-slice`.
5. **Showcase/docs:** the style/theme playground selectors already pick up new
   profiles dynamically via `style_profile_names()` (no hardcoded lists).
   Restart the showcase on port 4321 and run `make showcase-health` only if you
   touch runtime/CSS (a data-only profile needs no rebuild).
6. `make gate` before the PR/phase exit. One PR per profile.

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

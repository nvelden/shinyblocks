---
phase: N
title: <phase title>
exited: YYYY-MM-DD
version: 0.0.0.900N
tag: phase-N
---

# Phase N exit — <title>

Copy this file to `phase-N.md` when starting the gate. Tick items as
they pass. Commit when all green. The committed file is the audit
trail; future contributors can `git checkout phase-N` and see exactly
what was verified.

## A. Verify — automated

- [ ] `make build-css` clean; no drift in `inst/www/shinyblocks.css`.
- [ ] `make lint` clean.
- [ ] `make spell` clean.
- [ ] `make urls` clean.
- [ ] Latest-version verification complete for every versioned input
      touched this phase; source/date/version recorded in ADRs, sync
      logs, roadmap notes, or this phase-exit file.
- [ ] `make test` clean.
- [ ] `make docs` (`devtools::document()`) clean.
- [ ] `make check` (`devtools::check(..., manual = FALSE)` or
      `R CMD check --no-manual` on the built source package) clean.
- [ ] `make pkgdown` clean.
- [ ] From Phase 1C onward: `R-CMD-check.yaml` green across the
      CRAN-readiness matrix (Ubuntu devel/release/oldrel-1, macOS
      release, Windows release).
- [ ] From Phase 1C onward: workflow action pins verified against
      latest upstream major versions before editing workflow files.
- [ ] From Phase 1C onward: r-wasm package availability checked for
      every dependency used by the staged Shinylive showcase.
- [ ] From Phase 1C onward: `make shinylive-export` clean;
      `site/showcase/app.json` size inspected for accidental bundling.

## B. Verify — semi-automated

- [ ] `make showcase` runs; `shinytest2` smoke test passes.
- [ ] From Phase 1C onward: generated `site/` served with
      `python3 -m http.server`; Shinylive browser smoke passes with
      long first-load timeout, iframe handling, desktop, and mobile.
- [ ] `make budget` reports CSS, JS, sprite within targets.
- [ ] Manual a11y sweep done; notes in `docs/a11y/notes.md`.

## C. Review

- [ ] Roxygen audit — every export has the five required tags.
- [ ] Utility audit — no copy-pasted helpers.
- [ ] `critical-code-reviewer` skill run on the diff; Blocking and
      Required items addressed.

## D. Document

- [ ] `NEWS.md` entry under the new dev-version heading.
- [ ] `docs/ROADMAP.md` phase ticked off; "Current Status" updated.
- [ ] Strategy doc amended if scope changed.
- [ ] ADRs written or updated as needed.
- [ ] `docs/upstream/sb-sync.md` entry if shadcn was reviewed.
- [ ] Cross-link check across `docs/` clean.
- [ ] Dev notes added if non-obvious problems were hit.

## E. Version and tag

- [ ] `DESCRIPTION` `Version` bumped to `0.0.0.900N`.
- [ ] Single tidy commit on `main`.
- [ ] `git tag phase-N`.
- [ ] CI green on `main`.
- [ ] For release phases only: full manual/PDF check run with a TeX
      toolchain available.
- [ ] For release phases only: manual `cran-release-check.yaml`
      workflow run is green on the release commit.

## F. Optional

- [ ] Showcase deployment refreshed.

## Notes from this phase

Anything notable: decisions made under the gate, deferred items,
follow-ups to track.

- ...

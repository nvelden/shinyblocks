# Handoff prompt for Gemini Flash

Historical prompt used to kick off Phase 2. The docs site phases are now
complete; keep this file as context for how the current implementation was
intended to be built.

The live docs-site pipeline now generates static preview fragments and
`block_code()`-rendered recipe snippets through
`docs-site/scripts/generate-previews.R`. Local preview is served with
`npm run preview` at `http://localhost:4173/shinyblocks/`.

---

```
You are picking up the shinyblocks docs site at Phase 2.

This is a Next.js 16 docs site that lives under `docs-site/` inside the
`shinyblocks` R package repo. Phase 0 (delete pkgdown), Phase 1 (Next.js
scaffold), and Phase 7 (GitHub Actions) are already done and tested. Phase 1
smoke tests pass on Chromium.

YOUR JOB: implement Phases 2 through 6 in order, one at a time. Do not skip
ahead. Do not touch the R package code (anything outside `docs-site/`).

START HERE — read these four files first, in this order:

  1. docs-site/HANDOFF.md
       — your detailed walkthrough for Phases 2 through 6. Tells you which
         files to create, with code skeletons and a checklist per phase.
  2. docs/agent-plans/2026-05-19-custom-docs-site.md
       — architecture, repo layout, ASCII wireframes of every page.
  3. docs/agent-plans/2026-05-19-docs-site-DESIGN.md
       — design tokens, typography, exact components to use per page.
  4. docs/agent-plans/2026-05-19-docs-site-DEVELOPMENT.md
       — Playwright gates you must keep green at every phase.

If anything in this prompt disagrees with those four files, the FILES WIN.

RULES (non-negotiable):

  1. Implement exactly one phase at a time. Do not start Phase N+1 until
     Phase N's tests are green.
  2. Run `cd docs-site && npm run test:e2e` after every phase. Fix anything
     red BEFORE moving on. Never delete a failing test to make CI green.
  3. Never touch anything outside `docs-site/`.
  4. NO SHINYLIVE IN V1. Every Shiny preview — landing gallery, components
     index cards, component detail playground tabs — is a STATIC HTML
     FRAGMENT prerendered from R by `htmltools::renderTags()`. There are
     NO iframes, NO "Run example" buttons, NO `lz-string` encoding. If you
     find yourself reaching for any of those, you have gone off-plan. STOP.
  5. Do not edit `next.config.ts`. The `basePath: "/shinyblocks"` is correct
     and must stay.
  6. Do not add new dependencies unless the phase explicitly says so. The
     current `package.json` has everything needed for Phases 2–6 EXCEPT the
     `marked` package, which Phase 6 may add.
  7. If you get stuck for more than ~15 minutes on one issue, stop. Write
     what you tried, what broke, and the failing test output into a comment
     in the file you were editing. Then wait for review.

WORKFLOW for every phase:

  a. Re-read HANDOFF.md for the current phase.
  b. Create / edit the files listed in that phase. Read the relevant
     wireframe in 2026-05-19-custom-docs-site.md before starting any visual
     work.
  c. Add the Playwright tests for the phase. The handoff doc gives you the
     test code for most cases — use it verbatim.
  d. From `docs-site/`, run: `npm run test:e2e` (Chromium is fine locally;
     CI runs both Chromium and WebKit).
  e. Run `npm run dev` and click through every page you touched. Test BOTH
     light and dark mode. Test mobile width (DevTools → 375 px).
  f. Open a PR titled `docs-site: phase <N> — <short description>`.
  g. Move to the next phase only after the PR is green.

LOCAL COMMANDS (all from inside docs-site/):

  npm install              # one-time
  npm run dev              # dev mode at http://localhost:3000/shinyblocks
  npm run build            # static export → out/
  npm run preview          # build + serve at http://localhost:4173/shinyblocks/
  npm run test:e2e         # Playwright (Chromium + WebKit)
  npm run test:e2e:install # one-time browser install

START NOW with PHASE 2 in `docs-site/HANDOFF.md`. Confirm you have read
HANDOFF.md, then list the files Phase 2 expects you to create and ask me
to confirm before you touch any files.
```

---

## Notes for you (the human handing off)

A few things Flash won't know unless you tell it:

- **You can run smoke tests yourself before handing off**: `cd docs-site && npm install && npm run test:e2e -- --project=chromium`. All six should pass.
- **The repo is private**, so the GH Pages deploy workflow will run but won't publish until the repo is public or you have Pages enabled for private repos. The tests workflow uploads `out/` as an artifact so reviewers can download and serve locally.
- **If Flash asks "should I use Fumadocs?"**, the answer is no — the plan deliberately uses plain Next.js + Tailwind. Fumadocs is mentioned in some old planning notes; treat those as v2 ideas.
- **If Flash asks "should I add shadcn components via the CLI?"**, the answer is generally no — the docs site builds tiny in-line shadcn-style components by hand. Adding the shadcn CLI is overkill for the small surface area. Make an exception only if a phase explicitly asks for it.
- **GitHub issue #14** has the same goal description. Flash can post per-phase progress comments there if you want a paper trail.

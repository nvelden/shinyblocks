# Phase 4 — Components Index Page

## Goal
Replace the placeholder components index page at `app/components/page.tsx` with a robust two-column design:
- A desktop-only sidebar containing a navigation list of all component names.
- A main content area displaying a grid of all registered components as `<ComponentPreview>` cards.

## Assumptions
- The previews manifest JSON file is generated during the prebuild phase.
- All routing prefixes map to `/shinyblocks` base path.

## Proposed API
No new public API. Updates the Next.js `app/components/page.tsx` routing entry.

## Files to Edit/Create
- `docs-site/app/components/page.tsx` [MODIFY]
- `docs-site/tests/e2e/components.spec.ts` [NEW]

## Tests/Checks
- `npm run test:e2e` runs completely green.
- Verify visually that the grid of previews displays under `/shinyblocks/components/` and is fully responsive.

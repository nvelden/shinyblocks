# Phase 3 — Landing Page Gallery

## Goal
Replace `app/page.tsx` with a rich landing page featuring a hero section and a gallery grid of `<ComponentPreview>` cards displaying featured components directly from the prerendered registry manifest.

## Assumptions
- Previews have been successfully generated in `lib/preview-manifest.json` by Phase 2.
- The `ComponentPreview` component is fully functional.

## Proposed API
No new public API. Modifies the internal Next.js `app/page.tsx` page logic.

## Files to Edit/Create
- `docs-site/app/page.tsx` [MODIFY]
- `docs-site/tests/e2e/gallery.spec.ts` [NEW]

## Tests/Checks
- `npm run test:e2e` is completely green.
- Manual inspection of the home page displays the visual previews of `button` and `card`.

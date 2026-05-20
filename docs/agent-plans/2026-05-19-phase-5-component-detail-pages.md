# Phase 5 — Component Detail Pages

## Goal
Replace the non-existent details route with a static dynamic routing layout at `app/components/[slug]/page.tsx` displaying the interactive detail page/playground:
- Component name and description header.
- A "Preview" section showing the prerendered HTML in a full-sized inert container.
- An "R Code" section displaying the exact R recipe used to create the component (read from the manifest).
- A back navigation link to easily return to the components index.

## Assumptions
- We will update the `generate-previews.R` pipeline to inject the raw `.R` source file contents into `preview-manifest.json` under a `code` field.
- Dynamic paths are fully generated using Next.js `generateStaticParams`.

## Proposed API
No new public API. Adds the Next.js `app/components/[slug]/page.tsx` dynamic routing layout.

## Files to Edit/Create
- `docs-site/scripts/generate-previews.R` [MODIFY]
- `docs-site/app/components/[slug]/page.tsx` [NEW]
- `docs-site/tests/e2e/detail.spec.ts` [NEW]

## Tests/Checks
- `npm run test:e2e` runs completely green.
- Manual inspection of details pages `/shinyblocks/components/button/` and `/shinyblocks/components/card/` displays both the live HTML renders and the source code block.
